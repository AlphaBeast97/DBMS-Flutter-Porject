# TechFix Agent Notes (Root)

## Workflow
- Work one phase at a time and confirm before moving forward.
- Update `CONTEXT.md` at the end of each completed phase.
- Update `AGENTS.md` and `CONTEXT.md` only at root level; subdirectories maintain their own.

## Architecture
- **3-tier**: Flutter frontend → Node.js/Express backend → MySQL database.
- All business logic lives in MySQL stored procedures and triggers.
- Backend validates inputs, calls routines, formats responses — no raw DML.
- Frontend consumes API via `TechFixApi` service with HTTP Basic Auth.

## Stack
- Frontend: Flutter 3.x + Dart (Material 3, Google Fonts, ChangeNotifier state)
- Backend: Node.js + Express 5 (mysql2/promise, basic auth middleware)
- Database: MySQL 8 (InnoDB, stored procedures, triggers, FKs)

## Current Phase
- Phase 5 (UX Polish) in progress.
- Root `DOCUMENTATION.md` has full architecture, ERD, widget hierarchy, API mapping.
- `database/DATABASE_DOCUMENTATION.md` has detailed DB docs (table specs, procedure catalog, seed walkthrough).
- `frontend/FRONTEND_DOCUMENTATION.md` has detailed frontend docs (screen breakdown, widget reference, design system).

## Constraints
- No mock data — all screens call real API.
- Color tokens: Coral #F26B4A, Teal #2A9D8F, Sky #2D7BD1, Clay #B86B4B, Ink #141414, Cream #F7F3ED, Beige #EFE7DA, Grey #9A958C.
- Font: `Space Grotesk` via `GoogleFonts.spaceGroteskTextTheme` — no hardcoded `fontFamily`.
- Keep scope minimal (no auth, payments, or complex state unless requested).
- Access control (Owner/Employee/Customer) only after endpoint coverage is complete and approved.

## Testing
- Backend: `node:test` + `supertest` with injected procedure mocks.
- Frontend: No tests yet (`widget_test.dart` has pre-existing `MyApp` error — app class is `TechFixApp`).
