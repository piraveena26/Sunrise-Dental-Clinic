package com.sunrisedental.patterns.factory;

/**
 * Interface for Dental Treatments.
 */
public interface Treatment {
    String getName();
    double getBasePrice();
    int getDurationMinutes();
    String getDescription();
}

// 1. Concrete Treatment: Routine Checkup
class RoutineCheckupTreatment implements Treatment {
    @Override public String getName() { return "Routine Checkup"; }
    @Override public double getBasePrice() { return 2500.00; }
    @Override public int getDurationMinutes() { return 30; }
    @Override public String getDescription() { return "Comprehensive oral inspection, tartar evaluation, and dental hygiene advice."; }
}

// 2. Concrete Treatment: Teeth Whitening
class TeethWhiteningTreatment implements Treatment {
    @Override public String getName() { return "Teeth Whitening"; }
    @Override public double getBasePrice() { return 15000.00; }
    @Override public int getDurationMinutes() { return 60; }
    @Override public String getDescription() { return "Professional laser bleaching and enamel stain removal."; }
}

// 3. Concrete Treatment: Root Canal Therapy
class RootCanalTreatment implements Treatment {
    @Override public String getName() { return "Root Canal Therapy"; }
    @Override public double getBasePrice() { return 22000.00; }
    @Override public int getDurationMinutes() { return 90; }
    @Override public String getDescription() { return "Endodontic therapy, pulp removal, canal cleaning, and gutta-percha sealing."; }
}

// 4. Concrete Treatment: Orthodontic Braces
class OrthodonticBracesTreatment implements Treatment {
    @Override public String getName() { return "Orthodontic Braces"; }
    @Override public double getBasePrice() { return 45000.00; }
    @Override public int getDurationMinutes() { return 120; }
    @Override public String getDescription() { return "Alignment consultation, bracket fitting, and archwire installation."; }
}

// 5. Concrete Treatment: Dental Filling
class DentalFillingTreatment implements Treatment {
    @Override public String getName() { return "Dental Filling"; }
    @Override public double getBasePrice() { return 4500.00; }
    @Override public int getDurationMinutes() { return 45; }
    @Override public String getDescription() { return "Composite resin restoration for cavity removal."; }
}

// 6. Concrete Treatment: Tooth Extraction
class ToothExtractionTreatment implements Treatment {
    @Override public String getName() { return "Tooth Extraction"; }
    @Override public double getBasePrice() { return 5500.00; }
    @Override public int getDurationMinutes() { return 45; }
    @Override public String getDescription() { return "Surgical or simple removal of decayed or impacted tooth."; }
}
