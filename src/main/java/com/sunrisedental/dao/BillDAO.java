package com.sunrisedental.dao;

import com.sunrisedental.config.DBConnectionManager;
import com.sunrisedental.model.Bill;
import com.sunrisedental.patterns.observer.AppointmentSubject;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class BillDAO {

    private static final Logger LOGGER = Logger.getLogger(BillDAO.class.getName());

    /**
     * Retrieve all bills from the MySQL database.
     * Auto-syncs any appointments that don't have a bill yet.
     */
    public List<Bill> getAllBills() {
        syncAppointmentsToBills();
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT b.*, a.treatment_type FROM bills b " +
                     "LEFT JOIN appointments a ON b.appointment_id = a.id OR b.appointment_number = a.appointment_number " +
                     "ORDER BY b.id DESC";

        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                String treatment = rs.getString("treatment_type");
                if (treatment == null || treatment.isEmpty()) {
                    treatment = "Dental Treatment";
                }
                Bill bill = new Bill(
                    rs.getInt("id"),
                    rs.getString("invoice_number"),
                    rs.getInt("appointment_id"),
                    rs.getString("appointment_number"),
                    rs.getString("patient_name"),
                    treatment,
                    rs.getDouble("treatment_fee"),
                    rs.getDouble("addons_fee"),
                    rs.getDouble("registration_fee"),
                    rs.getDouble("tax_amount"),
                    rs.getDouble("grand_total"),
                    rs.getString("payment_status"),
                    rs.getString("payment_method"),
                    rs.getString("created_at")
                );
                list.add(bill);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[BillDAO] Error fetching bills from database", e);
        }
        return list;
    }

    /**
     * Get a single bill by invoice number
     */
    public Bill getBillByInvoiceNumber(String invoiceNumber) {
        String sql = "SELECT b.*, a.treatment_type FROM bills b " +
                     "LEFT JOIN appointments a ON b.appointment_id = a.id OR b.appointment_number = a.appointment_number " +
                     "WHERE b.invoice_number = ?";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, invoiceNumber);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String treatment = rs.getString("treatment_type");
                    if (treatment == null || treatment.isEmpty()) {
                        treatment = "Dental Treatment";
                    }
                    return new Bill(
                        rs.getInt("id"),
                        rs.getString("invoice_number"),
                        rs.getInt("appointment_id"),
                        rs.getString("appointment_number"),
                        rs.getString("patient_name"),
                        treatment,
                        rs.getDouble("treatment_fee"),
                        rs.getDouble("addons_fee"),
                        rs.getDouble("registration_fee"),
                        rs.getDouble("tax_amount"),
                        rs.getDouble("grand_total"),
                        rs.getString("payment_status"),
                        rs.getString("payment_method"),
                        rs.getString("created_at")
                    );
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[BillDAO] Error fetching bill " + invoiceNumber, e);
        }
        return null;
    }

    /**
     * Cashier approval method:
     * 1. Marks bill as PAID with specific payment method (Cash, Card, QR Payment)
     * 2. Updates appointment status to COMPLETED
     * 3. Inserts an audit log entry in audit_logs table
     */
    public boolean approvePayment(String invoiceNumber, String appointmentNumber, String paymentMethod, String cashierName) {
        String updateBillSql = "UPDATE bills SET payment_status = 'PAID', payment_method = ? WHERE invoice_number = ? OR appointment_number = ?";
        String updateApptSql = "UPDATE appointments SET status = 'COMPLETED' WHERE appointment_number = ?";
        String auditSql = "INSERT INTO audit_logs (event_type, appointment_number, description) VALUES ('PAYMENT_APPROVED', ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnectionManager.getInstance().getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement stmtBill = conn.prepareStatement(updateBillSql)) {
                stmtBill.setString(1, paymentMethod != null ? paymentMethod : "Cash");
                stmtBill.setString(2, invoiceNumber != null ? invoiceNumber : "");
                stmtBill.setString(3, appointmentNumber != null ? appointmentNumber : "");
                stmtBill.executeUpdate();
            }

            if (appointmentNumber != null && !appointmentNumber.isEmpty()) {
                try (PreparedStatement stmtAppt = conn.prepareStatement(updateApptSql)) {
                    stmtAppt.setString(1, appointmentNumber);
                    stmtAppt.executeUpdate();
                }
            }

            // Insert into audit_logs table
            String logDesc = String.format("Payment approved for Invoice %s (Appt: %s) via %s by Cashier %s.",
                    invoiceNumber, appointmentNumber, paymentMethod, cashierName != null ? cashierName : "Cashier");
            try (PreparedStatement stmtAudit = conn.prepareStatement(auditSql)) {
                stmtAudit.setString(1, appointmentNumber != null ? appointmentNumber : "SYSTEM");
                stmtAudit.setString(2, logDesc);
                stmtAudit.executeUpdate();
            }

            conn.commit();
            LOGGER.info("[BillDAO] " + logDesc);
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "[BillDAO] Failed to approve payment for " + invoiceNumber, e);
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Create a new Bill row for an appointment
     */
    public boolean createBill(int appointmentId, String appointmentNumber, String patientName,
                              double treatmentFee, double addonsFee, double grandTotal) {
        String invoiceNumber = "INV-" + (5000 + appointmentId);
        String sql = "INSERT INTO bills (invoice_number, appointment_id, appointment_number, patient_name, treatment_fee, addons_fee, registration_fee, tax_amount, grand_total, payment_status, payment_method) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 500.00, 0.00, ?, 'UNPAID', 'Cash') " +
                     "ON DUPLICATE KEY UPDATE grand_total = VALUES(grand_total)";
        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, invoiceNumber);
            stmt.setInt(2, appointmentId);
            stmt.setString(3, appointmentNumber);
            stmt.setString(4, patientName);
            stmt.setDouble(5, treatmentFee);
            stmt.setDouble(6, addonsFee);
            stmt.setDouble(7, grandTotal);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[BillDAO] Failed to create bill for " + appointmentNumber, e);
            return false;
        }
    }

    /**
     * Automatically sync any appointments in MySQL that are missing a row in `bills`
     */
    private void syncAppointmentsToBills() {
        String selectSql = "SELECT a.id, a.appointment_number, a.patient_name, a.base_fee, a.total_fee, a.status " +
                           "FROM appointments a " +
                           "LEFT JOIN bills b ON a.id = b.appointment_id " +
                           "WHERE b.id IS NULL";

        String insertSql = "INSERT INTO bills (invoice_number, appointment_id, appointment_number, patient_name, treatment_fee, addons_fee, registration_fee, tax_amount, grand_total, payment_status, payment_method) " +
                           "VALUES (?, ?, ?, ?, ?, ?, 500.00, 0.00, ?, ?, 'Cash')";

        try (Connection conn = DBConnectionManager.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(selectSql)) {

            List<BillSyncItem> items = new ArrayList<>();
            while (rs.next()) {
                items.add(new BillSyncItem(
                    rs.getInt("id"),
                    rs.getString("appointment_number"),
                    rs.getString("patient_name"),
                    rs.getDouble("base_fee"),
                    rs.getDouble("total_fee"),
                    rs.getString("status")
                ));
            }

            if (!items.isEmpty()) {
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    for (BillSyncItem item : items) {
                        String invNo = "INV-" + (5000 + item.id);
                        double addons = Math.max(0, item.totalFee - item.baseFee);
                        double grandTotal = item.totalFee + 500.00;
                        String payStatus = "COMPLETED".equalsIgnoreCase(item.status) ? "PAID" : "UNPAID";

                        insertStmt.setString(1, invNo);
                        insertStmt.setInt(2, item.id);
                        insertStmt.setString(3, item.apptNo);
                        insertStmt.setString(4, item.patientName);
                        insertStmt.setDouble(5, item.baseFee);
                        insertStmt.setDouble(6, addons);
                        insertStmt.setDouble(7, grandTotal);
                        insertStmt.setString(8, payStatus);
                        insertStmt.addBatch();
                    }
                    insertStmt.executeBatch();
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.INFO, "[BillDAO] Sync check: " + e.getMessage());
        }
    }

    private static class BillSyncItem {
        int id;
        String apptNo;
        String patientName;
        double baseFee;
        double totalFee;
        String status;

        BillSyncItem(int id, String apptNo, String patientName, double baseFee, double totalFee, String status) {
            this.id = id;
            this.apptNo = apptNo;
            this.patientName = patientName;
            this.baseFee = baseFee;
            this.totalFee = totalFee;
            this.status = status;
        }
    }
}
