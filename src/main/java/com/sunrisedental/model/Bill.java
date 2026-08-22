package com.sunrisedental.model;

/**
 * Model representing an Invoice / Bill in Sunrise Dental Clinic.
 * Corresponds to the `bills` table in MySQL.
 */
public class Bill {
    private int id;
    private String invoiceNumber;
    private int appointmentId;
    private String appointmentNumber;
    private String patientName;
    private String treatmentType;
    private double treatmentFee;
    private double addonsFee;
    private double registrationFee;
    private double taxAmount;
    private double grandTotal;
    private String paymentStatus; // UNPAID, PAID
    private String paymentMethod; // Cash, Card, QR Code (LankaQR)
    private String createdAt;

    public Bill() {}

    public Bill(int id, String invoiceNumber, int appointmentId, String appointmentNumber,
                String patientName, String treatmentType, double treatmentFee, double addonsFee,
                double registrationFee, double taxAmount, double grandTotal,
                String paymentStatus, String paymentMethod, String createdAt) {
        this.id = id;
        this.invoiceNumber = invoiceNumber;
        this.appointmentId = appointmentId;
        this.appointmentNumber = appointmentNumber;
        this.patientName = patientName;
        this.treatmentType = treatmentType;
        this.treatmentFee = treatmentFee;
        this.addonsFee = addonsFee;
        this.registrationFee = registrationFee;
        this.taxAmount = taxAmount;
        this.grandTotal = grandTotal;
        this.paymentStatus = paymentStatus != null ? paymentStatus : "UNPAID";
        this.paymentMethod = paymentMethod != null ? paymentMethod : "Cash";
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getInvoiceNumber() { return invoiceNumber; }
    public void setInvoiceNumber(String invoiceNumber) { this.invoiceNumber = invoiceNumber; }

    public int getAppointmentId() { return appointmentId; }
    public void setAppointmentId(int appointmentId) { this.appointmentId = appointmentId; }

    public String getAppointmentNumber() { return appointmentNumber; }
    public void setAppointmentNumber(String appointmentNumber) { this.appointmentNumber = appointmentNumber; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getTreatmentType() { return treatmentType; }
    public void setTreatmentType(String treatmentType) { this.treatmentType = treatmentType; }

    public double getTreatmentFee() { return treatmentFee; }
    public void setTreatmentFee(double treatmentFee) { this.treatmentFee = treatmentFee; }

    public double getAddonsFee() { return addonsFee; }
    public void setAddonsFee(double addonsFee) { this.addonsFee = addonsFee; }

    public double getRegistrationFee() { return registrationFee; }
    public void setRegistrationFee(double registrationFee) { this.registrationFee = registrationFee; }

    public double getTaxAmount() { return taxAmount; }
    public void setTaxAmount(double taxAmount) { this.taxAmount = taxAmount; }

    public double getGrandTotal() { return grandTotal; }
    public void setGrandTotal(double grandTotal) { this.grandTotal = grandTotal; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
