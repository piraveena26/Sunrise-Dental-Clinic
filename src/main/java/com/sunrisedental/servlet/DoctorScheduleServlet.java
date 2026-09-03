package com.sunrisedental.servlet;

import com.sunrisedental.dao.DoctorScheduleDAO;
import com.sunrisedental.model.DoctorSchedule;
import com.sunrisedental.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/doctor-schedule")
public class DoctorScheduleServlet extends HttpServlet {

    private final DoctorScheduleDAO scheduleDAO = new DoctorScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String doctorName = request.getParameter("doctorName");
        List<DoctorSchedule> schedules;
        if (doctorName != null && !doctorName.trim().isEmpty()) {
            schedules = scheduleDAO.getSchedulesByDoctorName(doctorName.trim());
        } else {
            schedules = scheduleDAO.getAllSchedules();
        }

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < schedules.size(); i++) {
            DoctorSchedule s = schedules.get(i);
            json.append("{")
                .append("\"id\":").append(s.getId()).append(",")
                .append("\"doctorId\":").append(s.getDoctorId()).append(",")
                .append("\"doctorName\":\"").append(escapeJson(s.getDoctorName())).append("\",")
                .append("\"unavailableDate\":\"").append(escapeJson(s.getUnavailableDate())).append("\",")
                .append("\"timeSlot\":\"").append(escapeJson(s.getTimeSlot())).append("\",")
                .append("\"reason\":\"").append(escapeJson(s.getReason())).append("\"")
                .append("}");
            if (i < schedules.size() - 1) json.append(",");
        }
        json.append("]");

        try (PrintWriter out = response.getWriter()) {
            out.print(json.toString());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || (!"DOCTOR".equalsIgnoreCase(user.getRole()) && !"ADMIN".equalsIgnoreCase(user.getRole()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only Doctors and Admins can schedule leave dates.");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equalsIgnoreCase(action)) {
            String doctorIdStr = request.getParameter("doctorId");
            String date = request.getParameter("unavailableDate");
            String timeSlot = request.getParameter("timeSlot");
            String reason = request.getParameter("reason");

            int doctorId = 1;
            try { doctorId = Integer.parseInt(doctorIdStr); } catch (NumberFormatException ignored) {}

            boolean success = scheduleDAO.addDoctorSchedule(doctorId, date, timeSlot != null ? timeSlot : "ALL_DAY", reason != null ? reason : "On Leave");
            if (success) {
                request.getSession(true).setAttribute("flashMessage", "Doctor leave / unavailability saved successfully!");
                request.getSession(true).setAttribute("flashType", "success");
                request.getSession(true).setAttribute("flashTitle", "Leave Saved");
                response.sendRedirect(request.getContextPath() + "/doctor-schedule.jsp");
            } else {
                request.getSession(true).setAttribute("flashMessage", "Failed to save doctor leave slot.");
                request.getSession(true).setAttribute("flashType", "error");
                request.getSession(true).setAttribute("flashTitle", "Error");
                response.sendRedirect(request.getContextPath() + "/doctor-schedule.jsp");
            }
        } else if ("delete".equalsIgnoreCase(action)) {
            String idStr = request.getParameter("id");
            int id = Integer.parseInt(idStr);
            scheduleDAO.removeDoctorSchedule(id);
            request.getSession(true).setAttribute("flashMessage", "Leave slot removed successfully.");
            request.getSession(true).setAttribute("flashType", "info");
            request.getSession(true).setAttribute("flashTitle", "Leave Removed");
            response.sendRedirect(request.getContextPath() + "/doctor-schedule.jsp");
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
