package com.sunrisedental.patterns.decorator;

import java.util.List;

/**
 * Utility class executing the Decorator pattern to construct dynamic treatment bills.
 */
public class BillingCalculator {

    public static ITreatmentCost buildCostCalculator(String treatmentName, double basePrice, double consultationFee, List<String> addOns) {
        ITreatmentCost cost = new BaseTreatmentCost(treatmentName, basePrice, consultationFee);

        if (addOns != null) {
            for (String addOn : addOns) {
                if (addOn == null) continue;
                String normalized = addOn.trim().toLowerCase();
                if (normalized.contains("x-ray") || normalized.contains("xray")) {
                    cost = new XRayDecorator(cost);
                } else if (normalized.contains("anaesthesia") || normalized.contains("anesthesia")) {
                    cost = new AnaesthesiaDecorator(cost);
                } else if (normalized.contains("fluoride")) {
                    cost = new FluorideDecorator(cost);
                } else if (normalized.contains("post-care") || normalized.contains("hygiene")) {
                    cost = new PostCareKitDecorator(cost);
                }
            }
        }

        return cost;
    }
}
