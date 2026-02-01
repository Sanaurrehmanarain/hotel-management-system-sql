-- file: hotel_schema.sql

-- 1. Setup Environment
CREATE DATABASE IF NOT EXISTS hotel_db;
USE hotel_db;

-- 2. Clean Slate
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS seasonal_rates;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS guests;

-- 3. Guests Table (The Users)
CREATE TABLE guests (
    guest_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(50),
    nationality VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Rooms Table
-- 'capacity' allows distinguishing between Private Rooms (cap=2) and Dorms (cap=8)
CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    room_type ENUM('Single', 'Double', 'Suite', 'Dormitory') NOT NULL,
    capacity INT NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL, -- The standard nightly rate
    status ENUM('Available', 'Maintenance') DEFAULT 'Available'
);

-- 5. Seasonal Rates (For Dynamic Pricing)
-- Overrides base_price for specific date ranges (e.g., Summer, Christmas)
CREATE TABLE seasonal_rates (
    rate_id INT AUTO_INCREMENT PRIMARY KEY,
    rate_name VARCHAR(50), -- e.g., "Summer Peak"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    multiplier DECIMAL(3, 2) NOT NULL -- e.g., 1.50 for 50% price increase
);

-- 6. Bookings Table (The Core Logic)
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('Confirmed', 'Cancelled', 'Checked-In', 'Checked-Out') DEFAULT 'Confirmed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE CASCADE
);

-- 7. Payments Table
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    method ENUM('Credit Card', 'Cash', 'Online Transfer'),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);

-- ==========================================
-- INDEX OPTIMIZATION (Technical Requirement)
-- ==========================================
-- Why? Searching for "Available Rooms" requires scanning dates constantly.
-- Without indexes, the system scans the whole table (slow). With indexes, it's instant.

CREATE INDEX idx_booking_dates ON bookings(check_in, check_out);
CREATE INDEX idx_room_status ON rooms(status);
CREATE INDEX idx_guest_email ON guests(email);