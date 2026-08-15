package com.sunrisedental.web;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.patterns.decorator.ITreatmentCost;
import com.sunrisedental.patterns.facade.ClinicManagementFacade;

import java.io.*;
import java.net.InetSocketAddress;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

/**
 * 3-TIER ARCHITECTURE - PRESENTATION TIER SERVER
 *
 * Embedded Java HTTP Server providing REST API endpoints (/api/*) and static file serving
 * for all multi-page web interfaces (login.html, register-appointment.html, billing.html, etc.).
 */
public class ClinicServer {

    private static final int PORT = 8080;
    private static final ClinicManagementFacade facade = new ClinicManagementFacade();

    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(PORT), 0);

        // API Contexts
        server.createContext("/api/login", new LoginHandler());
        server.createContext("/api/appointments", new AppointmentsHandler());
        server.createContext("/api/register", new RegisterHandler());
        server.createContext("/api/bill", new BillHandler());
        server.createContext("/api/undo", new UndoHandler());
        server.createContext("/api/reports", new ReportsHandler());
        server.createContext("/api/patterns", new PatternsHandler());

        // Static Files Handler (serves html, js, images)
        server.createContext("/", new StaticFileHandler());

        server.setExecutor(null); // default executor
        System.out.println("==================================================================");
        System.out.println("  SUNRISE DENTAL CLINIC - 3-TIER JAVA APPLICATION SERVER STARTED  ");
        System.out.println("  Server running at: http://localhost:" + PORT + "/login.html");
        System.out.println("==================================================================");
        server.start();
    }

    // Handler 1: User Login
    static class LoginHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            if ("POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                Map<String, String> params = parseRequestBody(exchange);
                String user = params.get("username");
                String pass = params.get("password");

                boolean success = facade.authenticate(user, pass);
                String jsonResponse;
                if (success) {
                    jsonResponse = String.format("{\"success\":true, \"username\":\"%s\", \"role\":\"Authorized Staff\"}", user);
                    exchange.getResponseHeaders().add("Set-Cookie", "clinic_session=" + UUID.randomUUID().toString() + "; Path=/; HttpOnly");
                } else {
                    jsonResponse = "{\"success\":false, \"message\":\"Invalid username or password. Authorized staff only.\"}";
                }
                sendJsonResponse(exchange, 200, jsonResponse);
            } else {
                sendJsonResponse(exchange, 450, "{\"error\":\"Method Not Allowed\"}");
            }
        }
    }

    // Handler 2: Appointments API (Get all or search by appt number)
    static class AppointmentsHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String query = exchange.getRequestURI().getQuery();
            String apptNum = null;
            if (query != null && query.contains("number=")) {
                apptNum = query.split("number=")[1].split("&")[0];
            }

            if (apptNum != null && !apptNum.isEmpty()) {
                Appointment app = facade.getAppointmentDetails(apptNum);
                if (app != null) {
                    sendJsonResponse(exchange, 200, toJson(app));
                } else {
                    sendJsonResponse(exchange, 404, "{\"error\":\"Appointment not found with number " + apptNum + "\"}");
                }
            } else {
                List<Appointment> list = facade.getAllAppointments();
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    sb.append(toJson(list.get(i)));
                    if (i < list.size() - 1) sb.append(",");
                }
                sb.append("]");
                sendJsonResponse(exchange, 200, sb.toString());
            }
        }
    }

    // Handler 3: Register New Appointment
    static class RegisterHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            if ("POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                Map<String, String> params = parseRequestBody(exchange);

                String name = params.get("patientName");
                String address = params.get("address");
                String phone = params.get("contactNumber");
                String dentist = params.get("dentistName");
                String treatment = params.get("treatmentType");
                String date = params.get("appointmentDate");
                String time = params.get("appointmentTime");
                String addOnsRaw = params.get("addOns");

                List<String> addOns = new ArrayList<>();
                if (addOnsRaw != null && !addOnsRaw.isEmpty()) {
                    addOns = Arrays.asList(addOnsRaw.split(","));
                }

                Appointment app = facade.registerAppointment(name, address, phone, dentist, treatment, date, time, addOns);
                sendJsonResponse(exchange, 200, "{\"success\":true, \"appointment\":" + toJson(app) + "}");
            } else {
                sendJsonResponse(exchange, 405, "{\"error\":\"Method Not Allowed\"}");
            }
        }
    }

    // Handler 4: Bill Calculation (Decorator Pattern)
    static class BillHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String query = exchange.getRequestURI().getQuery();
            if (query != null && query.contains("number=")) {
                String apptNum = query.split("number=")[1].split("&")[0];
                Appointment app = facade.getAppointmentDetails(apptNum);
                ITreatmentCost cost = facade.calculateBillBreakdown(apptNum);

                if (app != null && cost != null) {
                    StringBuilder breakdownJson = new StringBuilder("[");
                    List<String> lines = cost.getBreakdown();
                    for (int i = 0; i < lines.size(); i++) {
                        breakdownJson.append("\"").append(escapeJson(lines.get(i))).append("\"");
                        if (i < lines.size() - 1) breakdownJson.append(",");
                    }
                    breakdownJson.append("]");

                    String json = String.format(
                            "{\"appointmentNumber\":\"%s\", \"patientName\":\"%s\", \"dentistName\":\"%s\", \"treatmentType\":\"%s\", \"date\":\"%s\", \"time\":\"%s\", \"baseCost\":%.2f, \"consultationFee\":%.2f, \"totalCost\":%.2f, \"breakdown\":%s, \"description\":\"%s\"}",
                            app.getAppointmentNumber(),
                            escapeJson(app.getPatient().getFullName()),
                            escapeJson(app.getDentistName()),
                            escapeJson(app.getTreatmentType()),
                            app.getAppointmentDate(),
                            app.getAppointmentTime(),
                            app.getBaseCost(),
                            app.getConsultationFee(),
                            cost.calculateCost(),
                            breakdownJson.toString(),
                            escapeJson(cost.getDescription())
                    );
                    sendJsonResponse(exchange, 200, json);
                } else {
                    sendJsonResponse(exchange, 404, "{\"error\":\"Appointment not found for billing\"}");
                }
            } else {
                sendJsonResponse(exchange, 400, "{\"error\":\"Missing appointment number\"}");
            }
        }
    }

    // Handler 5: Undo Edit (Memento Pattern)
    static class UndoHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            if ("POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                Map<String, String> params = parseRequestBody(exchange);
                String apptNum = params.get("appointmentNumber");

                Appointment restored = facade.undoAppointmentEdit(apptNum);
                if (restored != null) {
                    sendJsonResponse(exchange, 200, "{\"success\":true, \"message\":\"Restored to previous state!\", \"appointment\":" + toJson(restored) + "}");
                } else {
                    sendJsonResponse(exchange, 400, "{\"success\":false, \"message\":\"No previous memento state found to undo.\"}");
                }
            } else {
                sendJsonResponse(exchange, 405, "{\"error\":\"Method Not Allowed\"}");
            }
        }
    }

    // Handler 6: Decision Making Reports
    static class ReportsHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            Map<String, Object> reports = facade.getDecisionMakingReports();
            List<String> logs = facade.getNotificationLogs();

            StringBuilder logsJson = new StringBuilder("[");
            for (int i = 0; i < logs.size(); i++) {
                logsJson.append("\"").append(escapeJson(logs.get(i))).append("\"");
                if (i < logs.size() - 1) logsJson.append(",");
            }
            logsJson.append("]");

            String json = String.format(
                    "{\"totalAppointments\":%d, \"totalRevenueLKR\":%.2f, \"notifications\":%s}",
                    (int) reports.get("totalAppointments"),
                    (double) reports.get("totalRevenueLKR"),
                    logsJson.toString()
            );
            sendJsonResponse(exchange, 200, json);
        }
    }

    // Handler 7: Design Patterns Info
    static class PatternsHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String json = "{" +
                    "\"patterns\": [" +
                    "{\"name\":\"Singleton Pattern\", \"type\":\"Creational\", \"class\":\"DatabaseConnectionManager\", \"description\":\"Ensures a single thread-safe instance manages DB connection pools and text-file storage.\"}," +
                    "{\"name\":\"Factory Method Pattern\", \"type\":\"Creational\", \"class\":\"TreatmentFactory\", \"description\":\"Instantiates dental treatments dynamically based on treatment selection.\"}," +
                    "{\"name\":\"Builder Pattern\", \"type\":\"Creational\", \"class\":\"AppointmentBuilder\", \"description\":\"Constructs complex Appointment objects cleanly with step-by-step validation.\"}," +
                    "{\"name\":\"Decorator Pattern\", \"type\":\"Structural\", \"class\":\"TreatmentCostDecorator\", \"description\":\"Wraps base treatment cost with add-ons (X-Ray, Anaesthesia) to compute bills dynamically.\"}," +
                    "{\"name\":\"Observer Pattern\", \"type\":\"Behavioral\", \"class\":\"AppointmentSubject\", \"description\":\"Notifies Email, SMS, and Audit Logger observers on appointment events.\"}," +
                    "{\"name\":\"Facade Pattern\", \"type\":\"Structural\", \"class\":\"ClinicManagementFacade\", \"description\":\"Simplifies 3-tier backend subsystem interactions into clean high-level methods.\"}," +
                    "{\"name\":\"Memento Pattern\", \"type\":\"Behavioral\", \"class\":\"AppointmentMemento\", \"description\":\"Captures state snapshots allowing staff to undo/revert appointment edits.\"}" +
                    "]" +
                    "}";
            sendJsonResponse(exchange, 200, json);
        }
    }

    // Static Files Handler
    static class StaticFileHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String uri = exchange.getRequestURI().getPath();
            if (uri.equals("/")) {
                uri = "/login.html";
            }

            Path filePath = Paths.get("." + uri);
            if (!Files.exists(filePath) || Files.isDirectory(filePath)) {
                sendJsonResponse(exchange, 404, "<h1>404 Page Not Found</h1>");
                return;
            }

            String contentType = "text/html";
            if (uri.endsWith(".js")) contentType = "application/javascript";
            else if (uri.endsWith(".css")) contentType = "text/css";
            else if (uri.endsWith(".png")) contentType = "image/png";
            else if (uri.endsWith(".jpg") || uri.endsWith(".jpeg")) contentType = "image/jpeg";
            else if (uri.endsWith(".json")) contentType = "application/json";

            byte[] bytes = Files.readAllBytes(filePath);
            exchange.getResponseHeaders().set("Content-Type", contentType + "; charset=UTF-8");
            exchange.sendResponseHeaders(200, bytes.length);
            OutputStream os = exchange.getResponseBody();
            os.write(bytes);
            os.close();
        }
    }

    // Helper utilities
    private static void sendJsonResponse(HttpExchange exchange, int statusCode, String response) throws IOException {
        byte[] bytes = response.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
        exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");
        exchange.sendResponseHeaders(statusCode, bytes.length);
        OutputStream os = exchange.getResponseBody();
        os.write(bytes);
        os.close();
    }

    private static Map<String, String> parseRequestBody(HttpExchange exchange) throws IOException {
        InputStreamReader isr = new InputStreamReader(exchange.getRequestBody(), StandardCharsets.UTF_8);
        BufferedReader br = new BufferedReader(isr);
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            sb.append(line);
        }
        String body = sb.toString();

        Map<String, String> map = new HashMap<>();
        if (body.startsWith("{") && body.endsWith("}")) {
            // Basic JSON parse
            body = body.substring(1, body.length() - 1);
            String[] pairs = body.split(",(?=([^\"]*\"[^\"]*\")*[^\"]*$)");
            for (String pair : pairs) {
                String[] kv = pair.split(":", 2);
                if (kv.length == 2) {
                    String k = kv[0].trim().replaceAll("^\"|\"$", "");
                    String v = kv[1].trim().replaceAll("^\"|\"$", "");
                    map.put(k, v);
                }
            }
        } else {
            // URL Encoded parse
            String[] pairs = body.split("&");
            for (String pair : pairs) {
                String[] kv = pair.split("=");
                if (kv.length == 2) {
                    String k = URLDecoder.decode(kv[0], StandardCharsets.UTF_8);
                    String v = URLDecoder.decode(kv[1], StandardCharsets.UTF_8);
                    map.put(k, v);
                }
            }
        }
        return map;
    }

    private static String toJson(Appointment app) {
        StringBuilder addOnsJson = new StringBuilder("[");
        List<String> list = app.getAddOns();
        for (int i = 0; i < list.size(); i++) {
            addOnsJson.append("\"").append(escapeJson(list.get(i))).append("\"");
            if (i < list.size() - 1) addOnsJson.append(",");
        }
        addOnsJson.append("]");

        return String.format(
                "{\"appointmentNumber\":\"%s\", \"patient\":{\"patientId\":\"%s\", \"fullName\":\"%s\", \"address\":\"%s\", \"contactNumber\":\"%s\"}, \"dentistName\":\"%s\", \"treatmentType\":\"%s\", \"appointmentDate\":\"%s\", \"appointmentTime\":\"%s\", \"baseCost\":%.2f, \"consultationFee\":%.2f, \"addOns\":%s, \"totalCost\":%.2f, \"status\":\"%s\"}",
                app.getAppointmentNumber(),
                app.getPatient().getPatientId(),
                escapeJson(app.getPatient().getFullName()),
                escapeJson(app.getPatient().getAddress()),
                escapeJson(app.getPatient().getContactNumber()),
                escapeJson(app.getDentistName()),
                escapeJson(app.getTreatmentType()),
                app.getAppointmentDate(),
                app.getAppointmentTime(),
                app.getBaseCost(),
                app.getConsultationFee(),
                addOnsJson.toString(),
                app.getTotalCost(),
                app.getStatus()
        );
    }

    private static String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
