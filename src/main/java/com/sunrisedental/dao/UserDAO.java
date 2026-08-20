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

    /**
     * Fetch Patient profile associated with a User ID
     */
    public com.sunrisedental.model.Patient getPatientByUserId(int userId) {
        String sql = "SELECT * FROM patients WHERE user_id = ?";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToPatient(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[UserDAO] Error retrieving patient by user_id: " + userId, e);
        }
        return null;
    }

    /**
     * Fetch Patient profile by username
     */
    public com.sunrisedental.model.Patient getPatientByUsername(String username) {
        String sql = "SELECT p.* FROM patients p JOIN users u ON p.user_id = u.id WHERE u.username = ?";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToPatient(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[UserDAO] Error retrieving patient by username: " + username, e);
        }
        return null;
    }

    /**
     * Fetch Patient profile by email or phone
     */
    public com.sunrisedental.model.Patient getPatientByEmailOrPhone(String email, String phone) {
        String sql = "SELECT * FROM patients WHERE (email = ? AND email IS NOT NULL AND email != '') OR (phone = ? AND phone IS NOT NULL AND phone != '')";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email != null ? email : "");
            stmt.setString(2, phone != null ? phone : "");
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToPatient(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[UserDAO] Error retrieving patient by email/phone", e);
        }
        return null;
    }

    private com.sunrisedental.model.Patient mapResultSetToPatient(ResultSet rs) throws SQLException {
        int id = rs.getInt("id");
        int userId = rs.getInt("user_id");
        String nic = rs.getString("nic_passport");
        String name = rs.getString("full_name");
        String email = rs.getString("email");
        String phone = rs.getString("phone");
        int age = rs.getInt("age");
        String gender = rs.getString("gender");
        String address = rs.getString("address");
        String medical = rs.getString("medical_history");
        String pId = "P-" + (100 + id);

        return new com.sunrisedental.model.Patient(id, userId, pId, nic, name, email, phone, age, gender, address, medical);
    }
}
