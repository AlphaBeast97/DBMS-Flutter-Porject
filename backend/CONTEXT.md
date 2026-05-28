# Backend Context

## Purpose

Node.js + Express API that calls MySQL stored procedures/functions.

## Status

Phase 2 endpoints implemented; access control pending.

## Endpoints

- POST /api/auth/employee
- POST /api/auth/customer
- POST /api/customers
- GET /api/customers/:id
- POST /api/devices
- POST /api/repair-jobs
- GET /api/repair-jobs
- PUT /api/repair-jobs/:job_id
- POST /api/inventory-usage
- POST /api/organizations
- POST /api/employees/owner
- POST /api/employees
- PUT /api/repair-jobs/:job_id/description
- POST /api/repair-jobs/:job_id/cancel
- GET /api/customers/me

## Live API Verification (2026-05-27)

Auth used: HTTP Basic with seeded owner account.

- POST /api/auth/employee
  - How: `curl -u "owner@techfix.com:Owner123" -X POST http://localhost:3000/api/auth/employee`
  - Expected: 200 + employee record
  - Received: 200 + `{ employee_id: 1, organization_id: 1, role: "Owner", ... }`
- GET /api/repair-jobs
  - How: `curl -u "owner@techfix.com:Owner123" http://localhost:3000/api/repair-jobs`
  - Expected: 200 + array of jobs
  - Received: 200 + array (example includes `job_id: 1`, `status: "Pending"`, etc.)
- GET /api/customers/1
  - How: `curl -u "owner@techfix.com:Owner123" http://localhost:3000/api/customers/1`
  - Expected: 200 + customer with devices/jobs/usage
  - Received: 200 + `customer_id: 1` with devices + repair jobs + inventory usage arrays
- POST /api/customers
  - How: `curl -u "owner@techfix.com:Owner123" -H "Content-Type: application/json" -X POST http://localhost:3000/api/customers -d '{"organization_id":1,"name":"Live Test Customer","phone":"0300...","email":"live_...@example.com"}'`
  - Expected: 201 + new customer id
  - Received: 201 + `{ customer_id: 7 }`
- POST /api/devices
  - How: `curl -u "owner@techfix.com:Owner123" -H "Content-Type: application/json" -X POST http://localhost:3000/api/devices -d '{"customer_id":1,"type":"Laptop","brand":"Dell","model":"Inspiron 15","serial_number":"LIVE-..."}'`
  - Expected: 201 + new device id
  - Received: 201 + `{ device_id: 10 }`
- POST /api/repair-jobs
  - How: `curl -u "owner@techfix.com:Owner123" -H "Content-Type: application/json" -X POST http://localhost:3000/api/repair-jobs -d '{"device_id":1,"description":"Live test job","estimated_cost":1234,"status":"Pending"}'`
  - Expected: 201 + new job id
  - Received: 201 + `{ job_id: 12 }`
- POST /api/inventory-usage
  - How: `curl -u "owner@techfix.com:Owner123" -H "Content-Type: application/json" -X POST http://localhost:3000/api/inventory-usage -d '{"job_id":1,"part_name":"Live Part","part_cost":999}'`
  - Expected: 201 + new usage id
  - Received: 201 + `{ usage_id: 9 }`
- PUT /api/repair-jobs/:job_id
  - How: `curl -u "owner@techfix.com:Owner123" -H "Content-Type: application/json" -X PUT http://localhost:3000/api/repair-jobs/12 -d '{"status":"Ready"}'`
  - Expected: 200 + rows affected
  - Received: 200 + `{ rows_affected: 1 }`

- POST /api/organizations
  - How: `curl -u "owner@techfix.com:Owner123" -H "Content-Type: application/json" -X POST http://localhost:3000/api/organizations -d '{"name":"New Org Ltd"}'`
  - Expected: 201 + new organization id
  - Received: 201 + `{ organization_id: 13 }`

- POST /api/employees/owner
  - How: `curl -H "Content-Type: application/json" -X POST http://localhost:3000/api/employees/owner -d '{"organization_name":"Shop A","owner_name":"Alice","owner_email":"alice@shopa.com","password":"Owner123"}'`
  - Expected: 201 + `{ organization_id, owner_employee_id }` (org + owner created)
  - Received: 201 + `{ organization_id: 14, owner_employee_id: 15 }`

- POST /api/employees
  - How: `curl -u "owner@shopa.com:Owner123" -H "Content-Type: application/json" -X POST http://localhost:3000/api/employees -d '{"name":"Bob","email":"bob@shopa.com","password":"Tech123"}'`
  - Expected: 201 + new employee id
  - Received: 201 + `{ employee_id: 16 }`

- PUT /api/repair-jobs/:job_id/description
  - How: `curl -u "tech@example.com:Tech123" -H "Content-Type: application/json" -X PUT http://localhost:3000/api/repair-jobs/12/description -d '{"description":"Updated description"}'`
  - Expected: 200 + `{ rows_affected: 1 }`
  - Received: 200 + `{ rows_affected: 1 }`

- POST /api/repair-jobs/:job_id/cancel
  - How: `curl -u "customer@example.com:" -X POST http://localhost:3000/api/repair-jobs/12/cancel`
  - Expected: 200 + `{ rows_affected: 1 }` when the job is `Pending`
  - Received: 200 + `{ rows_affected: 1 }`

- GET /api/customers/me
  - How: `curl -u "customer@example.com:" http://localhost:3000/api/customers/me`
  - Expected: 200 + customer object with `devices`, `repair_jobs` and `inventory_usage` result sets
  - Received: 200 + `{ customer: { customer_id: 7, name: "Live Test Customer", email: "live_...@example.com" }, devices: [...], repair_jobs: [...], inventory_usage: [...] }`

## Testing

- Unit tests: `npm test`
- Integration tests (real DB): `npm run test:db`
- Integration tests require `.env` with DB credentials and seeded data.

### Unit test results (2026-05-28)

- `npm test` — **24 passed, 0 failed, 1 skipped** (includes one DB integration test skipped).

## Database Notes

- If you see collation mismatch errors, run database/techfix_routines_patch.sql.
- This patch updates login and customer lookup routines to align collations.

## Auth

- Employee endpoints require HTTP Basic auth (email:password).
- Customer auth uses HTTP Basic auth (email only).
- Protected endpoints bind actions to the authenticated employee context.

## Notes

- Backend must validate input before calling stored routines.
- No direct SQL table access from code.
- Basic auth for Owner/Employee/Customer is implemented.
- Fine-grained access control rules still need approval.
