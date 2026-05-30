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

Status: IMPLEMENTED IN PHASE 2

| Method | Route                            | Purpose                                     | Status  |
| ------ | -------------------------------- | ------------------------------------------- | ------- |
| POST   | /api/auth/employee               | Employee login via basic auth               | ✅ DONE |
| POST   | /api/auth/customer               | Customer login via basic auth               | ✅ DONE |
| POST   | /api/employees/owner             | Create owner + organization (initial setup) | ✅ DONE |
| POST   | /api/employees                   | Create employee (owner-protected)           | ✅ DONE |
| POST   | /api/customers                   | Register a new customer                     | ✅ DONE |
| GET    | /api/customers/:id               | Fetch customer with all associated devices  | ✅ DONE |
| GET    | /api/customers/me                | Get authenticated customer's own data       | ✅ DONE |
| POST   | /api/devices                     | Check in a device for repair                | ✅ DONE |
| POST   | /api/repair-jobs                 | Create a repair job                         | ✅ DONE |
| GET    | /api/repair-jobs                 | Fetch all repair jobs with status filtering | ✅ DONE |
| PUT    | /api/repair-jobs/:job_id         | Update job status                           | ✅ DONE |
| PUT    | /api/repair-jobs/:id/description | Update job description                      | ✅ DONE |
| POST   | /api/repair-jobs/:id/cancel      | Customer cancels pending job                | ✅ DONE |
| POST   | /api/inventory-usage             | Log parts used in a repair                  | ✅ DONE |

## Phase Tracker

- [x] Phase 0: Project Setup & Context File
- [x] Phase 1: MySQL Schema & Seeding
- [x] Phase 2: Express API
- [x] Phase 3: Flutter UI & API Integration (completed)
- [x] Phase 4: Claude Design UI Implementation (completed)
- [ ] Phase 5: UX Polish & Bug Fixes (in progress)

## Decisions Log

- All data operations use stored procedures/functions in MySQL; backend calls routines only.
- Added root and per-part AGENTS.md + CONTEXT.md (backend, database, frontend).
- Introduced organizations and employees with role-based access; customers can cancel only when status is Pending.
- sp_get_repair_jobs accepts optional 3rd p_org_id param: when provided returns org-wide jobs (manager view), when null filters by created_by_employee_id (technician view).
- Frontend TechFixApi.getRepairJobs() accepts optional organizationId to support the manager dashboard.
- Login screen split into 3 tabs (Owner/Employee/Customer) with Owner tab offering both Sign In and Sign Up (create org + owner account).

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
- Patch script added for routine fixes: database/techfix_routines_patch.sql

### Phase 2

- Express app wired with error handling and 404 response.
- MySQL pool and stored-procedure helper added (single + multi result sets).
- API routes/controllers implemented for customers, devices, repair jobs, inventory usage.
- Auth endpoints added for employees and customers using Basic auth headers.
- Input validation helpers added for required fields and numeric parsing.
- Tests added with Node test runner + supertest, plus optional real DB integration test (RUN_DB_TESTS=1).
- Access control middleware added (Owner/Employee/Customer roles).
- Organizations and employees management endpoints added.
- Additional endpoints for job description updates and customer cancellations.

### Phase 3

- Flutter app scaffolded with themed UI and home shell.
- Screens added for customer status, technician console, and manager overview.
- TechFixApi service layer added with full endpoint coverage (auth, CRUD, updates).
- AppSession state management added for authentication and credentials.
- All screens wired to real API endpoints (no mock data in use).
- Fixed sp_get_repair_jobs to filter by created_by_employee_id for technicians.
- Added p_org_id param to sp_get_repair_jobs for org-wide manager dashboard view.
- Manager screen passes organization_id to API to fetch all jobs for dashboard.
- Mock data file preserved but unused.
- Login screen redesigned with 3 tabs (Owner/Employee/Customer).
- Owner tab has Sign In/Sign Up toggle — Sign Up calls POST /api/employees/owner to create org + owner account.
- TechFixApi.createOwner() added for public owner registration.
- AppSession.isOwner getter added.

### Phase 4

- Claude Design system fully implemented across all screens.
- Phase 4a: Design System Components — Avatar, Field, StatusBadge, TechFixDialog, Sheet, EmptyState, LoadingState/SkeletonCard, ErrorState, Pill widgets created. StatCard, SectionHeader, AppBackground, JobCard, InventoryCard refactored to match design tokens.
- Phase 4b: Login screen redesigned with Brandmark, role icons/blurbs per tab, Field widget inputs, SegmentedButton replacement, improved spacing.
- Phase 4c: Customer screen redesigned with profile card (avatar + phone + member pill), interactive device cards with StatusBadge, DeviceJobsDialog styled per design, loading/empty/error states.
- Phase 4d: Technician console redesigned with FAB + header icon, filter chips (All/Pending/Repairing), multi-step CreateJobSheet (3 steps with stepper), LogPartSheet with job radio selector, StatusRadioDialog with styled radio options, EditDescDialog with description + cost, loading/empty/error states.
- Phase 4e: Manager dashboard redesigned with CustomPaint donut chart (SVG-style), KPI stat cards (active staff, avg turnaround), revenue card with finalized/estimated amounts + dual progress bar toward target, AddStaffDialog. fl_chart dependency no longer used (replaced by CustomPaint).
- All API calls preserved (no breaking data flow changes).
- Color tokens: Coral #F26B4A, Teal #2A9D8F, Sky #2D7BD1, Clay #B86B4B, Ink #141414, Cream #F7F3ED, Beige #EFE7DA, Grey #9A958C. Additional derived tokens: line, line2, muted, faint.
- Status values normalized to lowercase in StatusBadge (case-insensitive matching).
- New widget files added: avatar.dart, field.dart, status_badge.dart, techfix_dialog.dart, sheet.dart, empty_state.dart, loading_state.dart, error_state.dart, pill.dart.
- Refactored widget files: stat_card.dart, section_header.dart, app_background.dart, job_card.dart, inventory_card.dart.

