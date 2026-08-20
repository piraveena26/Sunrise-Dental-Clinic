-- ===================================================================
-- SUNRISE DENTAL CLINIC DATABASE SCHEMA FOR WAMP / PHPMYADMIN
-- Database: sunrise_dental_clinic
-- Engine: InnoDB | MySQL 8.0+ / MariaDB
-- ===================================================================

CREATE DATABASE IF NOT EXISTS `sunrise_dental_clinic` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `sunrise_dental_clinic`;

-- -------------------------------------------------------------------
-- 1. USERS TABLE (Supports Admin, Patient, Doctor, Cashier)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `role` ENUM('ADMIN', 'PATIENT', 'DOCTOR', 'CASHIER') NOT NULL DEFAULT 'PATIENT',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed Default Accounts for all 4 Roles
INSERT INTO `users` (`username`, `password`, `full_name`, `email`, `phone`, `role`) VALUES
('admin', 'admin123', 'System Administrator', 'admin@sunrisedental.com', '+94770000000', 'ADMIN'),
('doctor1', 'doctor123', 'Dr. Chaminda Silva', 'chaminda@sunrisedental.com', '+94771112233', 'DOCTOR'),
('doctor2', 'doctor123', 'Dr. Nimali Fernando', 'nimali@sunrisedental.com', '+94772223344', 'DOCTOR'),
('cashier', 'cashier123', 'Kasun Perera (Cashier)', 'cashier@sunrisedental.com', '+94773334455', 'CASHIER'),
('patient1', 'patient123', 'Piraveena Krishnakumar', 'piraveena@gmail.com', '+94765476542', 'PATIENT');

-- -------------------------------------------------------------------
-- 2. PATIENTS TABLE
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `patients`;
CREATE TABLE `patients` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `nic_passport` VARCHAR(30) NOT NULL UNIQUE,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `age` INT NOT NULL,
    `gender` VARCHAR(10) NOT NULL,
    `address` TEXT,
    `medical_history` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `patients` (`user_id`, `nic_passport`, `full_name`, `email`, `phone`, `age`, `gender`, `address`, `medical_history`) VALUES
(5, '199854321098', 'Piraveena Krishnakumar', 'piraveena@gmail.com', '+94765476542', 26, 'Female', 'No. 45, Galle Road, Colombo 03', 'No known allergies'),
(NULL, '198512345678', 'Saman Kumara', 'saman@gmail.com', '+94718889900', 39, 'Male', 'Kandy Road, Kiribathgoda', 'Diabetic');

-- -------------------------------------------------------------------
-- 3. DOCTORS TABLE
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `doctors`;
CREATE TABLE `doctors` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `name` VARCHAR(100) NOT NULL,
    `specialization` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `doctors` (`user_id`, `name`, `specialization`, `phone`, `email`) VALUES
(2, 'Dr. Chaminda Silva', 'General & Cosmetic Dentistry', '+94771112233', 'chaminda@sunrisedental.com'),
(3, 'Dr. Nimali Fernando', 'Orthodontics & Root Canal Specialist', '+94772223344', 'nimali@sunrisedental.com');

-- -------------------------------------------------------------------
-- 4. DOCTOR SCHEDULES & LEAVE TABLE (For Doctor Availability Slot Blocking)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `doctor_schedules`;
CREATE TABLE `doctor_schedules` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `doctor_id` INT NOT NULL,
    `unavailable_date` DATE NOT NULL,
    `time_slot` VARCHAR(20) DEFAULT 'ALL_DAY', -- 'ALL_DAY', '09:00', '10:30', '14:00', etc.
    `reason` VARCHAR(255) DEFAULT 'On Leave',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`doctor_id`) REFERENCES `doctors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `doctor_schedules` (`doctor_id`, `unavailable_date`, `time_slot`, `reason`) VALUES
(1, '2026-08-25', 'ALL_DAY', 'Medical Conference'),
(2, '2026-08-28', '14:00', 'Personal Leave');

-- -------------------------------------------------------------------
-- 5. APPOINTMENTS TABLE
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `appointments`;
CREATE TABLE `appointments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `appointment_number` VARCHAR(20) NOT NULL UNIQUE,
    `patient_name` VARCHAR(100) NOT NULL,
    `patient_phone` VARCHAR(20) NOT NULL,
    `patient_email` VARCHAR(100) NOT NULL,
    `patient_nic` VARCHAR(30) NOT NULL,
    `patient_age` INT NOT NULL,
    `gender` VARCHAR(10) NOT NULL,
    `dentist_name` VARCHAR(100) NOT NULL,
    `treatment_type` VARCHAR(100) NOT NULL,
    `appointment_date` DATE NOT NULL,
    `appointment_time` VARCHAR(10) NOT NULL,
    `base_fee` DECIMAL(10,2) NOT NULL,
    `total_fee` DECIMAL(10,2) NOT NULL,
    `status` ENUM('CONFIRMED', 'CANCELLED', 'COMPLETED') DEFAULT 'CONFIRMED',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `appointments` (`appointment_number`, `patient_name`, `patient_phone`, `patient_email`, `patient_nic`, `patient_age`, `gender`, `dentist_name`, `treatment_type`, `appointment_date`, `appointment_time`, `base_fee`, `total_fee`, `status`) VALUES
