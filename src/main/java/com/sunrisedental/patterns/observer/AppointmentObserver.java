package com.sunrisedental.patterns.observer;

import com.sunrisedental.model.Appointment;

/**
 * Observer Interface for Appointment events.
 */
public interface AppointmentObserver {
    void onAppointmentEvent(String eventType, Appointment appointment, String details);
    String getObserverName();
}
