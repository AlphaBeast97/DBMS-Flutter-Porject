# Database Agent Notes

## Architecture
- MySQL 8.0+ with InnoDB engine for transactional integrity and FK enforcement.
- All business logic in stored procedures/functions and triggers.
- Schema normalized to 3NF with 6 tables, FK constraints, and ENUM domains.

## Scripts (run in order)
1. `techfix.sql` — Schema: 6 tables, FKs, ENUMs, indexes
2. `techfix_routines.sql` — 1 function (`fn_parts_total`) + 12 stored procedures
3. `techfix_triggers.sql` — 1 trigger (`tr_repair_jobs_delivered_cost`)
4. `techfix_seed.sql` — Demo data: 1 org, 4 employees, 5 customers, 8 devices, 10 jobs, 7 usage entries

## Conventions
- Use strict, readable SQL with clear section comments.
- Prefer MySQL Workbench-friendly scripts (single `.sql` file, `DELIMITER $$` blocks).
- Keep schema normalized and enforce FK constraints.
- `ON DELETE RESTRICT` on employee FKs — employees who created records cannot be deleted.
- `ON DELETE CASCADE` on org/customer/device FKs — cascading deletes where appropriate.

## Key Patterns
- **Org-scope validation**: Every write procedure validates employee + target record are in the same org via JOIN chains.
- **Case-insensitive auth**: Login procedures use `utf8mb4_uca1400_ai_ci` collation.
- **Idempotent customer creation**: `sp_create_customer` returns existing ID if email already in org.
- **Terminal state protection**: `Delivered` and `Cancelled` jobs cannot be updated.
- **Trigger**: `tr_repair_jobs_delivered_cost` auto-calculates `final_cost` on status → `Delivered`.

## Documentation
- `database/DATABASE_DOCUMENTATION.md` — Full DBMS report: Intro, Domain, Problem, Novelty, ERD, constraints, DBMS features catalog, use-case diagram, sample query results, trigger details, procedure catalog, seed walkthrough, and conclusion.
- Root `DOCUMENTATION.md` — Architecture overview with smaller ERD and procedure list.
