package com.sunrisedental.servlet;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.patterns.observer.AppointmentSubject;
import com.sunrisedental.repository.DatabaseConnectionManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/cancel-appointment")
public class CancelAppointmentServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final AppointmentSubject appointmentSubject = new AppointmentSubject();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String appointmentNumber = request.getParameter("appointmentNumber");
        boolean success = false;
        if (appointmentNumber != null && !appointmentNumber.trim().isEmpty()) {
            success = appointmentDAO.cancelAppointment(appointmentNumber.trim());
            if (success) {
                Appointment app = DatabaseConnectionManager.getInstance().getAppointment(appointmentNumber.trim());
                if (app != null) {
                    appointmentSubject.notifyObservers("CANCELLED", app, "Appointment " + appointmentNumber + " was cancelled by user.");
                }
            }
        }

        String acceptHeader = request.getHeader("Accept");
        if (acceptHeader != null && acceptHeader.contains("application/json")) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write(String.format("{\"success\":%b, \"appointmentNumber\":\"%s\"}", success, appointmentNumber));
            return;
        }

        response.sendRedirect(request.getContextPath() + "/appointment-details.jsp");
    }
}