('APT-1001', 'Piraveena Krishnakumar', '+94765476542', 'piraveena@gmail.com', '199854321098', 26, 'Female', 'Dr. Chaminda Silva', 'Routine Checkup', '2026-08-20', '09:00', 3000.00, 5200.00, 'CONFIRMED'),
('APT-1002', 'Saman Kumara', '+94718889900', 'saman@gmail.com', '198512345678', 39, 'Male', 'Dr. Nimali Fernando', 'Teeth Whitening', '2026-08-21', '10:30', 8000.00, 11500.00, 'CONFIRMED');

-- -------------------------------------------------------------------
-- 6. APPOINTMENT ADD-ONS TABLE (Decorator Pattern Persistence)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `appointment_addons`;
CREATE TABLE `appointment_addons` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `appointment_id` INT NOT NULL,
    `addon_name` VARCHAR(100) NOT NULL,
    `addon_cost` DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (`appointment_id`) REFERENCES `appointments`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `appointment_addons` (`appointment_id`, `addon_name`, `addon_cost`) VALUES
(1, 'Digital X-Ray', 1500.00),
(1, 'Local Anaesthesia', 700.00),
(2, 'Fluoride Treatment', 2000.00),
(2, 'Post-Care Hygiene Kit', 1500.00);

-- -------------------------------------------------------------------
-- 7. BILLS TABLE (Billing & Receipt Module)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `bills`;
CREATE TABLE `bills` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `invoice_number` VARCHAR(20) NOT NULL UNIQUE,
    `appointment_id` INT NOT NULL,
    `appointment_number` VARCHAR(20) NOT NULL,
    `patient_name` VARCHAR(100) NOT NULL,
    `treatment_fee` DECIMAL(10,2) NOT NULL,
    `addons_fee` DECIMAL(10,2) NOT NULL,
    `registration_fee` DECIMAL(10,2) NOT NULL DEFAULT 500.00,
    `tax_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `grand_total` DECIMAL(10,2) NOT NULL,
    `payment_status` ENUM('UNPAID', 'PAID') DEFAULT 'UNPAID',
    `payment_method` VARCHAR(30) DEFAULT 'Cash',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`appointment_id`) REFERENCES `appointments`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `bills` (`invoice_number`, `appointment_id`, `appointment_number`, `patient_name`, `treatment_fee`, `addons_fee`, `registration_fee`, `tax_amount`, `grand_total`, `payment_status`, `payment_method`) VALUES
('INV-5001', 1, 'APT-1001', 'Piraveena Krishnakumar', 3000.00, 2200.00, 500.00, 0.00, 5700.00, 'PAID', 'Card'),
('INV-5002', 2, 'APT-1002', 'Saman Kumara', 8000.00, 3500.00, 500.00, 0.00, 12000.00, 'UNPAID', 'Cash');

-- -------------------------------------------------------------------
-- 8. AUDIT LOGS TABLE
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `event_type` VARCHAR(50) NOT NULL,
    `appointment_number` VARCHAR(20),
    `description` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `audit_logs` (`event_type`, `appointment_number`, `description`) VALUES
('SYSTEM_INIT', 'SYSTEM', 'Sunrise Dental Clinic Database initialized successfully with default records.');

-- ===================================================================
-- END OF SCHEMA
-- ===================================================================
