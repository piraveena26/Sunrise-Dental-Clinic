package com.sunrisedental.patterns.factory;

/**
 * DESIGN PATTERN: FACTORY METHOD PATTERN (Creational)
 *
 * Why Factory Method?
 * Encapsulates treatment creation logic so the application code does not need to know
 * concrete classes or hardcode pricing/duration details. New treatments can be added
 * without modifying existing client code (Open-Closed Principle).
 */
public class TreatmentFactory {

    public static Treatment createTreatment(String type) {
        if (type == null || type.trim().isEmpty()) {
            return new RoutineCheckupTreatment();
        }

        switch (type.trim().toLowerCase()) {
            case "routine checkup":
            case "checkup":
                return new RoutineCheckupTreatment();
            case "teeth whitening":
            case "whitening":
                return new TeethWhiteningTreatment();
            case "root canal therapy":
            case "root canal":
                return new RootCanalTreatment();
            case "orthodontic braces":
            case "braces":
                return new OrthodonticBracesTreatment();
            case "dental filling":
            case "filling":
                return new DentalFillingTreatment();
            case "tooth extraction":
            case "extraction":
                return new ToothExtractionTreatment();
            default:
                // Default fallback
                return new RoutineCheckupTreatment();
        }
    }
}
