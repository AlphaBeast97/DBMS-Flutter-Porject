-- Patch routines to fix collation mismatch
-- Run after techfix.sql and before app usage if collation errors appear

USE techfix;

DROP PROCEDURE IF EXISTS sp_employee_login;
DROP PROCEDURE IF EXISTS sp_customer_login;
DROP PROCEDURE IF EXISTS sp_get_customer_full_for_customer;

DELIMITER $$
CREATE PROCEDURE sp_employee_login(
    IN p_email VARCHAR(100),
    IN p_password_hash VARCHAR(255)
)
BEGIN
    DECLARE v_count INT;

    -- Validate required inputs
    IF p_email IS NULL OR p_email = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email is required.';
    END IF;
    IF p_password_hash IS NULL OR p_password_hash = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password hash is required.';
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM employees
        WHERE email = p_email COLLATE utf8mb4_uca1400_ai_ci
            AND password_hash = p_password_hash COLLATE utf8mb4_uca1400_ai_ci;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid credentials.';
    END IF;

    SELECT employee_id, organization_id, name, email, role, created_at
    FROM employees
        WHERE email = p_email COLLATE utf8mb4_uca1400_ai_ci
            AND password_hash = p_password_hash COLLATE utf8mb4_uca1400_ai_ci;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_customer_login(
    IN p_email VARCHAR(100)
)
BEGIN
    DECLARE v_count INT;

    -- Validate required inputs
    IF p_email IS NULL OR p_email = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email is required.';
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM customers
    WHERE email = p_email COLLATE utf8mb4_uca1400_ai_ci;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found.';
    END IF;

    SELECT customer_id, organization_id, name, phone, email, created_at
    FROM customers
    WHERE email = p_email COLLATE utf8mb4_uca1400_ai_ci;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_get_customer_full_for_customer(
    IN p_email VARCHAR(100)
)
BEGIN
    DECLARE v_customer_id INT;

    -- Validate required inputs
    IF p_email IS NULL OR p_email = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email is required.';
    END IF;

    SELECT customer_id
    INTO v_customer_id
    FROM customers
    WHERE email = p_email COLLATE utf8mb4_uca1400_ai_ci;

    IF v_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found.';
    END IF;

    -- Result set 1: customer
    SELECT
        customer_id,
        organization_id,
        name,
        phone,
        email,
        created_at
    FROM customers
    WHERE customer_id = v_customer_id;

    -- Result set 2: devices
    SELECT
        d.device_id,
        d.type,
        d.brand,
        d.model,
        d.serial_number,
        d.created_at
    FROM devices d
    WHERE d.customer_id = v_customer_id;

    -- Result set 3: repair jobs
    SELECT
        r.job_id,
        r.device_id,
        r.description,
        r.estimated_cost,
        r.final_cost,
        r.status,
        r.created_at
    FROM repair_jobs r
    JOIN devices d ON d.device_id = r.device_id
    WHERE d.customer_id = v_customer_id;

    -- Result set 4: inventory usage
    SELECT
        u.usage_id,
        u.job_id,
        u.part_name,
        u.part_cost,
        u.created_at
    FROM inventory_usage u
    JOIN repair_jobs r ON r.job_id = u.job_id
    JOIN devices d ON d.device_id = r.device_id
    WHERE d.customer_id = v_customer_id;
END$$
DELIMITER ;
