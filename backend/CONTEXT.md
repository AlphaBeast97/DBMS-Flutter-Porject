# Backend Context

## Purpose

Node.js + Express API that calls MySQL stored procedures/functions.

## Status

Phase 2 endpoints implemented; access control pending.

## Endpoints

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

## Notes

- Backend must validate input before calling stored routines.
- No direct SQL table access from code.
- Access control (Owner/Employee/Customer) still needs to be implemented.
