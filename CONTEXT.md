# Mini-Store Management System Context

## Purpose

This file is the single source of truth for the project. Before making changes, read this file to understand the current state, completed phases, decisions, and blockers.

## Stack

- Frontend: Flutter
- Middleware: Node.js + Express.js
- Database: MySQL on local port 3306

## Project Goal

Build a lightweight mini-store system with:

- CUSTOMER role for browsing products and placing orders
- ADMIN role for adding products
- Core entities: Products, Categories, Orders, Order_Items

## Phase 0 Agenda

1. Confirm the project scope, folder structure, and phase plan.
2. Review the proposal for any changes before creating implementation files.
3. Freeze the agreed context so later phases can build from it cleanly.

## Reference Files

- Proposal document: docs/PROJECT_PROPOSAL.md

## Schema Outline

Status: TO BE CONFIRMED IN PHASE 1

Planned entities:

- categories
- products
- orders
- order_items

## API Endpoint Table

Status: ALL TODO UNTIL PHASE 2

| Method | Route         | Purpose                               | Status  |
| ------ | ------------- | ------------------------------------- | ------- |
| GET    | /api/products | Fetch all products with category name | ⬜ TODO |
| POST   | /api/products | Add a new product                     | ⬜ TODO |
| POST   | /api/orders   | Create order with items               | ⬜ TODO |

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
