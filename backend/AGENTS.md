# Backend Agent Notes

## Architecture
- Node.js + Express 5 with `mysql2/promise` connection pool.
- All data operations through MySQL stored procedures — no raw DML from code.
- Thin controllers: validate inputs → call procedure → format JSON response.

## Structure
- `src/app.js` — Express app factory (accepts pool via DI for testability).
- `src/server.js` — Entry point, starts listener.
- `src/routes/` — 6 route files.
- `src/controllers/` — 6 controller files.
- `src/middleware/` — `auth.js` (employee + customer auth), `errorHandler.js`.
- `src/db/` — `pool.js` (mysql2 pool factory), `callProcedure.js` (CALL helper for single + multi result sets).
- `src/utils/` — `auth.js` (SHA256 hashing, Basic Auth parser), `validation.js` (required fields, parse int/float).

## Auth
- Employee endpoints: HTTP Basic Auth (email:password) → `sp_employee_login`.
- Customer endpoints: HTTP Basic Auth (email only) → `sp_customer_login`.
- Middleware binds authenticated entity to `req.employee` or `req.customer`.
- Fine-grained role control available via `roles` parameter in `employeeAuth` middleware.

## Endpoints
- 14 endpoints total (see `backend/CONTEXT.md` for full list and curl verification).
- Owner-specific: `POST /api/employees/owner` (public), `POST /api/employees` (owner-protected).

## Testing
- Unit tests: `npm test` — uses `node:test` + `supertest` with mocked procedures.
- Integration tests (real DB): `npm run test:db` — requires `.env` with DB credentials.
- Current: **24 passed, 0 failed, 1 skipped** (DB integration test skipped by default).

## Notes
- `callProcedure.js` uses `pool.query` instead of `pool.execute` (prepared statements have issues with `CALL` returning multiple result sets).
- Keep routes modular and avoid direct table access from code.
- Prefer clear request/response shapes for presentation demos.
