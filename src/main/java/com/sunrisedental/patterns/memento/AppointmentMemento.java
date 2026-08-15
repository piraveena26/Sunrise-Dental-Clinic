package com.sunrisedental.patterns.memento;

import com.sunrisedental.model.Appointment;

/**
 * DESIGN PATTERN: MEMENTO PATTERN (Behavioral)
 *
 * Why Memento Pattern?
 * Clinic staff frequently make edits to appointments (e.g., changing dentist name, date, or time).
 * The Memento pattern enables capturing the complete snapshot state of an Appointment before an edit
 * occurs, storing it in a Caretaker history stack, and restoring the appointment to its previous state
 * if an edit error is made.
 */

// Memento Object holding state snapshot
public class AppointmentMemento {
    private final Appointment stateSnapshot;
    private final String timestamp;

    public AppointmentMemento(Appointment appointment) {
        this.stateSnapshot = appointment.copy(); // Deep copy snapshot
        this.timestamp = new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date());
    }

    public Appointment getSavedState() {
        return stateSnapshot.copy();
    }

    public String getTimestamp() {
        return timestamp;
    }
}
