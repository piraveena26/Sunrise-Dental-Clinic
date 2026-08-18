package com.sunrisedental.dao;

import com.sunrisedental.config.DBConnectionManager;
import com.sunrisedental.model.User;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    /**
     * Authenticate User by Username, Password, and optional Role
     */
    public User authenticate(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            stmt.setString(2, password);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("password"),
                        rs.getString("full_name"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("role")
                    );
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[UserDAO] Authentication error for user: " + username, e);
        }
        return null;
    }

    /**
     * Register New Patient User & Patient Record
     */
    public boolean registerPatientUser(String username, String password, String fullName, String email, String phone, String nic, int age, String gender, String address) {
        String insertUserSql = "INSERT INTO users (username, password, full_name, email, phone, role) VALUES (?, ?, ?, ?, ?, 'PATIENT')";
        String insertPatientSql = "INSERT INTO patients (user_id, nic_passport, full_name, email, phone, age, gender, address) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnectionManager.getInstance().getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            int newUserId = 0;
            try (PreparedStatement stmtUser = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                stmtUser.setString(1, username);
                stmtUser.setString(2, password);
                stmtUser.setString(3, fullName);
                stmtUser.setString(4, email);
                stmtUser.setString(5, phone);
                stmtUser.executeUpdate();

                try (ResultSet rs = stmtUser.getGeneratedKeys()) {
                    if (rs.next()) {
                        newUserId = rs.getInt(1);
                    }
                }
            }

            try (PreparedStatement stmtPatient = conn.prepareStatement(insertPatientSql)) {
                stmtPatient.setInt(1, newUserId);
                stmtPatient.setString(2, nic);
                stmtPatient.setString(3, fullName);
                stmtPatient.setString(4, email);
                stmtPatient.setString(5, phone);
                stmtPatient.setInt(6, age);
                stmtPatient.setString(7, gender);
                stmtPatient.setString(8, address);
                stmtPatient.executeUpdate();
            }

            conn.commit(); // Commit Transaction
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            LOGGER.log(Level.SEVERE, "[UserDAO] Patient self-registration failed for: " + username, e);
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Close failed", ex); }
            }
        }
    }

    public boolean isUsernameTaken(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[UserDAO] Username check error", e);
        }
        return false;
    }
}
