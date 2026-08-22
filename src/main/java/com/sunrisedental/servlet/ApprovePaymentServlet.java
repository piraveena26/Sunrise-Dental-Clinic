package com.sunrisedental.servlet;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.BillDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.User;
import com.sunrisedental.patterns.observer.AppointmentSubject;
import com.sunrisedental.repository.DatabaseConnectionManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/approve-payment")
public class ApprovePaymentServlet extends HttpServlet {

    private final BillDAO billDAO = new BillDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final AppointmentSubject appointmentSubject = new AppointmentSubject();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;

        // Security check: Only Cashier or Admin can approve payments
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false, \"message\":\"Unauthorized. Please log in.\"}");
            return;
        }

        String role = currentUser.getRole();
        if (!"CASHIER".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"success\":false, \"message\":\"Access denied. Only Cashiers or Admins can approve payments.\"}");
            return;
        }

        String invoiceNumber = request.getParameter("invoiceNumber");
        String appointmentNumber = request.getParameter("appointmentNumber");
        String paymentMethod = request.getParameter("paymentMethod");

        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "Cash";
        }

        boolean success = billDAO.approvePayment(
                invoiceNumber,
                appointmentNumber,
                paymentMethod,
                currentUser.getFullName()
        );

        if (success) {
            // Update in-memory appointment status if exists
            Appointment app = DatabaseConnectionManager.getInstance().getAppointment(appointmentNumber);
            if (app != null) {
                app.setStatus("COMPLETED");
                appointmentSubject.notifyObservers("PAYMENT_APPROVED", app,
                        "Payment approved via " + paymentMethod + " by Cashier " + currentUser.getFullName());
            }

            response.getWriter().write(String.format(
                "{\"success\":true, \"message\":\"Payment for %s approved via %s successfully!\", \"invoiceNumber\":\"%s\", \"paymentMethod\":\"%s\"}",
                invoiceNumber != null ? invoiceNumber : appointmentNumber,
                paymentMethod,
                invoiceNumber,
                paymentMethod
            ));
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false, \"message\":\"Failed to record payment in the database.\"}");
        }
    }
}
