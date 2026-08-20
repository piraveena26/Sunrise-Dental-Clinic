package com.sunrisedental.model;

import java.io.Serializable;

public class Doctor implements Serializable {
    private int id;
    private int userId;
    private String name;
    private String specialization;
    private String phone;
    private String email;

    public Doctor() {}

    public Doctor(int id, int userId, String name, String specialization, String phone, String email) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.specialization = specialization;
        this.phone = phone;
        this.email = email;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
