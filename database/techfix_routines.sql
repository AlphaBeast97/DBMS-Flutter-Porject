-- TechFix routines (functions + procedures)
-- Run after techfix.sql

USE techfix;

-- Stored function: sum parts cost for a job
DELIMITER $$
CREATE FUNCTION fn_parts_total(p_job_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);

    -- Sum all parts used for the given job
    SELECT IFNULL(SUM(part_cost), 0.00)
    INTO v_total
    FROM inventory_usage
    WHERE job_id = p_job_id;

    RETURN v_total;
END$$
DELIMITER ;

-- Stored procedures: organization and employee setup
DELIMITER $$
CREATE PROCEDURE sp_create_owner(
    IN p_org_name VARCHAR(100),
    IN p_owner_name VARCHAR(100),
    IN p_owner_email VARCHAR(100),
    IN p_password_hash VARCHAR(255)
)
BEGIN
    DECLARE v_org_id INT;
    DECLARE v_owner_id INT;

    -- Roll back if any step fails
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Validate required inputs
    IF p_org_name IS NULL OR p_org_name = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Organization name is required.';
    END IF;
    IF p_owner_name IS NULL OR p_owner_name = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Owner name is required.';
    END IF;
    IF p_owner_email IS NULL OR p_owner_email = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Owner email is required.';
    END IF;
    IF p_password_hash IS NULL OR p_password_hash = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password hash is required.';
    END IF;

    START TRANSACTION;

    -- Create organization
    INSERT INTO organizations (name)
    VALUES (p_org_name);
    SET v_org_id = LAST_INSERT_ID();

    -- Create owner account
    INSERT INTO employees (organization_id, name, email, password_hash, role)
    VALUES (v_org_id, p_owner_name, p_owner_email, p_password_hash, 'Owner');
    SET v_owner_id = LAST_INSERT_ID();

    COMMIT;

    SELECT v_org_id AS organization_id, v_owner_id AS owner_employee_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_create_employee(
    IN p_org_id INT,
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_password_hash VARCHAR(255)
)
BEGIN
    -- Validate required inputs
    IF p_org_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Organization ID is required.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM organizations WHERE organization_id = p_org_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Organization does not exist.';
    END IF;
    IF p_name IS NULL OR p_name = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee name is required.';
    END IF;
    IF p_email IS NULL OR p_email = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee email is required.';
    END IF;
    IF p_password_hash IS NULL OR p_password_hash = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password hash is required.';
    END IF;

    -- Insert employee
    INSERT INTO employees (organization_id, name, email, password_hash, role)
    VALUES (p_org_id, p_name, p_email, p_password_hash, 'Employee');

    SELECT LAST_INSERT_ID() AS employee_id;
END$$
DELIMITER ;

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

