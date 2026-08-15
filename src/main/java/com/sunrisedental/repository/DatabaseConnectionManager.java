package com.sunrisedental.repository;

import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Patient;

import java.io.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * DESIGN PATTERN: SINGLETON PATTERN (Creational)
 *
 * Why Singleton?
 * Ensures that exactly ONE instance of DatabaseConnectionManager manages database pool state,
 * text file synchronization, and in-memory caching across the entire 3-Tier application.
 * Prevents race conditions and duplicate connection allocations.
 */
public class DatabaseConnectionManager {
    private static volatile DatabaseConnectionManager instance;
    
    // In-memory data store for quick access and text-file persistence
    private final Map<String, Appointment> appointmentStore = new ConcurrentHashMap<>();
    private final Map<String, Patient> patientStore = new ConcurrentHashMap<>();
    private final List<String> auditLogStore = Collections.synchronizedList(new ArrayList<>());
    
    private final String dataDir = "data";
    private final String appointmentsFile = "data/appointments.txt";
    private final String auditFile = "data/audit_logs.txt";

    // Private constructor prevents direct instantiation
    private DatabaseConnectionManager() {
        initFileStorage();
        seedInitialData();
    }

    /**
     * Double-checked locking thread-safe Singleton getInstance method
     */
    public static DatabaseConnectionManager getInstance() {
        if (instance == null) {
            synchronized (DatabaseConnectionManager.class) {
                if (instance == null) {
                    instance = new DatabaseConnectionManager();
                }
            }
        }
        return instance;
    }

    private void initFileStorage() {
        File dir = new File(dataDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }

    private void seedInitialData() {
        // Seed initial sample data for Sunrise Dental Clinic
        Patient p1 = new Patient("P-101", "Kavindu Perera", "14/2 Galle Road, Colombo 03", "+94 77 123 4567");
        Patient p2 = new Patient("P-102", "Nimali Fernando", "45 Kandy Road, Kiribathgoda", "+94 71 987 6543");
        Patient p3 = new Patient("P-103", "Anura Jayasinghe", "88 Station Road, Bambalapitiya", "+94 76 555 1234");
        
        patientStore.put(p1.getPatientId(), p1);
        patientStore.put(p2.getPatientId(), p2);
        patientStore.put(p3.getPatientId(), p3);

        Appointment a1 = new Appointment("APT-1001", p1, "Dr. Chaminda Silva", "Routine Checkup", "2026-08-11", "09:30", 2500.00, 1500.00, Arrays.asList("X-Ray"), 4500.00, "SCHEDULED");
        Appointment a2 = new Appointment("APT-1002", p2, "Dr. Dilhani Wickramasinghe", "Teeth Whitening", "2026-08-11", "11:00", 15000.00, 1500.00, Arrays.asList("Fluoride Treatment"), 17700.00, "COMPLETED");
        Appointment a3 = new Appointment("APT-1003", p3, "Dr. Roshan Amerasinghe", "Root Canal Therapy", "2026-08-12", "14:00", 22000.00, 2000.00, Arrays.asList("Local Anaesthesia", "Post-Care Kit"), 26500.00, "SCHEDULED");

        appointmentStore.put(a1.getAppointmentNumber(), a1);
        appointmentStore.put(a2.getAppointmentNumber(), a2);
        appointmentStore.put(a3.getAppointmentNumber(), a3);

        logAudit("SYSTEM_INIT", "Database Connection Manager initialized with seed records.");
    }

    // Repository operations
    public void saveAppointment(Appointment appointment) {
        appointmentStore.put(appointment.getAppointmentNumber(), appointment);
        patientStore.put(appointment.getPatient().getPatientId(), appointment.getPatient());
        persistToTextFile(appointment);
    }

    public Appointment getAppointment(String appointmentNumber) {
        return appointmentStore.get(appointmentNumber);
    }

    public List<Appointment> getAllAppointments() {
        return new ArrayList<>(appointmentStore.values());
    }

    public void logAudit(String action, String description) {
        String logEntry = String.format("[%s] Action: %s | %s", new Date(), action, description);
        auditLogStore.add(logEntry);
        
        try (PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(auditFile, true)))) {
            out.println(logEntry);
        } catch (IOException e) {
            System.err.println("Error writing audit log: " + e.getMessage());
        }
    }

    public List<String> getAuditLogs() {
        return new ArrayList<>(auditLogStore);
    }

    private void persistToTextFile(Appointment app) {
        try (PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(appointmentsFile, true)))) {
            out.printf("%s|%s|%s|%s|%s|%s|%s|%.2f|%.2f|%s%n",
                    app.getAppointmentNumber(),
                    app.getPatient().getFullName(),
                    app.getPatient().getContactNumber(),
                    app.getDentistName(),
                    app.getTreatmentType(),
                    app.getAppointmentDate(),
                    app.getAppointmentTime(),
                    app.getBaseCost(),
                    app.getTotalCost(),
                    app.getStatus()
            );
        } catch (IOException e) {
            System.err.println("Text file persistence error: " + e.getMessage());
        }
    }
}
