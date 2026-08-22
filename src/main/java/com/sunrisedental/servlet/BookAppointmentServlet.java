package com.sunrisedental.servlet;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Patient;
import com.sunrisedental.patterns.observer.AppointmentSubject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet("/book-appointment")
public class BookAppointmentServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final com.sunrisedental.dao.BillDAO billDAO = new com.sunrisedental.dao.BillDAO();
    private final AppointmentSubject appointmentSubject = new AppointmentSubject();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String patientName = request.getParameter("patientName");
        String patientPhone = request.getParameter("patientPhone");
        String patientEmail = request.getParameter("patientEmail");
        String patientNic = request.getParameter("patientNic");
        String patientAgeStr = request.getParameter("patientAge");
        String patientGender = request.getParameter("patientGender");
        String dentistName = request.getParameter("dentistName");
        String treatmentType = request.getParameter("treatmentType");
        String appointmentDate = request.getParameter("appointmentDate");
        String appointmentTime = request.getParameter("appointmentTime");
        String baseCostStr = request.getParameter("baseCost");
        String totalCostStr = request.getParameter("totalCost");
        String[] addOnsArray = request.getParameterValues("addOns");

        int patientAge = 25;
        try {
            if (patientAgeStr != null && !patientAgeStr.trim().isEmpty()) {
                patientAge = Integer.parseInt(patientAgeStr.trim());
            }
        } catch (NumberFormatException ignored) {}

        double baseCost = 3000.0;
        try {
            if (baseCostStr != null && !baseCostStr.trim().isEmpty()) {
                baseCost = Double.parseDouble(baseCostStr.trim());
            }
        } catch (NumberFormatException ignored) {}

        double totalCost = baseCost;
        try {
            if (totalCostStr != null && !totalCostStr.trim().isEmpty()) {
                totalCost = Double.parseDouble(totalCostStr.trim());
            }
        } catch (NumberFormatException ignored) {}

        List<String> addOns = new ArrayList<>();
        if (addOnsArray != null) {
            addOns.addAll(Arrays.asList(addOnsArray));
        }

        // Generate unique appointment number
        String aptNo = "APT-" + (System.currentTimeMillis() % 9000 + 1000);

        boolean success = appointmentDAO.saveAppointment(
                aptNo,
                patientName != null ? patientName.trim() : "",
                patientPhone != null ? patientPhone.trim() : "",
                patientEmail != null ? patientEmail.trim() : "",
                patientNic != null ? patientNic.trim() : "",
                patientAge,
                patientGender != null ? patientGender.trim() : "Other",
                dentistName != null ? dentistName.trim() : "",
                treatmentType != null ? treatmentType.trim() : "",
                appointmentDate != null ? appointmentDate.trim() : "",
                appointmentTime != null ? appointmentTime.trim() : "",
                baseCost,
                totalCost,
                addOns,
                "CONFIRMED"
        );

        if (success) {
            Patient p = new Patient(0, 0, "P-AUTO", patientNic, patientName, patientEmail, patientPhone, patientAge, patientGender, "", "");
            Appointment app = new Appointment(aptNo, p, dentistName, treatmentType, appointmentDate, appointmentTime, baseCost, 1500.0, addOns, totalCost, "CONFIRMED");
            
            // Observer notifications (Email, SMS, Audit)
            appointmentSubject.notifyObservers("REGISTERED", app, "Treatment: " + treatmentType + " | Cost: LKR " + totalCost);
        }

        // Check if AJAX request
        String acceptHeader = request.getHeader("Accept");
        if (acceptHeader != null && acceptHeader.contains("application/json")) {
            response.setContentType("application/json;charset=UTF-8");
            if (success) {
                response.getWriter().write(String.format("{\"success\":true, \"appointmentNumber\":\"%s\", \"dentist\":\"%s\", \"dateTime\":\"%s @ %s\"}", aptNo, dentistName, appointmentDate, appointmentTime));
            } else {
                response.getWriter().write("{\"success\":false, \"message\":\"Failed to save appointment.\"}");
            }
            return;
        }

        response.sendRedirect(request.getContextPath() + "/appointment-details.jsp");
    }
}
