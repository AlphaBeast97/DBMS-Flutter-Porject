-- TechFix triggers
-- Run after techfix_routines.sql

USE techfix;

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
