# TechFix – Digital Repair Workflow Manager Context

## Purpose

This file is the single source of truth for the project. Before making changes, read this file to understand the current state, completed phases, decisions, and blockers.

## Stack

- Frontend: Flutter
- Middleware: Node.js + Express.js
- Database: MySQL on local port 3306

## Project Goal

Build a centralized repair workflow management system for local repair shops:

- TECHNICIAN role to update job status and log repairs
- ADMIN/MANAGER role to view dashboards and manage inventory
- CUSTOMER role to check repair status
- Core entities: Customers, Devices, Repair_Jobs, Inventory_Usage

## Phase 0 Agenda

1. Confirm the project scope, folder structure, and phase plan.
2. Review the proposal for any changes before creating implementation files.
3. Freeze the agreed context so later phases can build from it cleanly.

## Reference Files

- Proposal document: docs/PROJECT_PROPOSAL.md

## Schema Outline

Status: CONFIRMED IN PHASE 1

Confirmed entities:

- organizations (organization_id, name, created_at)
- employees (employee_id, organization_id FK, name, email, password_hash, role, created_at)
- customers (customer_id, organization_id FK, created_by_employee_id FK, name, phone, email, created_at)
- devices (device_id, customer_id FK, created_by_employee_id FK, type, brand, model, serial_number, created_at)
- repair_jobs (job_id, device_id FK, created_by_employee_id FK, description, estimated_cost, status, created_at, final_cost)
- inventory_usage (usage_id, job_id FK, logged_by_employee_id FK, part_name, part_cost, created_at)

## API Endpoint Table

Status: ALL TODO UNTIL PHASE 2

| Method | Route                    | Purpose                                     | Status  |
| ------ | ------------------------ | ------------------------------------------- | ------- |
| POST   | /api/customers           | Register a new customer                     | ⬜ TODO |
| POST   | /api/devices             | Check in a device for repair                | ⬜ TODO |
| POST   | /api/repair-jobs         | Create a repair job                         | ⬜ TODO |
| GET    | /api/repair-jobs         | Fetch all repair jobs with status filtering | ✅ DONE |
| PUT    | /api/repair-jobs/:job_id | Update job status or final cost             | ⬜ TODO |
| POST   | /api/inventory-usage     | Log parts used in a repair                  | ⬜ TODO |
| GET    | /api/customers/:id       | Fetch customer with all associated devices  | ⬜ TODO |

## Phase Tracker

- [x] Phase 0: Project Setup & Context File
- [x] Phase 1: MySQL Schema & Seeding
- [ ] Phase 2: Express API (started: skeleton only)
- [ ] Phase 3: Flutter UI & API Integration
- [ ] Phase 4: Polish & Basic Error Handling

## Decisions Log

- All data operations use stored procedures/functions in MySQL; backend calls routines only.
- Added root and per-part AGENTS.md + CONTEXT.md (backend, database, frontend).
- Introduced organizations and employees with role-based access; customers can cancel only when status is Pending.

## Blockers

- None

## How to Use This File

- Read this file first in every new session before changing code.
- Update it at the end of each completed phase.
- Keep it concise and factual.
- Record only confirmed decisions, not guesses.
- Use it to avoid duplicating work across sessions.
- Start each new phase by confirming the scope and proposal before writing files.

## Phase Notes

### Phase 0

- Folder structure proposed
- CONTEXT.md template prepared
- Phase confirmed and completed

### Phase 1

- MySQL schema created with FK constraints, stored procedures, functions, and trigger
- Seed data added via stored procedures
- Revised schema to include organizations, employees, basic login routines, and Cancelled status

### Phase 2

- Express app wired with error handling and 404 response.
- MySQL pool and stored-procedure helper added.
- GET /api/repair-jobs implemented using stored procedure with validation.
- Tests added with Node test runner + supertest.

### Phase 3

- Pending

### Phase 4

- Pending

## Final Summary

Status: PHASE 2 IN PROGRESS (GET /api/repair-jobs implemented)
