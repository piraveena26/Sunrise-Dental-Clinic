package com.sunrisedental.dao;

import com.sunrisedental.config.DBConnectionManager;
import com.sunrisedental.model.DoctorSchedule;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DoctorScheduleDAO {
    private static final Logger LOGGER = Logger.getLogger(DoctorScheduleDAO.class.getName());

    public List<DoctorSchedule> getAllSchedules() {
        List<DoctorSchedule> list = new ArrayList<>();
        String sql = "SELECT s.*, d.name AS doctor_name FROM doctor_schedules s JOIN doctors d ON s.doctor_id = d.id ORDER BY s.unavailable_date ASC";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                list.add(new DoctorSchedule(
                    rs.getInt("id"),
                    rs.getInt("doctor_id"),
                    rs.getString("doctor_name"),
                    rs.getString("unavailable_date"),
                    rs.getString("time_slot"),
                    rs.getString("reason")
                ));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[DoctorScheduleDAO] Error fetching doctor schedules", e);
        }
        return list;
    }

    public List<DoctorSchedule> getSchedulesByDoctorName(String doctorName) {
        List<DoctorSchedule> list = new ArrayList<>();
        String sql = "SELECT s.*, d.name AS doctor_name FROM doctor_schedules s JOIN doctors d ON s.doctor_id = d.id WHERE d.name LIKE ? ORDER BY s.unavailable_date ASC";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + doctorName + "%");
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new DoctorSchedule(
                        rs.getInt("id"),
                        rs.getInt("doctor_id"),
                        rs.getString("doctor_name"),
                        rs.getString("unavailable_date"),
                        rs.getString("time_slot"),
                        rs.getString("reason")
                    ));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[DoctorScheduleDAO] Error fetching schedules by doctor name", e);
        }
        return list;
    }

    public boolean addDoctorSchedule(int doctorId, String unavailableDate, String timeSlot, String reason) {
        String sql = "INSERT INTO doctor_schedules (doctor_id, unavailable_date, time_slot, reason) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            stmt.setString(2, unavailableDate);
            stmt.setString(3, timeSlot);
            stmt.setString(4, reason);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[DoctorScheduleDAO] Error adding doctor schedule", e);
            return false;
        }
    }

    public boolean removeDoctorSchedule(int scheduleId) {
        String sql = "DELETE FROM doctor_schedules WHERE id = ?";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, scheduleId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[DoctorScheduleDAO] Error removing schedule: " + scheduleId, e);
            return false;
        }
    }

    /**
     * Check if a doctor is unavailable on a specific date & time slot
     */
    public boolean isDoctorUnavailable(String dentistName, String date, String timeSlot) {
        String sql = "SELECT COUNT(*) FROM doctor_schedules s JOIN doctors d ON s.doctor_id = d.id " +
                     "WHERE d.name = ? AND s.unavailable_date = ? AND (s.time_slot = 'ALL_DAY' OR s.time_slot = ?)";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, dentistName);
            stmt.setString(2, date);
            stmt.setString(3, timeSlot);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[DoctorScheduleDAO] Error checking unavailability", e);
        }
        return false;
    }

    /**
     * Retrieve all active Doctors dynamically from the MySQL Database
     */
    public List<com.sunrisedental.model.Doctor> getAllDoctors() {
        List<com.sunrisedental.model.Doctor> list = new ArrayList<>();
        String sql = "SELECT * FROM doctors ORDER BY name ASC";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                list.add(new com.sunrisedental.model.Doctor(
                    rs.getInt("id"),
                    rs.getInt("user_id"),
                    rs.getString("name"),
                    rs.getString("specialization"),
                    rs.getString("phone"),
                    rs.getString("email")
                ));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.INFO, "[DoctorScheduleDAO] Doctors query fallback: " + e.getMessage());
        }

        // Fallback default list if database is empty or offline
        if (list.isEmpty()) {
            list.add(new com.sunrisedental.model.Doctor(1, 2, "Dr. Chaminda Silva", "General & Cosmetic Dentistry", "+94771112233", "chaminda@sunrisedental.com"));
            list.add(new com.sunrisedental.model.Doctor(2, 3, "Dr. Nimali Fernando", "Orthodontics & Root Canal Specialist", "+94772223344", "nimali@sunrisedental.com"));
        }
        return list;
    }
}
