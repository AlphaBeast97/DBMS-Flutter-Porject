-- ============================================================
-- TechFix — Complete Database Demo Script
-- Run in MySQL Workbench or CLI line by line
-- Uses seed data from techfix_seed.sql
-- ============================================================

USE techfix;

-- ============================================================
-- 1. VIEW ALL SEED DATA
-- ============================================================

SELECT '--- 1. All Organizations ---';
SELECT * FROM organizations;

SELECT '--- 2. All Employees ---';
SELECT * FROM employees;

SELECT '--- 3. All Customers ---';
SELECT * FROM customers;

SELECT '--- 4. All Devices ---';
SELECT * FROM devices;

SELECT '--- 5. All Repair Jobs ---';
SELECT * FROM repair_jobs;

SELECT '--- 6. All Inventory Usage ---';
SELECT * FROM inventory_usage;

-- ============================================================
-- 2. STORED FUNCTION
-- ============================================================

SELECT '--- fn_parts_total: Sum parts cost for Job 3 ---';
-- Expected: 800.00 (HDMI port)
SELECT fn_parts_total(3) AS total_parts_cost;

SELECT '--- fn_parts_total: Job with no parts (should be 0) ---';
-- Expected: 0.00
SELECT fn_parts_total(1) AS total_parts_cost;

-- ============================================================
-- 3. AUTHENTICATION
-- ============================================================

SELECT '--- Employee Login: Valid credentials ---';
CALL sp_employee_login('bilal.tech@techfix.com', SHA2('Tech123', 256));

SELECT '--- Employee Login: Invalid password (should fail) ---';
-- Expected: SIGNAL 'Invalid credentials.'
CALL sp_employee_login('bilal.tech@techfix.com', SHA2('WrongPassword', 256));

SELECT '--- Customer Login: Valid email ---';
CALL sp_customer_login('ayesha@example.com');

SELECT '--- Customer Login: Unknown email (should fail) ---';
-- Expected: SIGNAL 'Customer not found.'
CALL sp_customer_login('nonexistent@example.com');

-- ============================================================
-- 4. CREATE FLOW (Customer → Device → Repair Job → Log Part)
-- ============================================================

SELECT '--- Create: New Customer ---';
CALL sp_create_customer(
    1,              -- org_id (TechFix Lahore)
    2,              -- employee_id (Bilal Hussain)
    'Ali Raza',     -- name
    '03111223344',  -- phone
    'ali@example.com'
);
-- Note the returned customer_id (should be 6)

SELECT '--- Create: New Device for that Customer ---';
-- Replace p_customer_id with the ID returned above (e.g., 6)
CALL sp_create_device(
    2,              -- employee_id (Bilal Hussain)
    6,              -- customer_id (Ali Raza — adjust if different)
    'Mobile',       -- type
    'Google',       -- brand
    'Pixel 7',      -- model
    'GP-PIX7-009'   -- serial_number
);
-- Note the returned device_id (should be 9)

SELECT '--- Create: New Repair Job for that Device ---';
-- Replace p_device_id with the ID returned above (e.g., 9)
CALL sp_create_repair_job(
    2,              -- employee_id (Bilal Hussain)
    9,              -- device_id (Google Pixel 7 — adjust if different)
    'Battery drains quickly, needs replacement',
    5500.00,        -- estimated_cost
    'Pending'
);
-- Note the returned job_id (should be 11)

SELECT '--- Create: Log Part Used on the New Job ---';
-- Replace p_job_id with the ID returned above (e.g., 11)
CALL sp_log_inventory_usage(
    2,              -- employee_id (Bilal Hussain)
    11,             -- job_id (Pixel 7 repair — adjust if different)
    'Battery Li-Po 4500mAh',
    2200.00
);

-- ============================================================
-- 5. TRIGGER DEMO (Status transition → Delivered auto-cost)
-- ============================================================

SELECT '--- Trigger Demo: Check Job 3 before delivery ---';
SELECT job_id, status, final_cost FROM repair_jobs WHERE job_id = 3;
-- Expected: status = 'Ready', final_cost = NULL

SELECT '--- Trigger Demo: Mark Job 3 as Delivered ---';
CALL sp_update_repair_job_status(2, 3, 'Delivered');

SELECT '--- Trigger Demo: Check Job 3 after delivery ---';
SELECT job_id, status, final_cost FROM repair_jobs WHERE job_id = 3;
-- Expected: status = 'Delivered', final_cost = 800.00 (auto-calculated)

-- ============================================================
-- 6. READ QUERIES
-- ============================================================

SELECT '--- Read: Technician view (Bilal — his own jobs) ---';
CALL sp_get_repair_jobs(2, NULL, NULL);

SELECT '--- Read: Technician view filtered by status ---';
CALL sp_get_repair_jobs(2, 'Pending', NULL);

SELECT '--- Read: Owner view (all jobs in org) ---';
CALL sp_get_repair_jobs(1, NULL, 1);

SELECT '--- Read: Employee views full customer profile ---';
-- Returns 4 result sets: customer + devices + jobs + inventory
CALL sp_get_customer_full_for_employee(2, 1);
-- Employee Bilal (2) viewing customer Ayesha (1)

SELECT '--- Read: Customer self-service portal ---';
-- Returns 4 result sets with no password required
CALL sp_get_customer_full_for_customer('ayesha@example.com');

-- ============================================================
-- 7. ERROR CASES (Expected failures)
-- ============================================================

SELECT '--- Error 1: Update a Delivered job (should fail) ---';
-- Expected: SIGNAL 'Cannot update a cancelled or delivered job.'
CALL sp_update_repair_job_status(2, 3, 'Pending');

SELECT '--- Error 2: Employee tries to cancel a job (should fail) ---';
-- Expected: SIGNAL 'Use customer cancel procedure for Cancelled status.'
CALL sp_update_repair_job_status(2, 1, 'Cancelled');

SELECT '--- Error 3: Cancel a non-Pending job (should fail) ---';
-- Job 3 is now Delivered, cannot be cancelled
-- Expected: SIGNAL 'Only pending jobs can be cancelled.'
CALL sp_cancel_repair_job_by_customer(1, 3);

SELECT '--- Error 4: Employee + device in different orgs (should fail) ---';
-- Usman (emp 4) vs a device owned by customer created by Bilal — if same org passes
-- Try employee from a non-existent org context:
CALL sp_create_device(999, 1, 'Mobile', 'Test', 'X', 'SN-001');

-- ============================================================
-- 8. CLEANUP (Remove demo records from section 4)
-- ============================================================

SELECT '--- Cleanup: Deleting demo records ---';
-- Delete in reverse dependency order
DELETE FROM inventory_usage WHERE job_id = 11;
DELETE FROM repair_jobs WHERE job_id = 11;
DELETE FROM devices WHERE device_id = 9;
DELETE FROM customers WHERE email = 'ali@example.com';

SELECT '--- Verify: Demo records removed ---';
SELECT * FROM customers WHERE email = 'ali@example.com';
SELECT * FROM devices WHERE serial_number = 'GP-PIX7-009';

-- ============================================================
-- END OF DEMO
-- ============================================================
