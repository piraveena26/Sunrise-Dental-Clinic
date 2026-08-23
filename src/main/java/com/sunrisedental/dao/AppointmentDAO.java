package com.sunrisedental.dao;

import com.sunrisedental.config.DBConnectionManager;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Patient;
import com.sunrisedental.repository.DatabaseConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AppointmentDAO {

    private static final Logger LOGGER = Logger.getLogger(AppointmentDAO.class.getName());

    /**
     * Save New Appointment to MySQL and in-memory Singleton repository
     */
    public boolean saveAppointment(String appointmentNumber, String patientName, String patientPhone,
                                   String patientEmail, String patientNic, int patientAge, String gender,
                                   String dentistName, String treatmentType, String appointmentDate,
                                   String appointmentTime, double baseFee, double totalFee,
                                   List<String> addOns, String status) {

        String sqlAppointment = "INSERT INTO appointments (appointment_number, patient_name, patient_phone, patient_email, patient_nic, patient_age, gender, dentist_name, treatment_type, appointment_date, appointment_time, base_fee, total_fee, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlAddon = "INSERT INTO appointment_addons (appointment_id, addon_name, addon_cost) VALUES (?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnectionManager.getInstance().getConnection();
            conn.setAutoCommit(false);

            int appointmentId = 0;
            try (PreparedStatement stmt = conn.prepareStatement(sqlAppointment, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, appointmentNumber);
                stmt.setString(2, patientName);
                stmt.setString(3, patientPhone);
                stmt.setString(4, patientEmail);
                stmt.setString(5, patientNic);
                stmt.setInt(6, patientAge);
                stmt.setString(7, gender);
                stmt.setString(8, dentistName);
                stmt.setString(9, treatmentType);
                stmt.setString(10, appointmentDate);
                stmt.setString(11, appointmentTime);
                stmt.setDouble(12, baseFee);
                stmt.setDouble(13, totalFee);
                stmt.setString(14, status != null ? status : "CONFIRMED");
                stmt.executeUpdate();

                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        appointmentId = rs.getInt(1);
                    }
                }
            }

            if (appointmentId > 0 && addOns != null && !addOns.isEmpty()) {
                try (PreparedStatement stmtAddon = conn.prepareStatement(sqlAddon)) {
                    for (String addon : addOns) {
                        stmtAddon.setInt(1, appointmentId);
                        stmtAddon.setString(2, addon);
                        stmtAddon.setDouble(3, 1000.00); // generic addon cost representation
                        stmtAddon.addBatch();
                    }
                    stmtAddon.executeBatch();
                }
            }

            conn.commit();

            // Sync to in-memory DatabaseConnectionManager for Facade & Observer compatibility
            Patient patient = new Patient(0, 0, "P-AUTO", patientNic, patientName, patientEmail, patientPhone, patientAge, gender, "", "");
            Appointment app = new Appointment(
                    appointmentNumber, patient, dentistName, treatmentType,
                    appointmentDate, appointmentTime, baseFee, 1500.0, addOns, totalFee, status
            );
            DatabaseConnectionManager.getInstance().saveAppointment(app);

            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            LOGGER.log(Level.SEVERE, "[AppointmentDAO] Save appointment failed for " + appointmentNumber, e);

            // Fallback: save to memory/file if MySQL is temporarily offline
            Patient patient = new Patient(0, 0, "P-AUTO", patientNic, patientName, patientEmail, patientPhone, patientAge, gender, "", "");
            Appointment app = new Appointment(
                    appointmentNumber, patient, dentistName, treatmentType,
                    appointmentDate, appointmentTime, baseFee, 1500.0, addOns, totalFee, status
            );
            DatabaseConnectionManager.getInstance().saveAppointment(app);
            return true;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Close failed", ex); }
            }
        }
    }

    /**
     * Retrieve all appointments (for Admin, Doctor, Cashier)
     */
    public List<Appointment> getAllAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, GROUP_CONCAT(ad.addon_name SEPARATOR ', ') AS addon_list " +
                "FROM appointments a " +
                "LEFT JOIN appointment_addons ad ON a.id = ad.appointment_id " +
                "GROUP BY a.id " +
                "ORDER BY a.appointment_date DESC, a.appointment_time DESC";

        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToAppointment(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.INFO, "[AppointmentDAO] MySQL lookup fallback to in-memory store: " + e.getMessage());
            return DatabaseConnectionManager.getInstance().getAllAppointments();
        }

        if (list.isEmpty()) {
            return DatabaseConnectionManager.getInstance().getAllAppointments();
        }
        return list;
    }

    /**
     * Retrieve appointments strictly belonging to a specific Patient
     */
    public List<Appointment> getAppointmentsForPatient(String email, String nic, String phone, String patientName) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, GROUP_CONCAT(ad.addon_name SEPARATOR ', ') AS addon_list " +
                "FROM appointments a " +
                "LEFT JOIN appointment_addons ad ON a.id = ad.appointment_id " +
                "WHERE (a.patient_email = ? AND a.patient_email != '') " +
                "   OR (a.patient_nic = ? AND a.patient_nic != '') " +
                "   OR (a.patient_phone = ? AND a.patient_phone != '') " +
                "   OR (LOWER(a.patient_name) = LOWER(?)) " +
                "GROUP BY a.id " +
                "ORDER BY a.appointment_date DESC, a.appointment_time DESC";

        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email != null ? email.trim() : "");
            stmt.setString(2, nic != null ? nic.trim() : "");
            stmt.setString(3, phone != null ? phone.trim() : "");
            stmt.setString(4, patientName != null ? patientName.trim() : "");

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAppointment(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.INFO, "[AppointmentDAO] Patient lookup fallback to memory filter: " + e.getMessage());
            List<Appointment> all = DatabaseConnectionManager.getInstance().getAllAppointments();
            for (Appointment a : all) {
                if (a.getPatient() != null) {
                    if ((email != null && email.equalsIgnoreCase(a.getPatient().getEmail())) ||
                        (phone != null && phone.equalsIgnoreCase(a.getPatient().getContactNumber())) ||
                        (patientName != null && patientName.equalsIgnoreCase(a.getPatient().getFullName()))) {
                        list.add(a);
                    }
                }
            }
        }
        return list;
    }

    /**
     * Retrieve single appointment by appointment number
     */
    public Appointment getAppointmentByNumber(String appointmentNumber) {
        String sql = "SELECT a.*, GROUP_CONCAT(ad.addon_name SEPARATOR ', ') AS addon_list " +
                "FROM appointments a " +
                "LEFT JOIN appointment_addons ad ON a.id = ad.appointment_id " +
                "WHERE a.appointment_number = ? " +
                "GROUP BY a.id";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, appointmentNumber);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAppointment(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[AppointmentDAO] Error fetching appointment " + appointmentNumber, e);
        }
        return DatabaseConnectionManager.getInstance().getAppointment(appointmentNumber);
    }

    /**
     * Cancel Appointment Status
     */
    public boolean cancelAppointment(String appointmentNumber) {
        String sql = "UPDATE appointments SET status = 'CANCELLED' WHERE appointment_number = ?";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, appointmentNumber);
            int rows = stmt.executeUpdate();
            
            // Sync memory store
            Appointment app = DatabaseConnectionManager.getInstance().getAppointment(appointmentNumber);
            if (app != null) {
                app.setStatus("CANCELLED");
            }
            return rows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[AppointmentDAO] Cancel appointment error for " + appointmentNumber, e);
            Appointment app = DatabaseConnectionManager.getInstance().getAppointment(appointmentNumber);
            if (app != null) {
                app.setStatus("CANCELLED");
                return true;
            }
            return false;
        }
    }

    private Appointment mapResultSetToAppointment(ResultSet rs) throws SQLException {
        String aptNo = rs.getString("appointment_number");
        String name = rs.getString("patient_name");
        String phone = rs.getString("patient_phone");
        String email = rs.getString("patient_email");
        String nic = rs.getString("patient_nic");
        int age = rs.getInt("patient_age");
        String gender = rs.getString("gender");
        String dentist = rs.getString("dentist_name");
        String treatment = rs.getString("treatment_type");
        String date = rs.getString("appointment_date");
        String time = rs.getString("appointment_time");
        double baseFee = rs.getDouble("base_fee");
        double totalFee = rs.getDouble("total_fee");
        String status = rs.getString("status");
        String addonStr = rs.getString("addon_list");

        List<String> addons = new ArrayList<>();
        if (addonStr != null && !addonStr.isEmpty()) {
            for (String a : addonStr.split(",")) {
                addons.add(a.trim());
            }
        }

        Patient patient = new Patient(0, 0, "P-AUTO", nic, name, email, phone, age, gender, "", "");
        return new Appointment(aptNo, patient, dentist, treatment, date, time, baseFee, 1500.0, addons, totalFee, status);
    }
}
