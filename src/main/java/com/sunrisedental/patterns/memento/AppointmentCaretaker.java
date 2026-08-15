package com.sunrisedental.patterns.memento;

import com.sunrisedental.model.Appointment;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.HashMap;
import java.util.Map;

/**
 * Caretaker Class maintaining Memento history per appointment.
 */
public class AppointmentCaretaker {
    private final Map<String, Deque<AppointmentMemento>> historyMap = new HashMap<>();

    public void saveSnapshot(Appointment appointment) {
        String appNum = appointment.getAppointmentNumber();
        historyMap.putIfAbsent(appNum, new ArrayDeque<>());
        historyMap.get(appNum).push(new AppointmentMemento(appointment));
    }

    public Appointment undo(Appointment currentAppointment) {
        String appNum = currentAppointment.getAppointmentNumber();
        if (historyMap.containsKey(appNum) && !historyMap.get(appNum).isEmpty()) {
            AppointmentMemento memento = historyMap.get(appNum).pop();
            return memento.getSavedState();
        }
        return null; // No state available to undo
    }

    public boolean canUndo(String appointmentNumber) {
        return historyMap.containsKey(appointmentNumber) && !historyMap.get(appointmentNumber).isEmpty();
    }
}
