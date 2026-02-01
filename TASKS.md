# 📋 Project Tasks: StayManager (Hotel Database)

## 📌 Problem Statement
Hotel management relies on complex **Temporal Data** (dates and times). Traditional databases often struggle with:
1.  **Double Bookings:** Allowing two guests to book the same room for overlapping dates.
2.  **Static Pricing:** Failing to adjust prices automatically during peak seasons (Summer/Holidays).
3.  **Slow Queries:** Availability checks becoming slow as booking history grows.

## 🎯 Project Objectives
* Design a **3NF Normalized Schema** to handle Guests, Rooms, and Bookings.
* Implement **Inverse Date Logic** to accurately detect room availability.
* Create a **Dynamic Pricing Engine** using SQL joins.
* Optimize performance using **B-Tree Indexing**.

## ✅ Tasks Completed

### Phase 1: Database Architecture
- [x] **Schema Design:** Created 5 core tables (`guests`, `rooms`, `bookings`, `payments`, `seasonal_rates`).
- [x] **Data Integrity:** Implemented `FOREIGN KEYS` with `ON DELETE CASCADE`.
- [x] **Capacity Logic:** Designed `rooms` table to handle different capacities (Single vs Dorms).

### Phase 2: Data Engineering (Python)
- [x] **Simulation Script:** Wrote Python script using `Faker` library.
- [x] **Complex Data Generation:** Generated 150+ bookings with realistic start/end dates in 2025.
- [x] **Error Handling:** Handled `VARCHAR` limits for phone numbers and email uniqueness.

### Phase 3: Advanced SQL Implementation
- [x] **Availability Query:** Implemented `NOT IN` subquery with date overlap logic `(StartA <= EndB) AND (EndA >= StartB)`.
- [x] **Dynamic Pricing:** Implemented `JOIN` logic to apply 1.5x multipliers during Summer seasons.
- [x] **Indexing:** Created composite indexes on `check_in` and `check_out` columns.

### Phase 4: Analytics & Reporting
- [x] **Financial Reports:** Calculated ADR (Average Daily Rate) and RevPAR.
- [x] **Operational Queries:** Built "Arrival List" and "Departure List" queries for Front Desk staff.
- [x] **Dashboard:** Visualized Revenue Trends and Occupancy using Python (Matplotlib/Seaborn).