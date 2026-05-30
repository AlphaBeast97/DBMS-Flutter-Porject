# Frontend Context

## Purpose
Flutter UI consuming the TechFix backend API via HTTP Basic Auth.

## Status
Phase 5 (UX Polish) in progress.

## Architecture
- **State**: `AppSession` (ChangeNotifier) + `AppSessionScope` (InheritedNotifier) — created once in `main.dart`, injected at root.
- **Navigation**: LoginScreen → HomeShell (IndexedStack + NavigationBar with role-filtered tabs). No Navigator routes.
- **Dialogs**: Conditionally rendered as overlay widgets in a `Stack`, managed by `_dialogType` / `_dialogJob` state variables.
- **API**: `TechFixApi` class in `services/techfix_api.dart` — 15 endpoint methods, HTTP Basic Auth headers.

## Screens
- **Login** (779 lines): 3 tabs (Owner/Employee/Customer), Owner has Sign In + Sign Up modes. `Field` widget inputs. `_authenticateAndGo()` with `requiredRole` param for Owner role check.
- **HomeShell** (106 lines): `IndexedStack` with `_allNavItems` filtered by employee role. Hides `NavigationBar` when only 1 tab visible.
- **Customer Status** (686 lines): Self-service portal. 7 private build methods. Async loads 4 result sets via `getCustomerSelf()` or `getCustomerFull()`.
- **Technician** (470 lines): Job list with search/filter, FAB for create/log. Orchestrates 4 dialogs/sheets as overlays.
- **Manager** (438 lines): Donut chart (CustomPainter), revenue card with dual progress bar, paginated jobs. FAB for add staff.

## Extracted Modules
- `technician/status_radio_dialog.dart` — status radio picker in TechFixDialog shell
- `technician/edit_desc_dialog.dart` — edit description+cost in TechFixDialog shell
- `technician/create_job_sheet.dart` — 3-step form in Sheet shell
- `technician/log_part_sheet.dart` — job selector + part fields in Sheet shell
- `manager/add_staff_dialog.dart` — add staff form in TechFixDialog shell
- `manager/donut_painter.dart` — DonutPainter (CustomPainter) + LegendDot widget

## Key Files
- `main.dart` — Entry point: creates AppSession, wraps in AppSessionScope, routes to LoginScreen
- `config/api_config.dart` — Base URL constants per platform
- `services/techfix_api.dart` — All REST endpoints (350 lines)
- `shared/utils.dart` — signOut(), fmtMoney(), emailRegex, minPasswordLength
- `widgets/toast.dart` — showToast(context, msg, type) — replaces all raw SnackBar calls
- `theme/app_theme.dart` — Color tokens, status helpers, Google Fonts Space Grotesk
- `FRONTEND_DOCUMENTATION.md` — Full frontend documentation with screen breakdown, widget reference, design system

## Changes in Phase 5
- Removed 88 hardcoded fontFamily declarations — theme default covers it
- Extracted 6 dialog/sheet files from oversized screens
- Created shared utils (signOut, fmtMoney, emailRegex, minPasswordLength)
- Deleted 4 unused files: mock_data.dart, customer.dart, device.dart, inventory_card.dart
- Fixed login role-check bug — Owner tab now rejects non-Owner credentials
- Created Toast system — replaced 12+ raw SnackBar calls
- Fixed all setState async bugs, IntrinsicHeight overflow, keyboard handling
- Added input validation + keyboard types + obscure text across all forms
