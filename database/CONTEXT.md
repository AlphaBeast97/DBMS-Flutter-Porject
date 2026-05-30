# Database Context

## Purpose
MySQL 8 schema and business logic for TechFix. All data logic is in stored procedures, functions, and triggers.

## Status
Phase 1 complete; Phase 3 bug fix deployed; Phase 5 documentation complete.

## File Layout
| File | Purpose | Run Order |
|------|---------|-----------|
| `techfix.sql` | Schema: 6 tables, FKs, ENUMs, indexes | 1st |
| `techfix_routines.sql` | 1 function + 12 stored procedures | 2nd |
| `techfix_triggers.sql` | 1 trigger: `tr_repair_jobs_delivered_cost` | 3rd |
| `techfix_seed.sql` | Demo data via stored procedure calls | 4th |

## Schema (6 tables)
- `organizations` — org scope for all data
- `employees` — `role` ENUM('Owner','Employee'), unique email, FK → organizations
- `customers` — unique email (nullable), FK → organizations + employees
- `devices` — `type` ENUM('Laptop','Mobile','Console','Tablet','Other'), FK → customers + employees
- `repair_jobs` — `status` ENUM('Pending','Repairing','Ready','Delivered','Cancelled'), FK → devices + employees
- `inventory_usage` — FK → repair_jobs + employees

## Routines (1 function + 12 procedures)
- `fn_parts_total(job_id)` → DECIMAL — sums part_cost for a job (deterministic)
- **Setup**: `sp_create_owner`, `sp_create_employee`
- **Auth**: `sp_employee_login`, `sp_customer_login` (case-insensitive collation)
- **Create**: `sp_create_customer` (idempotent by email), `sp_create_device`, `sp_create_repair_job`, `sp_log_inventory_usage`
- **Update**: `sp_update_repair_job_status` (blocks Cancelled/Delivered terminal states), `sp_update_repair_job_description` (blocks Cancelled), `sp_cancel_repair_job_by_customer` (Pending only)
- **Read**: `sp_get_repair_jobs` (3 params: emp_id, status, org_id — org_id=manager view, null=technician), `sp_get_customer_full_for_employee` (4 result sets), `sp_get_customer_full_for_customer` (4 result sets)

## Trigger
- `tr_repair_jobs_delivered_cost`: BEFORE UPDATE on repair_jobs. When status changes to 'Delivered', auto-sets `final_cost = fn_parts_total(job_id)`.

## Key Rules
- ON DELETE RESTRICT on all employee FKs — can't delete employees with records
- All write procedures validate org-scope via JOIN chains
- Status transitions enforce terminal state protection
- Only customers can cancel (Pending only); employees cannot set Cancelled

## Seed Data
1 org (TechFix Lahore), 1 owner + 3 employees, 5 customers, 8 devices, 10 repair jobs, 7 inventory usage entries. 3 jobs marked Delivered to demonstrate trigger.

## Documentation
- `database/DATABASE_DOCUMENTATION.md` — Full documentation with ERD, EERD, state machine, table specs, procedure catalog, trigger details, seed walkthrough, call sequences, and design decisions.