-- Stored procedures: create records
DELIMITER $$
CREATE PROCEDURE sp_create_customer(
    IN p_org_id INT,
    IN p_employee_id INT,
    IN p_name VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_email VARCHAR(100)
)
BEGIN
    -- Validate required inputs
    IF p_org_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Organization ID is required.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM organizations WHERE organization_id = p_org_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Organization does not exist.';
    END IF;
    IF p_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee ID is required.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM employees WHERE employee_id = p_employee_id AND organization_id = p_org_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee does not belong to the organization.';
    END IF;
    IF p_name IS NULL OR p_name = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Name is required.';
    END IF;
    IF p_phone IS NULL OR p_phone = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phone is required.';
    END IF;

    -- Insert customer
    INSERT INTO customers (organization_id, created_by_employee_id, name, phone, email)
    VALUES (p_org_id, p_employee_id, p_name, p_phone, NULLIF(p_email, ''));

    SELECT LAST_INSERT_ID() AS customer_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_create_device(
    IN p_employee_id INT,
    IN p_customer_id INT,
    IN p_type VARCHAR(20),
    IN p_brand VARCHAR(50),
    IN p_model VARCHAR(50),
    IN p_serial_number VARCHAR(100)
)
BEGIN
    -- Validate required inputs
    IF p_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee ID is required.';
    END IF;
    IF p_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer ID is required.';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM employees e
        JOIN customers c ON c.organization_id = e.organization_id
        WHERE e.employee_id = p_employee_id AND c.customer_id = p_customer_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee and customer are not in the same organization.';
    END IF;
    IF p_type IS NULL OR p_type = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Device type is required.';
    END IF;
    IF p_brand IS NULL OR p_brand = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Brand is required.';
    END IF;
    IF p_model IS NULL OR p_model = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Model is required.';
    END IF;
    IF p_serial_number IS NULL OR p_serial_number = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Serial number is required.';
    END IF;

    -- Insert device
    INSERT INTO devices (customer_id, created_by_employee_id, type, brand, model, serial_number)
    VALUES (p_customer_id, p_employee_id, p_type, p_brand, p_model, p_serial_number);

    SELECT LAST_INSERT_ID() AS device_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_create_repair_job(
    IN p_employee_id INT,
    IN p_device_id INT,
    IN p_description TEXT,
    IN p_estimated_cost DECIMAL(10,2),
    IN p_status VARCHAR(20)
)
BEGIN
    DECLARE v_status VARCHAR(20);

    -- Validate required inputs
    IF p_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee ID is required.';
    END IF;
    IF p_device_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Device ID is required.';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM employees e
        JOIN customers c ON c.organization_id = e.organization_id
        JOIN devices d ON d.customer_id = c.customer_id
        WHERE e.employee_id = p_employee_id AND d.device_id = p_device_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee and device are not in the same organization.';
    END IF;
    IF p_description IS NULL OR p_description = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Description is required.';
    END IF;

    -- Normalize status
    IF p_status IS NULL OR p_status = '' THEN
        SET v_status = 'Pending';
    ELSEIF p_status IN ('Pending','Repairing','Ready','Delivered') THEN
        SET v_status = p_status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid status.';
    END IF;

    -- Insert repair job
    INSERT INTO repair_jobs (device_id, created_by_employee_id, description, estimated_cost, status)
    VALUES (p_device_id, p_employee_id, p_description, IFNULL(p_estimated_cost, 0.00), v_status);

    SELECT LAST_INSERT_ID() AS job_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_log_inventory_usage(
    IN p_employee_id INT,
    IN p_job_id INT,
    IN p_part_name VARCHAR(100),
    IN p_part_cost DECIMAL(10,2)
)
BEGIN
    -- Validate required inputs
    IF p_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee ID is required.';
    END IF;
    IF p_job_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Job ID is required.';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM employees e
        JOIN customers c ON c.organization_id = e.organization_id
        JOIN devices d ON d.customer_id = c.customer_id
        JOIN repair_jobs r ON r.device_id = d.device_id
        WHERE e.employee_id = p_employee_id AND r.job_id = p_job_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee and repair job are not in the same organization.';
    END IF;
    IF p_part_name IS NULL OR p_part_name = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Part name is required.';
    END IF;

    -- Insert inventory usage
    INSERT INTO inventory_usage (job_id, logged_by_employee_id, part_name, part_cost)
    VALUES (p_job_id, p_employee_id, p_part_name, IFNULL(p_part_cost, 0.00));

    SELECT LAST_INSERT_ID() AS usage_id;
END$$
DELIMITER ;

-- Stored procedures: update records
DELIMITER $$
CREATE PROCEDURE sp_update_repair_job_status(
    IN p_employee_id INT,
    IN p_job_id INT,
    IN p_status VARCHAR(20)
)
BEGIN
    DECLARE v_current_status VARCHAR(20);

    -- Validate required inputs
    IF p_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee ID is required.';
    END IF;
    IF p_job_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Job ID is required.';
    END IF;
    IF p_status IS NULL OR p_status = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Status is required.';
    END IF;
    IF p_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Use customer cancel procedure for Cancelled status.';
    END IF;
    IF p_status NOT IN ('Pending','Repairing','Ready','Delivered') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid status.';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM employees e
        JOIN customers c ON c.organization_id = e.organization_id
        JOIN devices d ON d.customer_id = c.customer_id
        JOIN repair_jobs r ON r.device_id = d.device_id
        WHERE e.employee_id = p_employee_id AND r.job_id = p_job_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee and repair job are not in the same organization.';
    END IF;

    SELECT status
    INTO v_current_status
    FROM repair_jobs
    WHERE job_id = p_job_id;

    IF v_current_status IN ('Cancelled','Delivered') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot update a cancelled or delivered job.';
    END IF;

    -- Update job status
    UPDATE repair_jobs
    SET status = p_status
    WHERE job_id = p_job_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_update_repair_job_description(
    IN p_employee_id INT,
    IN p_job_id INT,
    IN p_description TEXT
)
BEGIN
    -- Validate required inputs
    IF p_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee ID is required.';
    END IF;
    IF p_job_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Job ID is required.';
    END IF;
    IF p_description IS NULL OR p_description = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Description is required.';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM employees e
        JOIN customers c ON c.organization_id = e.organization_id
        JOIN devices d ON d.customer_id = c.customer_id
        JOIN repair_jobs r ON r.device_id = d.device_id
        WHERE e.employee_id = p_employee_id AND r.job_id = p_job_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee and repair job are not in the same organization.';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM repair_jobs
        WHERE job_id = p_job_id AND status = 'Cancelled'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot update a cancelled job.';
    END IF;

    -- Update job description
    UPDATE repair_jobs
    SET description = p_description
    WHERE job_id = p_job_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_cancel_repair_job_by_customer(
    IN p_customer_id INT,
    IN p_job_id INT
)
BEGIN
    DECLARE v_status VARCHAR(20);

    -- Validate required inputs
    IF p_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer ID is required.';
    END IF;
    IF p_job_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Job ID is required.';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM customers c
        JOIN devices d ON d.customer_id = c.customer_id
        JOIN repair_jobs r ON r.device_id = d.device_id
        WHERE c.customer_id = p_customer_id AND r.job_id = p_job_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Repair job not found for customer.';
    END IF;

    SELECT r.status
    INTO v_status
    FROM repair_jobs r
    JOIN devices d ON d.device_id = r.device_id
    WHERE r.job_id = p_job_id AND d.customer_id = p_customer_id;

    IF v_status <> 'Pending' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only pending jobs can be cancelled.';
    END IF;

    -- Cancel job
    UPDATE repair_jobs
    SET status = 'Cancelled'
    WHERE job_id = p_job_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$