### Phase 5 (in progress)

- Removed all 88 hardcoded `fontFamily: 'SpaceGrotesk'` from TextStyles — theme default now covers it via `GoogleFonts.spaceGroteskTextTheme`.
- Login screen: wrapped in Scaffold with `resizeToAvoidBottomInset: true` for keyboard handling; added Enter-to-submit via `textInputAction`/`onSubmitted` on all Field inputs.
- Customer screen: fixed overflow by wrapping Pill in Flexible, shortened member date with formatter.
- Technician screen: fixed setState async bug — `_refresh()` now splits assignment from setState; dialogs close after create job / log part.
- JobCard: fixed IntrinsicHeight overflow by restructuring Card — AnimatedSize placed outside IntrinsicHeight.
- Backend: fixed `getRepairJobs` 500 error — always passes 3 params `[employeeId, status, organizationId]`; fixed status update 400 error by normalizing to PascalCase before WRITE_STATUSES check.
- Fixed "logged by unknown" — added LEFT JOIN employees + `e.name AS employee_name` to both `sp_get_customer_full_*` stored procedures.
- Fixed AddStaffDialog/LogPartSheet buttons always disabled — added `setState((){})` to onChanged callbacks.
- Manager screen: removed Active Staff / Avg Turnaround KPIs, added paginated jobs list (latest 5, "Show more") with inventory usage; wrapped LoadingState in SingleChildScrollView.
- Fixed LoadingState overflow — wrapped Column in SingleChildScrollView.
- **Input validation**: Added `_isValidEmail` regex + inline checks in all login submit methods (email format, password required, min 6 chars, required fields).
- **Keyboard types**: Added `TextInputType.emailAddress` on email fields, `TextInputType.phone` on phone, `TextInputType.number` on cost fields across all screens.
- **Password obscuring**: Added `obscureText: true` on all password fields.
- **Validation getters**: Updated `_valid` in CreateJobSheet (cost must be parseable as double), LogPartSheet (cost must be parseable), AddStaffDialog (email regex + password ≥ 6 chars).
- **Toast system**: Created `lib/widgets/toast.dart` with `showToast()` utility — floating dark/coral snackbar from bottom with rounded corners. Replaced all 12 raw SnackBar calls across technician, manager, and customer screens.
- **Deleted dead files**: Removed `mock_data.dart`, `models/customer.dart`, `models/device.dart`, `widgets/inventory_card.dart`, empty `lib/data/` directory.
- **Screen modularization**: Split `technician_screen.dart` (1241→478 lines) into 5 files under `lib/screens/technician/` (StatusRadioDialog, EditDescDialog, CreateJobSheet, LogPartSheet). Split `manager_screen.dart` (629→438 lines) into 2 files under `lib/screens/manager/` (AddStaffDialog, DonutPainter+LegendDot). Split customer_status_screen.dart 333-line build into 7 focused private methods.
- **Shared utils**: Created `lib/shared/utils.dart` with `signOut(context)`, `fmtMoney()`, `emailRegex`, `minPasswordLength` — replaced 3 duplicate signOut blocks, 2 duplicate fmtMoney, and 3 inline email regexes.
- **FilterChip**: Extracted private `_FilterChip` to `widgets/filter_chip.dart` as public `FilterChipWidget`.
- **Login role check**: Added `requiredRole` parameter to `_authenticateAndGo`. Owner Sign In now verifies role is `'Owner'` — technician creds in Owner tab reject with `"Access denied: not a Owner account."` instead of silently logging into the wrong role.
- **Database documentation**: Created `database/DATABASE_DOCUMENTATION.md` with ERD (Mermaid), EERD with disjoint specialization, status lifecycle state machine, full table specs (6 tables), stored procedure catalog (13 procedures + 1 function with usage matrix), trigger details, seed data walkthrough, call sequence diagrams, org-scope validation pattern flowchart, frontend↔DB mapping table, and key design decisions.

## Recent Changes (2026-05-31)
- Fixed Widget Hierarchy diagram in `DOCUMENTATION.md` — added main.dart, login_screen.dart, home_shell.dart, full app root, state/theme/services/utils/models subgraphs, accurate connections. Fixed file count (15 widgets, 34 total files).
- Created `frontend/FRONTEND_DOCUMENTATION.md` — detailed 50+ section document covering all 34 files: app boot sequence, state management, navigation/routing, full screen-by-screen breakdown (5 main screens + 6 extracted modules), dialog/sheet extraction pattern, 15-widget reference gallery with usage matrix, API service layer with all endpoint methods, design tokens table, shared utilities, input validation guide, toast system, file inventory, key design decisions.
- Updated all 4 AGENTS.md files (root, frontend, backend, database) with detailed architecture, conventions, and file references.
- Updated all 4 CONTEXT.md files (root, frontend, backend, database) with current state, all Phase 5 changes, and documentation references.

## Final Summary

Status: PHASE 5 UX POLISH — Documentation complete, Phase 5 work ongoing
