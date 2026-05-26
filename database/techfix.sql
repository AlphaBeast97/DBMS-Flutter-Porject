-- TechFix database schema, routines, and trigger
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
