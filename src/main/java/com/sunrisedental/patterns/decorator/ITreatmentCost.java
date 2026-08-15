package com.sunrisedental.patterns.decorator;

import java.util.List;

/**
 * Component interface for Decorator Pattern.
 */
public interface ITreatmentCost {
    double calculateCost();
    String getDescription();
    List<String> getBreakdown();
}
