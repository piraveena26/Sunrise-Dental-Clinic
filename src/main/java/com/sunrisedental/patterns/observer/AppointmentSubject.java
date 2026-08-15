package com.sunrisedental.patterns.observer;

import com.sunrisedental.model.Appointment;

import java.util.ArrayList;
import java.util.List;

/**
 * DESIGN PATTERN: OBSERVER PATTERN (Behavioral)
 *
 * Why Observer Pattern?
 * To satisfy modern healthcare clinic requirements (e.g., Email alerts, SMS notifications,
 * and compliance audit logging), the system must notify multiple subsystems whenever an
 * appointment state changes.
 */

// Concrete Observer: Email Notification Service
class EmailNotificationObserver implements AppointmentObserver {
    private final List<String> dispatchedEmails = new ArrayList<>();

    @Override
    public void onAppointmentEvent(String eventType, Appointment appointment, String details) {
        String msg = String.format("EMAIL DISPATCHED to %s (%s): Dear %s, your appointment %s for %s on %s at %s is %s.",
                appointment.getPatient().getFullName().replaceAll(" ", ".").toLowerCase() + "@gmail.com",
                appointment.getPatient().getContactNumber(),
                appointment.getPatient().getFullName(),
                appointment.getAppointmentNumber(),
                appointment.getTreatmentType(),
                appointment.getAppointmentDate(),
                appointment.getAppointmentTime(),
                eventType.toLowerCase()
        );
        dispatchedEmails.add(msg);
        System.out.println("[Observer: Email] " + msg);
    }

    @Override
    public String getObserverName() { return "Email Notification Dispatcher"; }

    public List<String> getDispatchedEmails() { return dispatchedEmails; }
}

// Concrete Observer: SMS Notification Service
class SMSNotificationObserver implements AppointmentObserver {
    private final List<String> dispatchedSMS = new ArrayList<>();

    @Override
    public void onAppointmentEvent(String eventType, Appointment appointment, String details) {
        String sms = String.format("SMS DISPATCHED to %s: [Sunrise Dental] Appt %s confirmed with %s for %s @ %s.",
                appointment.getPatient().getContactNumber(),
                appointment.getAppointmentNumber(),
                appointment.getDentistName(),
                appointment.getAppointmentDate(),
                appointment.getAppointmentTime()
        );
        dispatchedSMS.add(sms);
        System.out.println("[Observer: SMS] " + sms);
    }

    @Override
    public String getObserverName() { return "SMS Gateway Dispatcher"; }

    public List<String> getDispatchedSMS() { return dispatchedSMS; }
}

// Concrete Observer: Audit Log Observer
class AuditLogObserver implements AppointmentObserver {
    @Override
    public void onAppointmentEvent(String eventType, Appointment appointment, String details) {
        String audit = String.format("AUDIT RECORD: Event=%s | Appt=%s | Patient=%s | Dentist=%s | Details=%s",
                eventType,
                appointment.getAppointmentNumber(),
                appointment.getPatient().getFullName(),
                appointment.getDentistName(),
                details
        );
        System.out.println("[Observer: Audit] " + audit);
    }

    @Override
    public String getObserverName() { return "System Audit Logger"; }
}

// Subject Class managing subscribers
public class AppointmentSubject {
    private final List<AppointmentObserver> observers = new ArrayList<>();
    private final List<String> liveNotificationLog = new ArrayList<>();

    public AppointmentSubject() {
        // Register default observers
        registerObserver(new EmailNotificationObserver());
        registerObserver(new SMSNotificationObserver());
        registerObserver(new AuditLogObserver());
    }

    public void registerObserver(AppointmentObserver observer) {
        observers.add(observer);
    }

    public void removeObserver(AppointmentObserver observer) {
        observers.remove(observer);
    }

    public void notifyObservers(String eventType, Appointment appointment, String details) {
        String timestamp = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
        String logHeader = String.format("[%s] Event: %s | Appt: %s | Patient: %s",
                timestamp, eventType, appointment.getAppointmentNumber(), appointment.getPatient().getFullName());
        liveNotificationLog.add(logHeader);

        for (AppointmentObserver observer : observers) {
            observer.onAppointmentEvent(eventType, appointment, details);
        }
    }

    public List<String> getLiveNotificationLog() {
        return new ArrayList<>(liveNotificationLog);
    }
}
