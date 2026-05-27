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

## Testing

- Unit tests: `npm test`
- Integration tests (real DB): `npm run test:db`
- Integration tests require `.env` with DB credentials and seeded data.

## Auth

- Employee endpoints require HTTP Basic auth (email:password).
- Customer auth uses HTTP Basic auth (email only).
- Protected endpoints bind actions to the authenticated employee context.

## Notes

- Backend must validate input before calling stored routines.
- No direct SQL table access from code.
- Basic auth for Owner/Employee/Customer is implemented.
- Fine-grained access control rules still need approval.
