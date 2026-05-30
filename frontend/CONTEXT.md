# Frontend Context

## Purpose

Flutter UI consuming the TechFix backend API.

## Status

Phase 4 complete. Phase 5 (UX Polish) in progress.

## Notes

- Keep UI minimal and presentation-ready.
- No mock data in use; all screens call the real TechFixApi service.
- TechFixApi.getRepairJobs() accepts optional organizationId for manager org-wide view.
- Manager screen passes organization_id from session to load all jobs for dashboard.
- Technician screen calls without organizationId — only sees self-created jobs.
- Login screen has 3 tabs: Owner (Sign In + Sign Up), Employee (Sign In), Customer (Sign In).
- Owner Sign Up creates org + owner via public POST /api/employees/owner, then auto-authenticates.
- AppSession.isOwner getter added for convenience.
- Toast utility: showToast(context, msg, type: ToastType.success|error) — floating dark snackbar from bottom with rounded corners.
- All action feedback uses showToast: job status, job created, job updated, part logged, technician added, job cancelled, plus all error states.
- Field widget supports keyboardType, obscureText, textInputAction, onSubmitted.
- Input validation on all forms: email regex, password min length, cost numeric parse, required field checks.
