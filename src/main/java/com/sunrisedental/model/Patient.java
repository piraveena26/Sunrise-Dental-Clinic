package com.sunrisedental.model;

import java.io.Serializable;

/**
 * Model representing a Patient in Sunrise Dental Clinic.
 * Holds personal details such as ID, full name, address, contact number, NIC, age, and gender.
 */
public class Patient implements Serializable {
    private int id;
    private int userId;
    private String patientId; // e.g. P-101
    private String nicPassport;
    private String fullName;
    private String email;
    private String contactNumber;
    private int age;
    private String gender;
    private String address;
    private String medicalHistory;

    public Patient() {}

    // Legacy constructor (4 arguments) for backwards compatibility
    public Patient(String patientId, String fullName, String address, String contactNumber) {
        this.patientId = patientId;
        this.fullName = fullName;
        this.address = address;
        this.contactNumber = contactNumber;
    }

    // Full constructor for database mapping
    public Patient(int id, int userId, String patientId, String nicPassport, String fullName,
                   String email, String contactNumber, int age, String gender, String address, String medicalHistory) {
        this.id = id;
        this.userId = userId;
        this.patientId = patientId;
        this.nicPassport = nicPassport;
        this.fullName = fullName;
        this.email = email;
        this.contactNumber = contactNumber;
        this.age = age;
        this.gender = gender;
        this.address = address;
        this.medicalHistory = medicalHistory;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getPatientId() { return patientId != null ? patientId : "P-" + (id > 0 ? (100 + id) : "100"); }
    public void setPatientId(String patientId) { this.patientId = patientId; }

    public String getNicPassport() { return nicPassport; }
    public void setNicPassport(String nicPassport) { this.nicPassport = nicPassport; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getMedicalHistory() { return medicalHistory; }
    public void setMedicalHistory(String medicalHistory) { this.medicalHistory = medicalHistory; }

    @Override
    public String toString() {
        return "Patient{" +
                "patientId='" + patientId + '\'' +
                ", fullName='" + fullName + '\'' +
                ", nicPassport='" + nicPassport + '\'' +
                ", age=" + age +
                ", gender='" + gender + '\'' +
                ", contactNumber='" + contactNumber + '\'' +
                '}';
    }
}
