package com.sunrisedental.test;

import com.sunrisedental.model.Appointment;
import com.sunrisedental.patterns.decorator.ITreatmentCost;
import com.sunrisedental.patterns.facade.ClinicManagementFacade;
import com.sunrisedental.patterns.factory.Treatment;
import com.sunrisedental.patterns.factory.TreatmentFactory;
import com.sunrisedental.repository.DatabaseConnectionManager;

import java.util.Arrays;
import java.util.List;

/**
 * Unit Test suite verifying Java Design Patterns, 3-Tier Facade, and Edge Cases.
 */
public class ClinicSystemTest {

    public static void main(String[] args) {
        System.out.println("=================================================");
        System.out.println("  RUNNING SUNRISE DENTAL CLINIC UNIT TEST SUITE  ");
        System.out.println("=================================================");

        int passed = 0;
        int failed = 0;

        // Test 1: Singleton Pattern Verification
        try {
            DatabaseConnectionManager instance1 = DatabaseConnectionManager.getInstance();
            DatabaseConnectionManager instance2 = DatabaseConnectionManager.getInstance();
            assert instance1 == instance2 : "Singleton instances are not identical!";
            System.out.println("[PASS] 1. Singleton Pattern (DatabaseConnectionManager instance identity confirmed)");
            passed++;
        } catch (Throwable t) {
            System.err.println("[FAIL] 1. Singleton Pattern: " + t.getMessage());
            failed++;
        }

        // Test 2: Factory Method Pattern Verification
        try {
            Treatment t1 = TreatmentFactory.createTreatment("Root Canal Therapy");
            assert "Root Canal Therapy".equals(t1.getName()) : "Incorrect treatment name!";
            assert t1.getBasePrice() == 22000.00 : "Incorrect base price!";
            System.out.println("[PASS] 2. Factory Method Pattern (Root Canal Therapy instantiated correctly)");
            passed++;
        } catch (Throwable t) {
            System.err.println("[FAIL] 2. Factory Method Pattern: " + t.getMessage());
            failed++;
        }

        // Test 3: Builder + Decorator + Facade Integration
        try {
            ClinicManagementFacade facade = new ClinicManagementFacade();
            Appointment app = facade.registerAppointment(
                    "Test Patient",
                    "100 Galle Rd",
                    "+94 70 000 0000",
                    "Dr. Chaminda Silva",
                    "Teeth Whitening",
                    "2026-08-15",
                    "10:00",
                    Arrays.asList("X-Ray", "Local Anaesthesia")
            );

            assert app != null : "Appointment building failed!";
            assert app.getAppointmentNumber().startsWith("APT-") : "Invalid Appointment Number format!";
            // Whitening (15000) + Consultation (1500) + X-Ray (1500) + Anaesthesia (2500) = 20500
            assert app.getTotalCost() == 20500.00 : "Decorator cost calculation mismatch! Got: " + app.getTotalCost();

            System.out.println("[PASS] 3. Builder & Decorator Patterns (Bill calculated correctly: LKR " + app.getTotalCost() + ")");
            passed++;
        } catch (Throwable t) {
            System.err.println("[FAIL] 3. Builder & Decorator Patterns: " + t.getMessage());
            failed++;
        }

        // Test 4: Memento Pattern Undo Verification
        try {
            ClinicManagementFacade facade = new ClinicManagementFacade();
            Appointment app = facade.getAppointmentDetails("APT-1001");
            String originalDentist = app.getDentistName();

            // Mutate schedule
            facade.updateAppointmentSchedule("APT-1001", "Dr. NewDentist", "2026-08-20", "15:00");
            assert "Dr. NewDentist".equals(facade.getAppointmentDetails("APT-1001").getDentistName());

            // Undo edit
            Appointment restored = facade.undoAppointmentEdit("APT-1001");
            assert restored != null : "Memento undo returned null!";
            assert originalDentist.equals(restored.getDentistName()) : "Memento undo failed to restore dentist name!";

            System.out.println("[PASS] 4. Memento Pattern (Successfully captured snapshot and restored state)");
            passed++;
        } catch (Throwable t) {
            System.err.println("[FAIL] 4. Memento Pattern: " + t.getMessage());
            failed++;
        }

        // Test 5: Edge Case Validation (Null & empty inputs)
        try {
            ClinicManagementFacade facade = new ClinicManagementFacade();
            boolean authResult = facade.authenticate(null, null);
            assert !authResult : "Null authentication should fail!";

            Appointment nullApp = facade.getAppointmentDetails(null);
            assert nullApp == null : "Searching null appointment should return null!";

            System.out.println("[PASS] 5. Edge Case Validation (Null auth and invalid searches handled safely)");
            passed++;
        } catch (Throwable t) {
            System.err.println("[FAIL] 5. Edge Case Validation: " + t.getMessage());
            failed++;
        }

        System.out.println("=================================================");
        System.out.println("  TEST RESULTS: " + passed + " PASSED, " + failed + " FAILED  ");
        System.out.println("=================================================");
    }
}
