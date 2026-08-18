package com.sunrisedental.model;

import java.io.Serializable;

public class DoctorSchedule implements Serializable {
    private int id;
    private int doctorId;
    private String doctorName;
    private String unavailableDate; // 'YYYY-MM-DD'
    private String timeSlot; // 'ALL_DAY', '09:00', '10:30', '14:00', etc.
    private String reason;

    public DoctorSchedule() {}

    public DoctorSchedule(int id, int doctorId, String doctorName, String unavailableDate, String timeSlot, String reason) {
        this.id = id;
        this.doctorId = doctorId;
        this.doctorName = doctorName;
        this.unavailableDate = unavailableDate;
        this.timeSlot = timeSlot;
        this.reason = reason;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getDoctorId() { return doctorId; }
    public void setDoctorId(int doctorId) { this.doctorId = doctorId; }

    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }

    public String getUnavailableDate() { return unavailableDate; }
    public void setUnavailableDate(String unavailableDate) { this.unavailableDate = unavailableDate; }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
}
