package com.sunrisedental.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Model representing an Appointment in Sunrise Dental Clinic.
 * Constructed via the AppointmentBuilder (Builder Pattern) and holds all visit details.
 */
public class Appointment {
    private String appointmentNumber; // e.g., APT-1001
    private Patient patient;
    private String dentistName;
    private String treatmentType;
    private String appointmentDate; // YYYY-MM-DD
    private String appointmentTime; // HH:MM
    private double baseCost;
    private double consultationFee;
    private List<String> addOns;
    private double totalCost;
    private String status; // SCHEDULED, COMPLETED, CANCELLED

    // Constructor populated by AppointmentBuilder
    public Appointment(String appointmentNumber, Patient patient, String dentistName,
                       String treatmentType, String appointmentDate, String appointmentTime,
                       double baseCost, double consultationFee, List<String> addOns, double totalCost, String status) {
        this.appointmentNumber = appointmentNumber;
        this.patient = patient;
        this.dentistName = dentistName;
        this.treatmentType = treatmentType;
        this.appointmentDate = appointmentDate;
        this.appointmentTime = appointmentTime;
        this.baseCost = baseCost;
        this.consultationFee = consultationFee;
        this.addOns = (addOns != null) ? addOns : new ArrayList<>();
        this.totalCost = totalCost;
        this.status = (status != null) ? status : "SCHEDULED";
    }

    // Getters and Setters
    public String getAppointmentNumber() { return appointmentNumber; }
    public Patient getPatient() { return patient; }
    public String getDentistName() { return dentistName; }
    public String getTreatmentType() { return treatmentType; }
    public String getAppointmentDate() { return appointmentDate; }
    public String getAppointmentTime() { return appointmentTime; }
    public double getBaseCost() { return baseCost; }
    public double getConsultationFee() { return consultationFee; }
    public List<String> getAddOns() { return addOns; }
    public double getTotalCost() { return totalCost; }
    public String getStatus() { return status; }

    public void setStatus(String status) { this.status = status; }
    public void setTotalCost(double totalCost) { this.totalCost = totalCost; }
    public void setDentistName(String dentistName) { this.dentistName = dentistName; }
    public void setAppointmentDate(String date) { this.appointmentDate = date; }
    public void setAppointmentTime(String time) { this.appointmentTime = time; }

    /**
     * Create a clone copy for Memento snapshots
     */
    public Appointment copy() {
        Patient clonedPatient = new Patient(
                this.patient.getPatientId(),
                this.patient.getFullName(),
                this.patient.getAddress(),
                this.patient.getContactNumber()
        );
        return new Appointment(
                this.appointmentNumber,
                clonedPatient,
                this.dentistName,
                this.treatmentType,
                this.appointmentDate,
                this.appointmentTime,
                this.baseCost,
                this.consultationFee,
                new ArrayList<>(this.addOns),
                this.totalCost,
                this.status
        );
    }
}
