package com.sunrisedental.model;

/**
 * Model representing a Patient in Sunrise Dental Clinic.
 * Holds personal details such as ID, full name, address, and contact number.
 */
public class Patient {
    private String patientId;
    private String fullName;
    private String address;
    private String contactNumber;

    public Patient(String patientId, String fullName, String address, String contactNumber) {
        this.patientId = patientId;
        this.fullName = fullName;
        this.address = address;
        this.contactNumber = contactNumber;
    }

    // Getters and Setters
    public String getPatientId() { return patientId; }
    public void setPatientId(String patientId) { this.patientId = patientId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    @Override
    public String toString() {
        return "Patient{" +
                "patientId='" + patientId + '\'' +
                ", fullName='" + fullName + '\'' +
                ", contactNumber='" + contactNumber + '\'' +
                '}';
    }
}
