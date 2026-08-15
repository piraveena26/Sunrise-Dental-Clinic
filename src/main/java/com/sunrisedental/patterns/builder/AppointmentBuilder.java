package com.sunrisedental.patterns.builder;

import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Patient;

import java.util.ArrayList;
import java.util.List;

/**
 * DESIGN PATTERN: BUILDER PATTERN (Creational)
 *
 * Why Builder Pattern?
 * Constructing an Appointment requires assembling complex nested patient details, dentist names,
 * treatment types, appointment schedules, consultation fees, base costs, and itemized add-on lists.
 * The Builder pattern provides a clear fluent interface, prevents telescoping constructors,
 * and ensures validation before building.
 */
public class AppointmentBuilder {
    private String appointmentNumber;
    private Patient patient;
    private String dentistName;
    private String treatmentType;
    private String appointmentDate;
    private String appointmentTime;
    private double baseCost;
    private double consultationFee = 1500.00; // Default consultation fee
    private List<String> addOns = new ArrayList<>();
    private double totalCost;
    private String status = "SCHEDULED";

    public AppointmentBuilder setAppointmentNumber(String appointmentNumber) {
        this.appointmentNumber = appointmentNumber;
        return this;
    }

    public AppointmentBuilder setPatient(Patient patient) {
        this.patient = patient;
        return this;
    }

    public AppointmentBuilder setPatientDetails(String patientId, String fullName, String address, String contactNumber) {
        this.patient = new Patient(patientId, fullName, address, contactNumber);
        return this;
    }

    public AppointmentBuilder setDentistName(String dentistName) {
        this.dentistName = dentistName;
        return this;
    }

    public AppointmentBuilder setTreatmentType(String treatmentType) {
        this.treatmentType = treatmentType;
        return this;
    }

    public AppointmentBuilder setAppointmentDate(String appointmentDate) {
        this.appointmentDate = appointmentDate;
        return this;
    }

    public AppointmentBuilder setAppointmentTime(String appointmentTime) {
        this.appointmentTime = appointmentTime;
        return this;
    }

    public AppointmentBuilder setBaseCost(double baseCost) {
        this.baseCost = baseCost;
        return this;
    }

    public AppointmentBuilder setConsultationFee(double consultationFee) {
        this.consultationFee = consultationFee;
        return this;
    }

    public AppointmentBuilder addAddOn(String addOnName) {
        if (addOnName != null && !addOnName.trim().isEmpty()) {
            this.addOns.add(addOnName);
        }
        return this;
    }

    public AppointmentBuilder setAddOns(List<String> addOns) {
        if (addOns != null) {
            this.addOns = new ArrayList<>(addOns);
        }
        return this;
    }

    public AppointmentBuilder setTotalCost(double totalCost) {
        this.totalCost = totalCost;
        return this;
    }

    public AppointmentBuilder setStatus(String status) {
        this.status = status;
        return this;
    }

    /**
     * Builds and validates the Appointment instance.
     */
    public Appointment build() {
        if (appointmentNumber == null || appointmentNumber.trim().isEmpty()) {
            // Auto-generate appointment number if missing
            this.appointmentNumber = "APT-" + (System.currentTimeMillis() % 1000000);
        }
        if (patient == null) {
            throw new IllegalStateException("Patient details must be set before building an Appointment.");
        }
        if (dentistName == null || dentistName.trim().isEmpty()) {
            throw new IllegalStateException("Dentist name is required.");
        }
        if (treatmentType == null || treatmentType.trim().isEmpty()) {
            throw new IllegalStateException("Treatment type is required.");
        }

        return new Appointment(
                appointmentNumber,
                patient,
                dentistName,
                treatmentType,
                appointmentDate,
                appointmentTime,
                baseCost,
                consultationFee,
                addOns,
                totalCost,
                status
        );
    }
}
