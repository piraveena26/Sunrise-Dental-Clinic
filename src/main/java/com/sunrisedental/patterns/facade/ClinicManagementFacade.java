package com.sunrisedental.patterns.facade;

import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Patient;
import com.sunrisedental.patterns.builder.AppointmentBuilder;
import com.sunrisedental.patterns.decorator.BillingCalculator;
import com.sunrisedental.patterns.decorator.ITreatmentCost;
import com.sunrisedental.patterns.factory.Treatment;
import com.sunrisedental.patterns.factory.TreatmentFactory;
import com.sunrisedental.patterns.memento.AppointmentCaretaker;
import com.sunrisedental.patterns.observer.AppointmentSubject;
import com.sunrisedental.repository.DatabaseConnectionManager;

import java.util.*;

/**
 * DESIGN PATTERN: FACADE PATTERN (Structural)
 *
 * Why Facade Pattern?
 * The Presentation Layer (Web REST Endpoints & UI controllers) needs to perform high-level operations
 * such as "Register Appointment", "Search Appointment", "Calculate Bill", "Undo Reschedule", or
 * "Generate Reports".
 * Doing this directly would require the UI to manually orchestrate Singleton DB connections, Factory
 * creation, Builder execution, Decorator bill calculation, Observer notifications, and Memento state saves.
 *
 * The ClinicManagementFacade provides a unified 3-Tier Business Logic entry point, insulating the
 * Presentation Tier from backend complexity.
 */
public class ClinicManagementFacade {

    private final DatabaseConnectionManager dbManager;
    private final AppointmentSubject notificationSubject;
    private final AppointmentCaretaker caretaker;

    public ClinicManagementFacade() {
        this.dbManager = DatabaseConnectionManager.getInstance();
        this.notificationSubject = new AppointmentSubject();
        this.caretaker = new AppointmentCaretaker();
    }

    /**
     * User Authentication with session simulation
     */
    public boolean authenticate(String username, String password) {
        if (username == null || password == null) return false;
        // Authorized staff credentials
        return (username.equalsIgnoreCase("admin") && password.equals("admin123")) ||
               (username.equalsIgnoreCase("receptionist") && password.equals("dental123")) ||
               (username.equalsIgnoreCase("dentist") && password.equals("dentist123"));
    }

    /**
     * Register New Appointment orchestrating Factory, Builder, Decorator, and Observer
     */
    public Appointment registerAppointment(String patientName, String address, String contactNumber,
                                           String dentistName, String treatmentType,
                                           String appointmentDate, String appointmentTime,
                                           List<String> addOns) {

        // 1. Factory Pattern: Instantiate Treatment base properties
        Treatment treatment = TreatmentFactory.createTreatment(treatmentType);

        // 2. Decorator Pattern: Calculate total price with add-ons & consultation fee
        double consultationFee = 1500.00;
        ITreatmentCost costCalculator = BillingCalculator.buildCostCalculator(
                treatment.getName(), treatment.getBasePrice(), consultationFee, addOns);
        double totalCost = costCalculator.calculateCost();

        // Auto-generate IDs
        String appointmentNumber = "APT-" + (1000 + dbManager.getAllAppointments().size() + 1);
        String patientId = "P-" + (100 + dbManager.getAllAppointments().size() + 1);

        // 3. Builder Pattern: Construct Appointment object
        Appointment appointment = new AppointmentBuilder()
                .setAppointmentNumber(appointmentNumber)
                .setPatientDetails(patientId, patientName, address, contactNumber)
                .setDentistName(dentistName)
                .setTreatmentType(treatment.getName())
                .setAppointmentDate(appointmentDate)
                .setAppointmentTime(appointmentTime)
                .setBaseCost(treatment.getBasePrice())
                .setConsultationFee(consultationFee)
                .setAddOns(addOns)
                .setTotalCost(totalCost)
                .setStatus("SCHEDULED")
                .build();

        // Save via Singleton Repository
        dbManager.saveAppointment(appointment);

        // 4. Observer Pattern: Notify subscribers (Email, SMS, Audit Logger)
        notificationSubject.notifyObservers("REGISTERED", appointment,
                "Treatment: " + treatment.getName() + " | Cost: LKR " + totalCost);

        return appointment;
    }

    /**
     * Search Appointment by Appointment Number
     */
    public Appointment getAppointmentDetails(String appointmentNumber) {
        if (appointmentNumber == null) return null;
        return dbManager.getAppointment(appointmentNumber.trim().toUpperCase());
    }

    /**
     * List all appointments
     */
    public List<Appointment> getAllAppointments() {
        return dbManager.getAllAppointments();
    }

    /**
     * Calculate Bill breakdown for an appointment (Decorator Pattern)
     */
    public ITreatmentCost calculateBillBreakdown(String appointmentNumber) {
        Appointment app = getAppointmentDetails(appointmentNumber);
        if (app == null) return null;

        return BillingCalculator.buildCostCalculator(
                app.getTreatmentType(),
                app.getBaseCost(),
                app.getConsultationFee(),
                app.getAddOns()
        );
    }

    /**
     * Update/Reschedule Appointment with Memento snapshot saving
     */
    public boolean updateAppointmentSchedule(String appointmentNumber, String newDentist, String newDate, String newTime) {
        Appointment app = getAppointmentDetails(appointmentNumber);
        if (app == null) return false;

        // 5. Memento Pattern: Save state snapshot before mutating
        caretaker.saveSnapshot(app);

        // Mutate fields
        app.setDentistName(newDentist);
        app.setAppointmentDate(newDate);
        app.setAppointmentTime(newTime);

        // Observer notification
        notificationSubject.notifyObservers("RESCHEDULED", app, "New Schedule: " + newDate + " @ " + newTime + " with " + newDentist);
        return true;
    }

    /**
     * Undo last edit (Memento Pattern)
     */
    public Appointment undoAppointmentEdit(String appointmentNumber) {
        Appointment current = getAppointmentDetails(appointmentNumber);
        if (current == null) return null;

        Appointment restored = caretaker.undo(current);
        if (restored != null) {
            dbManager.saveAppointment(restored);
            notificationSubject.notifyObservers("UNDO_RESTORED", restored, "Restored appointment to previous state.");
            return restored;
        }
        return null;
    }

    public boolean canUndo(String appointmentNumber) {
        return caretaker.canUndo(appointmentNumber);
    }

    /**
     * Get live notification logs dispatched via Observers
     */
    public List<String> getNotificationLogs() {
        return notificationSubject.getLiveNotificationLog();
    }

    /**
     * Get decision-making reports & analytics
     */
    public Map<String, Object> getDecisionMakingReports() {
        Map<String, Object> report = new HashMap<>();
        List<Appointment> all = getAllAppointments();

        double totalRevenue = 0.0;
        Map<String, Integer> treatmentCounts = new HashMap<>();
        Map<String, Integer> dentistWorkload = new HashMap<>();

        for (Appointment a : all) {
            totalRevenue += a.getTotalCost();
            treatmentCounts.put(a.getTreatmentType(), treatmentCounts.getOrDefault(a.getTreatmentType(), 0) + 1);
            dentistWorkload.put(a.getDentistName(), dentistWorkload.getOrDefault(a.getDentistName(), 0) + 1);
        }

        report.put("totalAppointments", all.size());
        report.put("totalRevenueLKR", totalRevenue);
        report.put("treatmentPopularity", treatmentCounts);
        report.put("dentistWorkload", dentistWorkload);
        return report;
    }
}
