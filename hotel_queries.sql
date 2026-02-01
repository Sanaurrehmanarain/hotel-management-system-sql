-- Query 1: Find Available Rooms for specific dates
SET @check_in = '2025-06-10';
SET @check_out = '2025-06-15';

SELECT r.room_number, r.room_type, r.base_price
FROM rooms r
WHERE r.room_id NOT IN (
    SELECT b.room_id 
    FROM bookings b
    WHERE 
        (b.check_in <= @check_out) AND (b.check_out >= @check_in)
        AND b.status != 'Cancelled'
);

-- Query 2: Calculate Price with Seasonality
SELECT 
    r.room_number,
    r.base_price AS standard_rate,
    sr.rate_name AS season,
    sr.multiplier,
    (r.base_price * sr.multiplier) AS seasonal_price
FROM rooms r
JOIN seasonal_rates sr 
    ON '2025-07-01' BETWEEN sr.start_date AND sr.end_date -- Checking a date in July
WHERE r.room_type = 'Suite';

-- 3. Today's Check-Ins (Arrival List)
-- Note: Replaces 'CURDATE()' with a specific 2025 date to match your fake data
SELECT b.booking_id, g.first_name, g.last_name, r.room_number
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id
WHERE b.check_in = '2025-06-12'; -- Simulating "Today"

-- 4. Today's Check-Outs (Departure List)
SELECT b.booking_id, g.last_name, r.room_number, 
       CASE WHEN p.amount >= b.total_price THEN 'Paid' ELSE 'Due' END AS payment_status
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id
LEFT JOIN payments p ON b.booking_id = p.booking_id
WHERE b.check_out = '2025-06-12';

-- 5. Currently Occupied Rooms (Guest in House)
SELECT r.room_number, r.room_type, g.last_name, b.check_out
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
JOIN guests g ON b.guest_id = g.guest_id
WHERE '2025-06-12' BETWEEN b.check_in AND b.check_out;

-- 6. Guest Search by Partial Name (Search Feature)
SELECT guest_id, first_name, last_name, email, phone
FROM guests
WHERE last_name LIKE 'Smi%'; -- Finds 'Smith', 'Smiley', etc.


-- 7. Monthly Revenue Report
SELECT 
    DATE_FORMAT(check_in, '%Y-%m') AS month,
    COUNT(booking_id) AS total_bookings,
    SUM(total_price) AS total_revenue
FROM bookings
WHERE status != 'Cancelled'
GROUP BY month
ORDER BY month;

-- 8. Average Daily Rate (ADR)
-- Formula: Total Revenue / Number of Rooms Sold
SELECT 
    r.room_type,
    ROUND(AVG(b.total_price / DATEDIFF(b.check_out, b.check_in)), 2) AS avg_nightly_rate
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
GROUP BY r.room_type;

-- 9. Revenue by Payment Method
SELECT method, SUM(amount) AS total_collected
FROM payments
GROUP BY method;

-- 10. Top Revenue Generating Rooms (The "Best Sellers")
SELECT r.room_number, SUM(b.total_price) AS revenue_generated
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
GROUP BY r.room_number
ORDER BY revenue_generated DESC
LIMIT 5;

-- 11. Cancellation Rate (Financial Loss Analysis)
SELECT 
    (SELECT COUNT(*) FROM bookings WHERE status = 'Cancelled') * 100.0 / COUNT(*) AS cancellation_percentage
FROM bookings;

-- 12. Occupancy Rate by Room Type
-- Shows which room types are most popular (e.g., Dorms vs Suites)
SELECT 
    r.room_type,
    COUNT(b.booking_id) AS times_booked
FROM rooms r
LEFT JOIN bookings b ON r.room_id = b.room_id
GROUP BY r.room_type
ORDER BY times_booked DESC;

-- 13. Long-Stay Guests (More than 7 days)
SELECT g.first_name, g.last_name, DATEDIFF(b.check_out, b.check_in) AS stay_duration
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
WHERE DATEDIFF(b.check_out, b.check_in) > 7
ORDER BY stay_duration DESC;

-- 14. Average Lead Time (Booking Behavior)
-- How many days in advance do people book?
SELECT AVG(DATEDIFF(check_in, DATE(created_at))) AS avg_days_in_advance
FROM bookings;

-- 15. Peak Season Identification
-- Which month has the most check-ins?
SELECT MONTHNAME(check_in) AS month_name, COUNT(*) AS check_ins
FROM bookings
GROUP BY month_name
ORDER BY check_ins DESC
LIMIT 1;

-- 16. Guest Nationality Breakdown
SELECT nationality, COUNT(*) AS count
FROM guests
GROUP BY nationality
ORDER BY count DESC
LIMIT 5;

-- 17. Repeat Guests (Loyalty Check)
SELECT g.first_name, g.last_name, COUNT(b.booking_id) AS visits
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_id
HAVING visits > 1;

-- 18. Housekeeping Schedule (Rooms Checking Out Tomorrow)
-- These rooms need to be cleaned for the next guest
SELECT r.room_number, r.room_type
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
WHERE b.check_out = '2025-06-13'; -- Tomorrow's date

-- 19. Room Maintenance Status
SELECT room_number, status 
FROM rooms 
WHERE status = 'Maintenance';

-- 20. "Orphaned" Rooms (Rooms that have never been booked)
-- Efficiency Check: Are we wasting space?
SELECT room_number, room_type 
FROM rooms 
WHERE room_id NOT IN (SELECT DISTINCT room_id FROM bookings);
