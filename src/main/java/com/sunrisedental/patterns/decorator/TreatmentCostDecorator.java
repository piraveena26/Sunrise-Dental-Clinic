package com.sunrisedental.patterns.decorator;

import java.util.ArrayList;
import java.util.List;

/**
 * DESIGN PATTERN: DECORATOR PATTERN (Structural)
 *
 * Why Decorator Pattern?
 * In Sunrise Dental Clinic, calculating the final patient bill involves combining a base treatment fee,
 * dentist consultation fee, and zero or more optional clinical add-ons (X-Ray, Local Anaesthesia,
 * Fluoride Treatment, Post-Care Kits).
 * Rather than creating static subclasses for every combination of add-ons, the Decorator pattern allows
 * dynamically wrapping the base cost with add-on decorators at runtime.
 */

// Concrete Base Component
class BaseTreatmentCost implements ITreatmentCost {
    private final String treatmentName;
    private final double basePrice;
    private final double consultationFee;

    public BaseTreatmentCost(String treatmentName, double basePrice, double consultationFee) {
        this.treatmentName = treatmentName;
        this.basePrice = basePrice;
        this.consultationFee = consultationFee;
    }

    @Override
    public double calculateCost() {
        return basePrice + consultationFee;
    }

    @Override
    public String getDescription() {
        return String.format("%s (LKR %.2f) + Consultation Fee (LKR %.2f)", treatmentName, basePrice, consultationFee);
    }

    @Override
    public List<String> getBreakdown() {
        List<String> list = new ArrayList<>();
        list.add(String.format("%s Base Fee: LKR %.2f", treatmentName, basePrice));
        list.add(String.format("Dentist Consultation Fee: LKR %.2f", consultationFee));
        return list;
    }
}

// Abstract Decorator
public abstract class TreatmentCostDecorator implements ITreatmentCost {
    protected final ITreatmentCost wrappedCost;

    public TreatmentCostDecorator(ITreatmentCost wrappedCost) {
        this.wrappedCost = wrappedCost;
    }

    @Override
    public double calculateCost() {
        return wrappedCost.calculateCost();
    }

    @Override
    public String getDescription() {
        return wrappedCost.getDescription();
    }

    @Override
    public List<String> getBreakdown() {
        return wrappedCost.getBreakdown();
    }
}

// Concrete Decorators

// Add-on: Dental X-Ray
class XRayDecorator extends TreatmentCostDecorator {
    private final double xrayFee = 1500.00;

    public XRayDecorator(ITreatmentCost wrappedCost) {
        super(wrappedCost);
    }

    @Override
    public double calculateCost() {
        return super.calculateCost() + xrayFee;
    }

    @Override
    public String getDescription() {
        return super.getDescription() + " + Digital Dental X-Ray";
    }

    @Override
    public List<String> getBreakdown() {
        List<String> list = super.getBreakdown();
        list.add(String.format("Add-on: Digital Dental X-Ray: LKR %.2f", xrayFee));
        return list;
    }
}

// Add-on: Local Anaesthesia
class AnaesthesiaDecorator extends TreatmentCostDecorator {
    private final double fee = 2500.00;

    public AnaesthesiaDecorator(ITreatmentCost wrappedCost) {
        super(wrappedCost);
    }

    @Override
    public double calculateCost() {
        return super.calculateCost() + fee;
    }

    @Override
    public String getDescription() {
        return super.getDescription() + " + Local Anaesthesia";
    }

    @Override
    public List<String> getBreakdown() {
        List<String> list = super.getBreakdown();
        list.add(String.format("Add-on: Local Anaesthesia: LKR %.2f", fee));
        return list;
    }
}

// Add-on: Fluoride Application
class FluorideDecorator extends TreatmentCostDecorator {
    private final double fee = 1200.00;

    public FluorideDecorator(ITreatmentCost wrappedCost) {
        super(wrappedCost);
    }

    @Override
    public double calculateCost() {
        return super.calculateCost() + fee;
    }

    @Override
    public String getDescription() {
        return super.getDescription() + " + Fluoride Application";
    }

    @Override
    public List<String> getBreakdown() {
        List<String> list = super.getBreakdown();
        list.add(String.format("Add-on: Fluoride Application: LKR %.2f", fee));
        return list;
    }
}

// Add-on: Post-Care Hygiene Kit
class PostCareKitDecorator extends TreatmentCostDecorator {
    private final double fee = 2000.00;

    public PostCareKitDecorator(ITreatmentCost wrappedCost) {
        super(wrappedCost);
    }

    @Override
    public double calculateCost() {
        return super.calculateCost() + fee;
    }

    @Override
    public String getDescription() {
        return super.getDescription() + " + Post-Care Hygiene Kit";
    }

    @Override
    public List<String> getBreakdown() {
        List<String> list = super.getBreakdown();
        list.add(String.format("Add-on: Post-Care Hygiene Kit: LKR %.2f", fee));
        return list;
    }
}
