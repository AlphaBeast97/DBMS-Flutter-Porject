# Database Context

## Purpose

MySQL schema and logic for TechFix, implemented with stored procedures, functions, and triggers.

## Status

Phase 1 complete.

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
