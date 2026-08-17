package com.sunrisedental.servlet;

import com.sunrisedental.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String nic = request.getParameter("nic");
        String ageStr = request.getParameter("age");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");

        if (username == null || password == null || fullName == null || email == null || phone == null || nic == null || ageStr == null) {
            request.setAttribute("errorMessage", "All required registration fields must be filled out.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (userDAO.isUsernameTaken(username.trim())) {
            request.setAttribute("errorMessage", "Username '" + username + "' is already registered. Please choose another.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        int age = 25;
        try { age = Integer.parseInt(ageStr.trim()); } catch (NumberFormatException ignored) {}

        boolean success = userDAO.registerPatientUser(
            username.trim(),
            password.trim(),
            fullName.trim(),
            email.trim(),
            phone.trim(),
            nic.trim(),
            age,
            gender != null ? gender.trim() : "Other",
            address != null ? address.trim() : ""
        );

        if (success) {
            request.setAttribute("successMessage", "Registration Successful! Please log in with your new patient account.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Registration failed due to a database error. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }
}