DELIMITER ;

-- Stored procedures: read data
DELIMITER $$
CREATE PROCEDURE sp_get_repair_jobs(
    IN p_employee_id INT,
    IN p_status VARCHAR(20),
    IN p_org_id INT
)
BEGIN
    -- Validate required inputs
    IF p_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee ID is required.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM employees WHERE employee_id = p_employee_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee does not exist.';
    END IF;

    -- When p_org_id is provided, return all jobs in the organization (manager view)
    -- Otherwise, return only jobs created by the employee (technician view)
    IF p_status IS NULL OR p_status = '' THEN
        SELECT
            r.job_id,
            r.status,
            r.description,
            r.estimated_cost,
            r.final_cost,
            r.created_at,
            d.device_id,
            d.type,
            d.brand,
            d.model,
            c.customer_id,
            c.name AS customer_name,
            c.phone AS customer_phone
        FROM repair_jobs r
        JOIN devices d ON d.device_id = r.device_id
        JOIN customers c ON c.customer_id = d.customer_id
        WHERE (p_org_id IS NOT NULL AND c.organization_id = p_org_id)
           OR (p_org_id IS NULL AND r.created_by_employee_id = p_employee_id)
        ORDER BY r.created_at DESC;
    ELSEIF p_status IN ('Pending','Repairing','Ready','Delivered','Cancelled') THEN
        SELECT
            r.job_id,
            r.status,
            r.description,
            r.estimated_cost,
            r.final_cost,
            r.created_at,
            d.device_id,
            d.type,
            d.brand,
            d.model,
            c.customer_id,
            c.name AS customer_name,
            c.phone AS customer_phone
        FROM repair_jobs r
        JOIN devices d ON d.device_id = r.device_id
        JOIN customers c ON c.customer_id = d.customer_id
        WHERE (p_org_id IS NOT NULL AND c.organization_id = p_org_id AND r.status = p_status)
           OR (p_org_id IS NULL AND r.created_by_employee_id = p_employee_id AND r.status = p_status)
        ORDER BY r.created_at DESC;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid status.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_get_customer_full_for_employee(
    IN p_employee_id INT,
    IN p_customer_id INT
)
BEGIN
    -- Validate required inputs
    IF p_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee ID is required.';
    END IF;
    IF p_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer ID is required.';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM employees e
        JOIN customers c ON c.organization_id = e.organization_id
        WHERE e.employee_id = p_employee_id AND c.customer_id = p_customer_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee and customer are not in the same organization.';
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
    WHERE customer_id = p_customer_id;

    -- Result set 2: devices
    SELECT
        d.device_id,
        d.type,
        d.brand,
        d.model,
        d.serial_number,
        d.created_at
    FROM devices d
    WHERE d.customer_id = p_customer_id;

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
    WHERE d.customer_id = p_customer_id;

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
    WHERE d.customer_id = p_customer_id;
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
