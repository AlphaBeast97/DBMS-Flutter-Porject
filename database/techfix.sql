-- TechFix database schema, routines, trigger, and seed data
-- Designed for MySQL Workbench execution

-- Core database setup
DROP DATABASE IF EXISTS techfix;
CREATE DATABASE techfix;
USE techfix;

-- Table: customers
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_customers_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: devices
CREATE TABLE devices (
    device_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    type ENUM('Laptop','Mobile','Console','Tablet','Other') NOT NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    serial_number VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_devices_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: repair_jobs
CREATE TABLE repair_jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    device_id INT NOT NULL,
    description TEXT NOT NULL,
    estimated_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status ENUM('Pending','Repairing','Ready','Delivered') NOT NULL DEFAULT 'Pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    final_cost DECIMAL(10,2) NULL,
    CONSTRAINT fk_repair_jobs_device
        FOREIGN KEY (device_id)
        REFERENCES devices(device_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: inventory_usage
CREATE TABLE inventory_usage (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    part_name VARCHAR(100) NOT NULL,
    part_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_usage_job
        FOREIGN KEY (job_id)
        REFERENCES repair_jobs(job_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
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

-- Stored procedures: create records
DELIMITER $$
CREATE PROCEDURE sp_create_customer(
    IN p_name VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_email VARCHAR(100)
)
BEGIN
    -- Validate required inputs
    IF p_name IS NULL OR p_name = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Name is required.';
    END IF;
    IF p_phone IS NULL OR p_phone = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phone is required.';
    END IF;

    -- Insert customer
    INSERT INTO customers (name, phone, email)
    VALUES (p_name, p_phone, NULLIF(p_email, ''));

    SELECT LAST_INSERT_ID() AS customer_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_create_device(
    IN p_customer_id INT,
    IN p_type VARCHAR(20),
    IN p_brand VARCHAR(50),
    IN p_model VARCHAR(50),
    IN p_serial_number VARCHAR(100)
)
BEGIN
    -- Validate required inputs
    IF p_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer ID is required.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer does not exist.';
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
    INSERT INTO devices (customer_id, type, brand, model, serial_number)
    VALUES (p_customer_id, p_type, p_brand, p_model, p_serial_number);

    SELECT LAST_INSERT_ID() AS device_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_create_repair_job(
    IN p_device_id INT,
    IN p_description TEXT,
    IN p_estimated_cost DECIMAL(10,2),
    IN p_status VARCHAR(20)
)
BEGIN
    DECLARE v_status VARCHAR(20);

    -- Validate required inputs
    IF p_device_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Device ID is required.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM devices WHERE device_id = p_device_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Device does not exist.';
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
    INSERT INTO repair_jobs (device_id, description, estimated_cost, status)
    VALUES (p_device_id, p_description, IFNULL(p_estimated_cost, 0.00), v_status);

    SELECT LAST_INSERT_ID() AS job_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_log_inventory_usage(
    IN p_job_id INT,
    IN p_part_name VARCHAR(100),
    IN p_part_cost DECIMAL(10,2)
)
BEGIN
    -- Validate required inputs
    IF p_job_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Job ID is required.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM repair_jobs WHERE job_id = p_job_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Repair job does not exist.';
    END IF;
    IF p_part_name IS NULL OR p_part_name = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Part name is required.';
    END IF;

    -- Insert inventory usage
    INSERT INTO inventory_usage (job_id, part_name, part_cost)
    VALUES (p_job_id, p_part_name, IFNULL(p_part_cost, 0.00));

    SELECT LAST_INSERT_ID() AS usage_id;
END$$
DELIMITER ;

-- Stored procedures: update records
DELIMITER $$
CREATE PROCEDURE sp_update_repair_job_status(
    IN p_job_id INT,
    IN p_status VARCHAR(20)
)
BEGIN
    -- Validate required inputs
    IF p_job_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Job ID is required.';
    END IF;
    IF p_status IS NULL OR p_status = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Status is required.';
    END IF;
    IF p_status NOT IN ('Pending','Repairing','Ready','Delivered') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid status.';
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
    IN p_job_id INT,
    IN p_description TEXT
)
BEGIN
    -- Validate required inputs
    IF p_job_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Job ID is required.';
    END IF;
    IF p_description IS NULL OR p_description = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Description is required.';
    END IF;

    -- Update job description
    UPDATE repair_jobs
    SET description = p_description
    WHERE job_id = p_job_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$
DELIMITER ;

-- Stored procedures: read data
DELIMITER $$
CREATE PROCEDURE sp_get_repair_jobs(
    IN p_status VARCHAR(20)
)
BEGIN
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
        ORDER BY r.created_at DESC;
    ELSEIF p_status IN ('Pending','Repairing','Ready','Delivered') THEN
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
        WHERE r.status = p_status
        ORDER BY r.created_at DESC;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid status.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_get_customer_full(
    IN p_customer_id INT
)
BEGIN
    -- Validate required inputs
    IF p_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer ID is required.';
    END IF;

    -- Result set 1: customer
    SELECT
        customer_id,
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
-- Customers
CALL sp_create_customer('Ayesha Malik', '03001234567', 'ayesha@example.com');
CALL sp_create_customer('Bilal Hussain', '03019876543', 'bilal@example.com');
CALL sp_create_customer('Hira Khan', '03121234567', 'hira@example.com');
CALL sp_create_customer('Usman Ali', '03211234567', 'usman@example.com');
CALL sp_create_customer('Sara Iqbal', '03331234567', 'sara@example.com');

-- Devices (assumes customer IDs 1-5 from fresh insert order)
CALL sp_create_device(1, 'Laptop', 'Dell', 'Inspiron 15', 'DL-INSP-001');
CALL sp_create_device(1, 'Mobile', 'Samsung', 'Galaxy S20', 'SS-S20-002');
CALL sp_create_device(2, 'Console', 'Sony', 'PS4', 'SN-PS4-003');
CALL sp_create_device(2, 'Laptop', 'HP', 'Pavilion', 'HP-PAV-004');
CALL sp_create_device(3, 'Mobile', 'Apple', 'iPhone 12', 'AP-IP12-005');
CALL sp_create_device(4, 'Laptop', 'Lenovo', 'ThinkPad X1', 'LN-TPX1-006');
CALL sp_create_device(5, 'Tablet', 'Apple', 'iPad Air', 'AP-IPAD-007');
CALL sp_create_device(5, 'Mobile', 'Xiaomi', 'Mi 11', 'XM-MI11-008');

-- Repair jobs (assumes device IDs 1-8 from fresh insert order)
CALL sp_create_repair_job(1, 'Battery drains quickly', 4500.00, 'Pending');
CALL sp_create_repair_job(2, 'Screen flicker issue', 8000.00, 'Repairing');
CALL sp_create_repair_job(3, 'HDMI port not working', 6000.00, 'Ready');
CALL sp_create_repair_job(4, 'Keyboard keys stuck', 3500.00, 'Pending');
CALL sp_create_repair_job(5, 'Camera not focusing', 5000.00, 'Repairing');
CALL sp_create_repair_job(6, 'Overheating during use', 7000.00, 'Pending');
CALL sp_create_repair_job(7, 'Touch not responding', 6500.00, 'Ready');
CALL sp_create_repair_job(8, 'Charging port loose', 3000.00, 'Pending');
CALL sp_create_repair_job(1, 'Wi-Fi disconnects randomly', 4000.00, 'Ready');
CALL sp_create_repair_job(2, 'Speaker distortion', 2500.00, 'Repairing');

-- Inventory usage
CALL sp_log_inventory_usage(1, 'Battery pack', 3200.00);
CALL sp_log_inventory_usage(2, 'Display cable', 1500.00);
CALL sp_log_inventory_usage(2, 'LCD panel', 4200.00);
CALL sp_log_inventory_usage(3, 'HDMI port', 800.00);
CALL sp_log_inventory_usage(5, 'Camera module', 3000.00);
CALL sp_log_inventory_usage(7, 'Touch panel', 2800.00);
CALL sp_log_inventory_usage(9, 'Wi-Fi card', 1200.00);

-- Update some jobs to Delivered to trigger final cost calculation
CALL sp_update_repair_job_status(3, 'Delivered');
CALL sp_update_repair_job_status(7, 'Delivered');
CALL sp_update_repair_job_status(9, 'Delivered');
