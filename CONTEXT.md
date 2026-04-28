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

Status: TO BE CONFIRMED IN PHASE 1

Planned entities:

- customers (customer_id, name, phone, email)
- devices (device_id, customer_id FK, type, brand, model, serial_number)
- repair_jobs (job_id, device_id FK, description, estimated_cost, status, created_at)
- inventory_usage (usage_id, job_id FK, part_name, part_cost)

## API Endpoint Table

Status: ALL TODO UNTIL PHASE 2

| Method | Route                    | Purpose                                     | Status  |
| ------ | ------------------------ | ------------------------------------------- | ------- |
| POST   | /api/customers           | Register a new customer                     | ⬜ TODO |
| POST   | /api/devices             | Check in a device for repair                | ⬜ TODO |
| POST   | /api/repair-jobs         | Create a repair job                         | ⬜ TODO |
| GET    | /api/repair-jobs         | Fetch all repair jobs with status filtering | ⬜ TODO |
| PUT    | /api/repair-jobs/:job_id | Update job status or final cost             | ⬜ TODO |
| POST   | /api/inventory-usage     | Log parts used in a repair                  | ⬜ TODO |
| GET    | /api/customers/:id       | Fetch customer with all associated devices  | ⬜ TODO |

## Phase Tracker

- [ ] Phase 0: Project Setup & Context File
- [ ] Phase 1: MySQL Schema & Seeding
- [ ] Phase 2: Express API
- [ ] Phase 3: Flutter UI & API Integration
- [ ] Phase 4: Polish & Basic Error Handling

## Decisions Log

-

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
- Awaiting confirmation before implementation work begins

### Phase 1

- Pending

### Phase 2

- Pending

### Phase 3

- Pending

### Phase 4

- Pending

## Final Summary

Status: IN PROGRESS
