# Frontend Agent Notes

## Architecture
- Flutter 3.x with Material 3, `ChangeNotifier` + `InheritedNotifier` state management.
- No Navigator routes — two-screen stack (LoginScreen → HomeShell with IndexedStack).
- Dialog/sheet orchestration via state variables rendered as overlay widgets in a `Stack`.

## Coding Conventions
- Keep UI minimal and presentation-ready.
- Use the backend API only via `TechFixApi` service; no direct database access.
- All action feedback via `showToast()` from `widgets/toast.dart` — no raw `SnackBar`.
- All forms validate inputs before API calls (email regex, password min 6, cost parseable).
- Import only from `package:techfix/...` (no relative imports between lib subdirectories).

## State
- `AppSession` (ChangeNotifier) stores credentials + employee data. Created in `main.dart`.
- `AppSessionScope` (InheritedNotifier) provides scoped access via `AppSessionScope.of(context)`.
- Screens call `AppSessionScope.of(context)` at build time to auto-subscribe to changes.

## Design System
- Colors defined as static consts in `AppTheme` class. Use exact hex values from theme.
- Status colors: `AppTheme.statusColor(status)`, `statusBg(status)`, `statusIcon(status)`, `statusLabel(status)`.
- Font courtesy of `GoogleFonts.spaceGroteskTextTheme` in theme — do NOT set `fontFamily` on individual `TextStyle`s.

## Screen Modularization
- Complex screens extract dialogs/sheets into separate files under `screens/` subdirectories.
- Extracted components use standardized shells: `TechFixDialog` for dialogs, `Sheet` for bottom sheets.
- Each extracted component receives `onClose` + `onSave`/`onCreate` callbacks — parent manages state.

## Key Files
- `lib/shared/utils.dart`: `signOut()`, `fmtMoney()`, `emailRegex`, `minPasswordLength`
- `lib/services/techfix_api.dart`: All 15 endpoint methods
- `lib/theme/app_theme.dart`: Color tokens, status helpers
- `lib/widgets/toast.dart`: `showToast(context, msg, type)`
- `frontend/FRONTEND_DOCUMENTATION.md`: Full frontend documentation with screen breakdowns
