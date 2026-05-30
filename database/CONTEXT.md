# Database Context

## Purpose

MySQL schema and logic for TechFix, implemented with stored procedures, functions, and triggers.

## Status

Phase 1 complete; Phase 3 bug fix deployed.

## Notes

- Split scripts:
  - database/techfix.sql (schema)
  - database/techfix_routines.sql (functions + procedures)
  - database/techfix_triggers.sql (triggers)
  - database/techfix_seed.sql (seed data)
- Run order: database/run_order.md
- ER diagram: database/ERD.md
- Use Workbench-friendly delimiter blocks.
- Includes organizations, employees, and login/cancel routines.
- sp_get_repair_jobs bug fix (2026-05-30):
  - Deployed version had wrong org-level join returning all jobs to all employees.
  - Fixed to accept 3rd p_org_id param: org-wide when provided, personal when null.
  - SQL file updated to match the correct version.
