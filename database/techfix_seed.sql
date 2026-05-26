-- TechFix seed data (run after schema/routines)
-- Designed for MySQL Workbench execution

USE techfix;

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
