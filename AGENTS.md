# TechFix Agent Notes

- Work one phase at a time and confirm before moving forward.
- Keep backend thin and call stored procedures/functions for all data operations.
- Validate inputs in the backend; keep database constraints and triggers authoritative.
- Update the root CONTEXT.md at the end of each completed phase.
- Keep scope minimal (no auth, payments, or complex state unless requested).
- Only edit root AGENTS.md and CONTEXT.md; other agents maintain their own area files.
- Prefer node:test + supertest with injected procedure mocks for API tests.
- Implement access control (Owner/Employee/Customer) only after endpoint coverage is complete and approved.
