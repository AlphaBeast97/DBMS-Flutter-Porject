-- TechFix database schema, routines, trigger, and seed data
-- Designed for MySQL Workbench execution

-- Core database setup
DROP DATABASE IF EXISTS techfix;
CREATE DATABASE techfix;
USE techfix;

-- Table: organizations
CREATE TABLE organizations (
    organization_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: employees
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    organization_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Owner','Employee') NOT NULL DEFAULT 'Employee',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_employees_email (email),
    CONSTRAINT fk_employees_org
        FOREIGN KEY (organization_id)
        REFERENCES organizations(organization_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: customers
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    organization_id INT NOT NULL,
    created_by_employee_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_customers_email (email),
    CONSTRAINT fk_customers_org
        FOREIGN KEY (organization_id)
        REFERENCES organizations(organization_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_customers_employee
        FOREIGN KEY (created_by_employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: devices
CREATE TABLE devices (
    device_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    created_by_employee_id INT NOT NULL,
    type ENUM('Laptop','Mobile','Console','Tablet','Other') NOT NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    serial_number VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_devices_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_devices_employee
        FOREIGN KEY (created_by_employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: repair_jobs
CREATE TABLE repair_jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    device_id INT NOT NULL,
    created_by_employee_id INT NOT NULL,
    description TEXT NOT NULL,
    estimated_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status ENUM('Pending','Repairing','Ready','Delivered','Cancelled') NOT NULL DEFAULT 'Pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    final_cost DECIMAL(10,2) NULL,
    CONSTRAINT fk_repair_jobs_device
        FOREIGN KEY (device_id)
        REFERENCES devices(device_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_repair_jobs_employee
        FOREIGN KEY (created_by_employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: inventory_usage
CREATE TABLE inventory_usage (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    logged_by_employee_id INT NOT NULL,
    part_name VARCHAR(100) NOT NULL,
    part_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_usage_job
        FOREIGN KEY (job_id)
        REFERENCES repair_jobs(job_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_inventory_usage_employee
        FOREIGN KEY (logged_by_employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
CREATE PROCEDURE sp_create_organization(
    IN p_name VARCHAR(100)
)
BEGIN
    -- Validate required inputs
    IF p_name IS NULL OR p_name = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Organization name is required.';
    END IF;

    -- Insert organization
    INSERT INTO organizations (name)
    VALUES (p_name);

    SELECT LAST_INSERT_ID() AS organization_id;
END$$
DELIMITER ;

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
    WHERE email = p_email AND password_hash = p_password_hash;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid credentials.';
    END IF;

    SELECT employee_id, organization_id, name, email, role, created_at
    FROM employees
    WHERE email = p_email AND password_hash = p_password_hash;
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
    WHERE email = p_email;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found.';
    END IF;

    SELECT customer_id, organization_id, name, phone, email, created_at
    FROM customers
    WHERE email = p_email;
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
    IN p_status VARCHAR(20)
)
BEGIN
    -- Validate required inputs
    IF p_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee ID is required.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM employees WHERE employee_id = p_employee_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee does not exist.';
    END IF;

    -- Optional status filter for dashboard views
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
        JOIN employees e ON e.organization_id = c.organization_id
        WHERE e.employee_id = p_employee_id
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
        JOIN employees e ON e.organization_id = c.organization_id
        WHERE e.employee_id = p_employee_id AND r.status = p_status
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
    WHERE email = p_email;

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

-- Trigger: auto-calculate final_cost when status becomes Delivered
DELIMITER $$
CREATE TRIGGER tr_repair_jobs_delivered_cost
BEFORE UPDATE ON repair_jobs
FOR EACH ROW
BEGIN
    -- Only calculate final cost when job is marked Delivered
    IF NEW.status = 'Delivered' AND OLD.status <> 'Delivered' THEN
        SET NEW.final_cost = fn_parts_total(NEW.job_id);
    END IF;
END$$
DELIMITER ;

-- Seed data using stored procedures
-- Organization and owner (hash uses SHA2 for seed demo)
CALL sp_create_owner('TechFix Lahore', 'Owner Admin', 'owner@techfix.com', SHA2('Owner123', 256));

-- Employees
CALL sp_create_employee(1, 'Bilal Hussain', 'bilal.tech@techfix.com', SHA2('Tech123', 256));
CALL sp_create_employee(1, 'Hira Khan', 'hira.tech@techfix.com', SHA2('Tech123', 256));
CALL sp_create_employee(1, 'Usman Ali', 'usman.tech@techfix.com', SHA2('Tech123', 256));

-- Customers
CALL sp_create_customer(1, 1, 'Ayesha Malik', '03001234567', 'ayesha@example.com');
CALL sp_create_customer(1, 2, 'Bilal Ahmed', '03019876543', 'bilal@example.com');
CALL sp_create_customer(1, 2, 'Sara Iqbal', '03331234567', 'sara@example.com');
CALL sp_create_customer(1, 3, 'Junaid Ahmad', '03121234567', 'junaid@example.com');
CALL sp_create_customer(1, 3, 'Mohsin Qureshi', '03211234567', 'mohsin@example.com');

-- Devices (assumes customer IDs 1-5 from fresh insert order)
CALL sp_create_device(2, 1, 'Laptop', 'Dell', 'Inspiron 15', 'DL-INSP-001');
CALL sp_create_device(2, 1, 'Mobile', 'Samsung', 'Galaxy S20', 'SS-S20-002');
CALL sp_create_device(2, 2, 'Console', 'Sony', 'PS4', 'SN-PS4-003');
CALL sp_create_device(2, 2, 'Laptop', 'HP', 'Pavilion', 'HP-PAV-004');
CALL sp_create_device(3, 3, 'Mobile', 'Apple', 'iPhone 12', 'AP-IP12-005');
CALL sp_create_device(3, 4, 'Laptop', 'Lenovo', 'ThinkPad X1', 'LN-TPX1-006');
CALL sp_create_device(3, 5, 'Tablet', 'Apple', 'iPad Air', 'AP-IPAD-007');
CALL sp_create_device(2, 5, 'Mobile', 'Xiaomi', 'Mi 11', 'XM-MI11-008');

-- Repair jobs (assumes device IDs 1-8 from fresh insert order)
CALL sp_create_repair_job(2, 1, 'Battery drains quickly', 4500.00, 'Pending');
CALL sp_create_repair_job(2, 2, 'Screen flicker issue', 8000.00, 'Repairing');
CALL sp_create_repair_job(2, 3, 'HDMI port not working', 6000.00, 'Ready');
CALL sp_create_repair_job(2, 4, 'Keyboard keys stuck', 3500.00, 'Pending');
CALL sp_create_repair_job(3, 5, 'Camera not focusing', 5000.00, 'Repairing');
CALL sp_create_repair_job(3, 6, 'Overheating during use', 7000.00, 'Pending');
CALL sp_create_repair_job(3, 7, 'Touch not responding', 6500.00, 'Ready');
CALL sp_create_repair_job(2, 8, 'Charging port loose', 3000.00, 'Pending');
CALL sp_create_repair_job(2, 1, 'Wi-Fi disconnects randomly', 4000.00, 'Ready');
CALL sp_create_repair_job(2, 2, 'Speaker distortion', 2500.00, 'Repairing');

-- Inventory usage
CALL sp_log_inventory_usage(2, 1, 'Battery pack', 3200.00);
CALL sp_log_inventory_usage(2, 2, 'Display cable', 1500.00);
CALL sp_log_inventory_usage(2, 2, 'LCD panel', 4200.00);
CALL sp_log_inventory_usage(2, 3, 'HDMI port', 800.00);
CALL sp_log_inventory_usage(3, 5, 'Camera module', 3000.00);
CALL sp_log_inventory_usage(3, 7, 'Touch panel', 2800.00);
CALL sp_log_inventory_usage(2, 9, 'Wi-Fi card', 1200.00);

-- Update some jobs to Delivered to trigger final cost calculation
CALL sp_update_repair_job_status(2, 3, 'Delivered');
CALL sp_update_repair_job_status(3, 7, 'Delivered');
CALL sp_update_repair_job_status(2, 9, 'Delivered');
