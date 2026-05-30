# Backend Context

## Purpose
Node.js + Express 5 API that calls MySQL stored procedures. No raw DML — all business logic stays in the database.

## Status
Phase 2 endpoints implemented; Phase 3 integration complete; Phase 5 fixes deployed.

## Structure
```
backend/src/
├── app.js              # Express app factory (DI for pool)
├── server.js           # Entry point
├── routes/             # 6 route files (auth, employees, customers, devices, repairJobs, inventoryUsage)
├── controllers/        # 6 controller files
├── middleware/
│   ├── auth.js         # employeeAuth + customerAuth middleware (Basic Auth)
│   └── errorHandler.js # Global error handler
├── db/
│   ├── pool.js         # mysql2/promise connection pool
│   └── callProcedure.js # CALL sp_name() helper (single + multi result sets)
└── utils/
    ├── auth.js         # SHA256 hashing, Basic Auth parser
    └── validation.js   # Required fields, parse int/float helpers
```

## Auth
- Employee endpoints: `employeeAuth` middleware calls `sp_employee_login`, binds to `req.employee`
- Customer endpoints: `customerAuth` middleware calls `sp_customer_login`, binds to `req.customer`
- Role filtering: `employeeAuth` accepts optional `roles` array (e.g., `roles: ['Owner']`)
- Public: `POST /api/employees/owner`, `POST /api/auth/*`

## Endpoints (14 total)

| Method | Route | Auth | Access | Procedure(s) |
|--------|-------|------|--------|-------------|
| POST | `/api/auth/employee` | Basic | Public | `sp_employee_login` |
| POST | `/api/auth/customer` | Basic | Public | `sp_customer_login` |
| POST | `/api/employees/owner` | — | Public | `sp_create_owner` |
| POST | `/api/employees` | Employee | Owner | `sp_create_employee` |
| POST | `/api/customers` | Employee | All | `sp_create_customer` |
| GET | `/api/customers/:id` | Employee | All | `sp_get_customer_full_for_employee` |
| GET | `/api/customers/me` | Customer | — | `sp_get_customer_full_for_customer` |
| POST | `/api/devices` | Employee | All | `sp_create_device` |
| GET | `/api/repair-jobs` | Employee | All | `sp_get_repair_jobs` (3 params) |
| POST | `/api/repair-jobs` | Employee | All | `sp_create_repair_job` |
| PUT | `/api/repair-jobs/:job_id` | Employee | All | `sp_update_repair_job_status` |
| PUT | `/api/repair-jobs/:id/description` | Employee | All | `sp_update_repair_job_description` |
| POST | `/api/repair-jobs/:id/cancel` | Customer | — | `sp_cancel_repair_job_by_customer` |
| POST | `/api/inventory-usage` | Employee | All | `sp_log_inventory_usage` |

## Testing
- Unit tests: `npm test` — 24 passed, 0 failed, 1 skipped
- Integration tests (real DB): `npm run test:db` — requires `.env` with seeded DB
- Test framework: `node:test` + `supertest` with mocked stored procedures (stub helper replaces `callProcedure`)

## Key Fixes (Phase 5)
- `getRepairJobs` 500 error: always passes 3 params `[employeeId, status, organizationId]`
- Status update 400 error: normalizes status to PascalCase before WRITE_STATUSES check
- `sp_get_customer_full_*` LEFT JOIN employees for `employee_name` in usage results

## DB Conn Details
- `.env` required: `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`
- If collation mismatch: run `database/techfix_routines_patch.sql`
- `callProcedure.js` uses `pool.query` (not `pool.execute`) — prepared statements have issues with `CALL` multi-result-sets
