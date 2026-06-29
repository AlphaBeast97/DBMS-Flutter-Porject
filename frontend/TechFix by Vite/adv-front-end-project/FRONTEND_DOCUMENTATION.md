# TechFix React Frontend — Documentation

> **Project:** TechFix — Digital Repair Workflow Manager
> **Stack:** React 19 + Vite 8 + Tailwind CSS v4 + shadcn/ui (Base UI)
> **Backend:** Node.js + Express 5 (15 REST endpoints, HTTP Basic Auth)
> **Database:** MySQL 8 (business logic in stored procedures)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Folder Structure](#3-folder-structure)
4. [Setup & Run](#4-setup--run)
5. [Routing](#5-routing)
6. [Authentication & State Management](#6-authentication--state-management)
7. [API Integration](#7-api-integration)
8. [Screen-by-Screen Breakdown](#8-screen-by-screen-breakdown)
9. [Component Gallery](#9-component-gallery)
10. [Form Flow Diagrams](#10-form-flow-diagrams)
11. [Design System](#11-design-system)
12. [Error & Loading Patterns](#12-error--loading-patterns)
13. [File Inventory](#13-file-inventory)
14. [Known Gaps & Deviations](#14-known-gaps--deviations)

---

## 1. Project Overview

### 1.1 What TechFix Does

TechFix is a repair shop management system with three user personas:

| Persona        | Role            | Capabilities                                                                          |
| -------------- | --------------- | ------------------------------------------------------------------------------------- |
| **Owner**      | `Owner`         | Dashboard with analytics (donut chart, revenue), view all org jobs                    |
| **Technician** | `Employee`      | Create/manage repair jobs (3-step wizard), update status, edit description, log parts |
| **Customer**   | (no role field) | View own devices/jobs/parts, cancel pending repairs                                   |

### 1.2 Backend Philosophy

- **All business logic lives in MySQL stored procedures.** The Express backend is a thin validation + routing layer.
- **Authentication is HTTP Basic Auth** — no JWT, no sessions. Email:password is base64-encoded and sent with every request.
- **Customer auth uses email only** (no password). Basic Auth header is `email:` with empty password.
- **Org-scope isolation** is enforced by stored procedures — employees can only access data within their organization.

### 1.3 Status Lifecycle

```
Pending → Repairing → Ready → Delivered  (employee transitions)
Pending → Cancelled                       (customer only)
```

- `Delivered` and `Cancelled` are terminal states — no further updates allowed.
- When a job is marked `Delivered`, a database trigger auto-computes `final_cost` by summing all `part_cost` values from `inventory_usage`.

---

## 2. Architecture

### 2.1 High-Level Structure

```
main.jsx
  └── App.jsx
       ├── AuthProvider (context)
       │   ├── BrowserRouter
       │   │   ├── /login → LoginPage
       │   │   ├── /technician → ProtectedRoute(Employee) → AppLayout → TechnicianPage
       │   │   ├── /dashboard → ProtectedRoute(Owner) → AppLayout → ManagerPage
       │   │   └── /my-repairs → ProtectedRoute(Customer) → AppLayout → MyRepairsPage
       │   └── Toaster (react-hot-toast)
       └── ErrorBoundary
```

### 2.2 Key Architecture Decisions

| Decision              | Choice                        | Rationale                                                       |
| --------------------- | ----------------------------- | --------------------------------------------------------------- |
| **Bundler**           | Vite 8                        | Fast HMR, already scaffolded                                    |
| **UI Framework**      | React 19                      | Latest stable                                                   |
| **Styling**           | Tailwind CSS v4               | Utility-first with `@theme` directive                           |
| **Component Library** | shadcn/ui on Base UI          | Copy-paste components, fully customizable, no locked dependency |
| **Routing**           | React Router v7               | SPA routing with role-based guards                              |
| **HTTP Client**       | Axios                         | Interceptors for auth header injection + 401 handling           |
| **State**             | React Context (`AuthContext`) | Matches 3-4 screen complexity; no external state library needed |
| **Charts**            | Recharts                      | Lightweight donut chart for ManagerPage                         |
| **Notifications**     | react-hot-toast               | Lightweight, declarative                                        |
| **Icons**             | Lucide React                  | Consistent icon set matching design tokens                      |

### 2.3 State Management

The only global state is `AuthContext`:

```
AuthContext shape:
{
  user: { id, organizationId, name, email, role } | null,
  baseUrl: string,
  email: string,
  password: string,
  isAuthenticated: boolean,
  role: 'Owner' | 'Employee' | 'Customer' | null,
  initialized: boolean,
  login: (email, password, role) => Promise<void>,
  logout: () => void,
}
```

- Auth data is persisted in `localStorage` under the key `techfix_auth`.
- On app load, the stored session is restored automatically (no re-login on refresh).
- Each page manages its own data-fetching state (`jobs`, `loading`, `error`, etc.) via `useState`.
- The `useApi()` hook returns a memoized Axios instance wired to the current user's credentials.

---

## 3. Folder Structure

```
src/
├── main.jsx                        # Entry point
├── App.jsx                         # Router + providers
├── index.css                       # Tailwind v4 theme + design tokens
│
├── config/
│   └── api.js                      # Axios factory (Basic Auth, 401 interception)
│
├── lib/
│   ├── utils.js                    # cn(), fmtMoney(), base64(), emailRegex
│   └── constants.js                # STATUS_COLORS, device types, role helpers
│
├── context/
│   └── AuthContext.jsx             # Auth state + login/logout/persist
│
├── hooks/
│   ├── useApi.js                   # Returns authenticated Axios instance
│   └── useAuth.js                  # Shortcut to AuthContext
│
├── services/
│   └── authService.js              # loginEmployee, loginCustomer, createOwner
│
├── components/
│   ├── ui/                         # shadcn/ui components (15 files)
│   │   ├── alert-dialog.jsx        # Confirm/cancel modal
│   │   ├── avatar.jsx              # User avatar with initials
│   │   ├── badge.jsx               # Status label
│   │   ├── button.jsx              # Primary/outline/ghost variants
│   │   ├── card.jsx                # Card + CardHeader + CardContent + CardFooter
│   │   ├── dialog.jsx              # Centered modal overlay
│   │   ├── input.jsx               # Text input
│   │   ├── label.jsx               # Form label
│   │   ├── radio-group.jsx         # Radio button group
│   │   ├── select.jsx              # Dropdown select
│   │   ├── separator.jsx           # Divider
│   │   ├── sheet.jsx               # Slide-in panel
│   │   ├── skeleton.jsx            # Shimmer placeholder
│   │   ├── tabs.jsx                # Tab switcher
│   │   ├── textarea.jsx            # Multi-line input
│   │   ├── toggle.jsx              # Press/unpress toggle
│   │
│   ├── layout/
│   │   ├── AppLayout.jsx           # TopBar + Outlet
│   │   ├── ProtectedRoute.jsx      # Auth + role guard
│   │   └── TopBar.jsx              # Brand + user info + sign-out
│   │
│   ├── shared/
│   │   ├── StatusBadge.jsx         # Status-colored badge
│   │   ├── JobCard.jsx             # Job display card
│   │   ├── StatCard.jsx            # Metric display card
│   │   ├── LoadingState.jsx        # Skeleton shimmer grid
│   │   ├── EmptyState.jsx          # Empty placeholder
│   │   ├── ErrorState.jsx          # Error + retry
│   │   ├── ErrorBoundary.jsx       # React error boundary (class)
│   │   └── RevenueCard.jsx         # Revenue display card
│   │
│   └── forms/
│       ├── LoginForm.jsx           # Email/password form
│       ├── OwnerSignUpForm.jsx     # Org registration form
│       ├── CreateCustomerForm.jsx  # Step 1 of wizard
│       ├── CreateDeviceForm.jsx    # Step 2 of wizard
│       ├── CreateJobForm.jsx       # Step 3 of wizard
│       ├── StatusChangeForm.jsx    # Status radio dialog
│       ├── EditJobForm.jsx         # Edit description dialog
│       ├── LogPartForm.jsx         # Log part sheet
│       └── AddStaffForm.jsx        # Add employee (Owner only)
│
└── pages/
    ├── LoginPage.jsx               # 3-mode auth screen
    ├── TechnicianPage.jsx          # Technician job management
    ├── ManagerPage.jsx             # Owner dashboard + Add Staff
    └── MyRepairsPage.jsx           # Customer self-service
```

---

## 4. Setup & Run

### 4.1 Prerequisites

- Node.js 20+
- Backend server running at `http://localhost:3000` (or configure via AuthContext default)

### 4.2 Install

```bash
cd frontend/TechFix\ by\ Vite/adv-front-end-project
npm install
```

### 4.3 Development

```bash
npm run dev
```

Opens at `http://localhost:5173`.

### 4.4 Production Build

```bash
npm run build    # Outputs to dist/
npm run preview  # Preview the build
```

### 4.5 Dependencies

| Package                    | Purpose                                |
| -------------------------- | -------------------------------------- |
| `react-router-dom`         | Client-side routing                    |
| `axios`                    | HTTP client with interceptors          |
| `recharts`                 | Donut chart                            |
| `react-hot-toast`          | Toast notifications                    |
| `lucide-react`             | Icons                                  |
| `clsx` + `tailwind-merge`  | Class merging (shadcn dependency)      |
| `tailwindcss`              | Utility CSS framework v4               |
| `tw-animate-css`           | Tailwind animation plugin              |
| `@base-ui/react/*`         | Base UI primitives (shadcn v4)         |
| `class-variance-authority` | Component variants (shadcn dependency) |
| `shadcn`                   | shadcn prebuilt CSS theme              |

---

## 5. Routing

### 5.1 Route Table

| Route         | Page             | Auth   | Role     | Description                                                                           |
| ------------- | ---------------- | ------ | -------- | ------------------------------------------------------------------------------------- |
| `/login`      | `LoginPage`      | Public | —        | Role-based login (Owner/Employee/Customer)                                            |
| `/`           | Redirect         | Auth   | Any      | Redirects based on role: Owner→/dashboard, Employee→/technician, Customer→/my-repairs |
| `/technician` | `TechnicianPage` | Auth   | Employee | Job list, create/update/log                                                           |
| `/dashboard`  | `ManagerPage`    | Auth   | Owner    | Analytics donut, revenue, paginated jobs                                              |
| `/my-repairs` | `MyRepairsPage`  | Auth   | Customer | Self-service profile, devices, jobs, parts                                            |
| `*`           | Fallback         | —      | —        | Redirects to `/login`                                                                 |

### 5.2 Route Protection

- `ProtectedRoute` checks `isAuthenticated` — redirects to `/login` if false.
- If `allowedRoles` is specified and the user's role is not in the list, renders "Access Denied".
- Nested routes use React Router's `<Outlet>` pattern — `AppLayout` provides the shared chrome (TopBar), child routes fill the main area.

### 5.3 Redirect Logic

- **After login**: 
  - `Owner` → `/dashboard`
  - `Employee` → `/technician`
  - `Customer` → `/my-repairs`
- **On 401** from any API call: Axios interceptor calls `logout()`, then `window.location.href = "/login"`.
- **Root `/`**: `HomeRedirect` component reads the user's role from context and redirects accordingly.

---

## 6. Authentication & State Management

### 6.1 Login Flow

```
[LoginPage]
   │
   ├── Owner Tab
   │   ├── Sign In sub-tab
   │   │   ├── Email + password fields (validated: email regex, min 6 chars)
   │   │   ├── POST /api/auth/employee (Basic Auth)
   │   │   ├── Check role === 'Owner'
   │   │   ├── Store credentials + user → redirect /dashboard
   │   │   └── Error → toast
   │   │
   │   └── Sign Up sub-tab
   │       ├── Org name + owner name + email + password fields
   │       ├── POST /api/employees/owner (public, no auth)
   │       ├── Then POST /api/auth/employee with new credentials
   │       ├── Store + redirect /dashboard
   │       └── Error → toast
   │
   ├── Employee Tab
   │   ├── Email + password fields
   │   ├── POST /api/auth/employee (Basic Auth)
   │   ├── Store + redirect /technician
   │   └── Error → toast
   │
   └── Customer Tab
       ├── Email field only (no password)
       ├── POST /api/auth/customer (Basic Auth: email:)
       ├── Store + inject role='Customer' + redirect /my-repairs
       └── Error → toast
```

### 6.2 Credential Storage

- Auth data (user object, baseUrl, email, password) is persisted in `localStorage` under key `techfix_auth`.
- On app mount, `AuthContext` restores the stored session via `loadStored()`.
- On sign-out, `localStorage` is cleared.

### 6.3 AuthContext Details

**File:** `src/context/AuthContext.jsx`

- Created with `createContext`, provided via `AuthProvider` at the app root.
- `login()` handles all three auth modes:
  - **Customer**: calls `loginCustomer()` (email only, no password) and assigns role `'Customer'`.
  - **Owner/Employee**: calls `loginEmployee()` and validates role matches on Owner tab.
- `logout()` clears all state and localStorage.
- `useAuth()` hook provides a shortcut to `AuthContext`.

---

## 7. API Integration

### 7.1 Axios Instance Factory

**File:** `src/config/api.js`

`createApiClient(baseUrl, email, password, onUnauthorized)` returns an Axios instance with:

1. **Request interceptor**: Injects `Authorization: Basic <base64(email:password)>` header on every request.
2. **Response interceptor**:
   - On success: passes response through unchanged.
   - On 401: calls `onUnauthorized()` (logout + redirect to `/login`).
   - On error: extracts `error.response.data.error` as the message, throws with `.status` property.

### 7.2 useApi Hook

**File:** `src/hooks/useApi.js`

Returns a memoized Axios instance from the current auth context:

```js
function useApi() {
  const { baseUrl, email, password, logout } = useAuth();
  return useMemo(
    () => createApiClient(baseUrl, email, password, () => {
      logout();
      window.location.href = "/login";
    }),
    [baseUrl, email, password, logout]
  );
}
```

### 7.3 API Call Examples

All pages use `api` directly (not service modules):

```js
// GET /api/repair-jobs
const res = await api.get("/api/repair-jobs");
const jobs = res.data.data;

// POST /api/customers
const res = await api.post("/api/customers", {
  name, phone, email
});
const customerId = res.data.data.customer_id;

// PUT /api/repair-jobs/:job_id
await api.put(`/api/repair-jobs/${job.job_id}`, {
  status: "Repairing"
});

// POST /api/inventory-usage
await api.post("/api/inventory-usage", {
  job_id: job.job_id,
  part_name,
  part_cost
});
```

### 7.4 Endpoints Consumed

| Method | Route                                  | Used By                       | Purpose                                |
| ------ | -------------------------------------- | ----------------------------- | -------------------------------------- |
| POST   | `/api/auth/employee`                   | LoginPage                     | Employee login                         |
| POST   | `/api/auth/customer`                   | LoginPage, CreateCustomerForm | Customer login, duplicate email lookup |
| POST   | `/api/employees/owner`                 | LoginPage                     | Owner registration                     |
| POST   | `/api/employees`                       | AddStaffForm                  | Create employee (unwired)              |
| POST   | `/api/customers`                       | CreateCustomerForm            | Register customer                      |
| GET    | `/api/customers/:id`                   | TechnicianPage, ManagerPage   | Customer detail (for parts fetch)      |
| GET    | `/api/customers/me`                    | MyRepairsPage                 | Customer self-service data             |
| POST   | `/api/devices`                         | CreateDeviceForm              | Create device                          |
| GET    | `/api/repair-jobs`                     | TechnicianPage, ManagerPage   | List jobs                              |
| POST   | `/api/repair-jobs`                     | CreateJobForm                 | Create job                             |
| PUT    | `/api/repair-jobs/:job_id`             | StatusChangeForm              | Update status                          |
| PUT    | `/api/repair-jobs/:job_id/description` | EditJobForm                   | Update description                     |
| POST   | `/api/repair-jobs/:job_id/cancel`      | MyRepairsPage                 | Cancel pending job                     |
| POST   | `/api/inventory-usage`                 | LogPartForm                   | Log part usage                         |

### 7.5 Parts Batch-Fetch Pattern

The `sp_get_repair_jobs` stored procedure does NOT return `inventory_usage` data. To display parts on the technician and owner screens, both `TechnicianPage` and `ManagerPage` implement a batch-fetch pattern after loading jobs:

1. Collect unique `customer_id` values from all jobs.
2. For each customer, call `GET /api/customers/:customerId` (which returns `inventory_usage` as the 4th result set).
3. Group all usage records by `job_id`.
4. Enrich each job object with `inventory_usage: usageMap[job.job_id] || []`.

This mirrors the Flutter frontend's approach `TechFixApi.fetchUsagesForJobs()`.

---

## 8. Screen-by-Screen Breakdown

### 8.1 LoginPage (`src/pages/LoginPage.jsx`, 99 lines)

**Role:** All (public)

**Description:** 3-tab login screen with role-specific forms. Owner tab has Sign In / Sign Up sub-tabs.

**States:**

- Default: Shows role tabs (Owner/Employee/Customer).
- Owner Sign Up: Shows registration form (org name, owner name, email, password).
- Loading: Submit button shows spinner.
- Error: Toast with error message.

**Key Implementation:**

- Uses shadcn `Tabs` for role switching.
- `LoginForm` component for email/password (Employee/Customer share this).
- `OwnerSignUpForm` component for registration.
- `login()` from `useAuth()` handles all auth flows.

### 8.2 TechnicianPage (`src/pages/TechnicianPage.jsx`, 282 lines)

**Role:** Employee

**Description:** Main technician console with job list, search, status filter chips, and orchestration of all dialogs/sheets.

**Sub-Components Orchestrated:**
| Component | Trigger | UI Pattern |
|-----------|---------|------------|
| `CreateCustomerForm` | "New Job" FAB → Step 1 | Sheet (right slide-in) |
| `CreateDeviceForm` | Step 1 complete → Step 2 | Same Sheet |
| `CreateJobForm` | Step 2 complete → Step 3 | Same Sheet |
| `StatusChangeForm` | "Status" button on JobCard | Dialog (centered modal) |
| `EditJobForm` | "Edit" button on JobCard | Dialog |
| `LogPartForm` | "+ Part" button on JobCard | Sheet (right slide-in) |

**Job List:**

- Search bar filters by `customer_name`, `brand`, `model`, `job_id`.
- Filter chips (All / Pending / Repairing / Ready) use shadcn `Toggle` with active styling.
- Each `JobCard` shows device info, status badge, costs, and collapsible parts section.
- Action buttons (Status, Edit, +Part) hidden for terminal statuses (Cancelled, Delivered).

**Data Fetching:**

- `fetchJobs()` is called on mount and after every mutation.
- Uses the batch-fetch pattern (§7.5) to load `inventory_usage` for all jobs.

### 8.3 ManagerPage (`src/pages/ManagerPage.jsx`, 174 lines)

**Role:** Owner

**Description:** Dashboard with analytics, revenue overview, and paginated job list.

**Sections:**

1. **Stat cards** (3-column grid): Total Jobs, Active Jobs, Estimated Revenue.
2. **Revenue card**: Dual-column finalized vs estimated with visual comparison.
3. **Job status distribution**: Recharts `PieChart` with donut hole, color-coded by status, with legend.
4. **Recent Jobs**: Paginated `JobCard` list with "Show more" (10 at a time).

**States:**

- Loading: 3-column skeleton grid.
- Empty: EmptyState with appropriate message.
- Error: ErrorState with retry.

**Data Fetching:**

- `GET /api/repair-jobs?organization_id=<orgId>` fetches all org jobs.
- Batch-fetch pattern (§7.5) adds `inventory_usage` to each job.

### 8.4 MyRepairsPage (`src/pages/MyRepairsPage.jsx`, 218 lines)

**Role:** Customer

**Description:** Customer self-service portal. Shows profile, devices, repair jobs, and parts used.

**Sections:**

1. **Profile card**: Avatar with initials, name, email, phone.
2. **Stat cards**: Active Repairs, Ready for Pickup.
3. **Devices**: Grid of device cards (brand, model, type, serial number).
4. **Repair Jobs**: List with status badge, description, costs. Cancel button only on `Pending` jobs (uses `AlertDialog` for confirmation).
5. **Parts Used**: Table of part_name, part_cost, employee_name (appears when `inventory_usage` has items).

**States:**

- Loading: 3-column skeleton grid.
- Error: ErrorState with retry.
- Empty (no jobs): EmptyState.

**Key Flow:**

- Cancel job → `POST /api/repair-jobs/:id/cancel` → re-fetch data → success toast.

---

## 9. Component Gallery

### 9.1 Shared Components

| Component       | File                       | Props                                                           | Used In                                    |
| --------------- | -------------------------- | --------------------------------------------------------------- | ------------------------------------------ |
| `StatusBadge`   | `shared/StatusBadge.jsx`   | `status`                                                        | JobCard, MyRepairsPage                     |
| `JobCard`       | `shared/JobCard.jsx`       | `job`, `actions?`, `onEditStatus?`, `onEditDesc?`, `onLogPart?` | TechnicianPage, ManagerPage                |
| `StatCard`      | `shared/StatCard.jsx`      | `icon`, `value`, `label`                                        | ManagerPage, MyRepairsPage                 |
| `LoadingState`  | `shared/LoadingState.jsx`  | `count?`                                                        | All pages                                  |
| `EmptyState`    | `shared/EmptyState.jsx`    | `icon`, `title`, `description`, `actionLabel?`, `onAction?`     | TechnicianPage, ManagerPage, MyRepairsPage |
| `ErrorState`    | `shared/ErrorState.jsx`    | `message`, `onRetry`                                            | All pages                                  |
| `ErrorBoundary` | `shared/ErrorBoundary.jsx` | `children`                                                      | App root                                   |
| `RevenueCard`   | `shared/RevenueCard.jsx`   | `estimated`, `finalized`                                        | ManagerPage                                |

### 9.2 Form Components

| Component            | File                           | Props                                       | UI Pattern                    |
| -------------------- | ------------------------------ | ------------------------------------------- | ----------------------------- |
| `LoginForm`          | `forms/LoginForm.jsx`          | `onSubmit`, `loading`                       | Inline in LoginPage tabs      |
| `OwnerSignUpForm`    | `forms/OwnerSignUpForm.jsx`    | `onSubmit`, `loading`                       | Inline in LoginPage Owner tab |
| `CreateCustomerForm` | `forms/CreateCustomerForm.jsx` | `api`, `baseUrl`, `onCreated`, `onBack`     | Sheet (step 1)                |
| `CreateDeviceForm`   | `forms/CreateDeviceForm.jsx`   | `api`, `customerId`, `onCreated`, `onBack`  | Sheet (step 2)                |
| `CreateJobForm`      | `forms/CreateJobForm.jsx`      | `api`, `deviceId`, `onCompleted`, `onBack`  | Sheet (step 3)                |
| `StatusChangeForm`   | `forms/StatusChangeForm.jsx`   | `api`, `job`, `role`, `onSaved`, `onCancel` | Dialog                        |
| `EditJobForm`        | `forms/EditJobForm.jsx`        | `api`, `job`, `onSaved`, `onCancel`         | Dialog                        |
| `LogPartForm`        | `forms/LogPartForm.jsx`        | `api`, `job`, `onSaved`, `onCancel`         | Sheet                         |
| `AddStaffForm`       | `forms/AddStaffForm.jsx`       | `api`, `onSaved`, `onCancel`                | Dialog (Owner dashboard)      |

### 9.3 UI Components (shadcn)

These 16 components are standard shadcn/ui v4 on Base UI. Refer to their individual files for the exact API:

`alert-dialog`, `avatar`, `badge`, `button`, `card`, `dialog`, `input`, `label`, `radio-group`, `select`, `separator`, `sheet`, `skeleton`, `tabs`, `textarea`, `toggle`

---

## 10. Form Flow Diagrams

### 10.1 Create Job Wizard

```
[Sheet opens: "Create Repair Job"]
         │
    ┌────▼────┐
    │ Step 1  │  CreateCustomerForm
    │         │  - Name, Phone, Email
    │         │  - Checks existing email via POST /api/auth/customer
    │         │  - If exists → uses existing customer_id
    │         │  - If not → POST /api/customers
    └────┬────┘
         │ onCreated(customerId)
         ▼
    ┌────▼────┐
    │ Step 2  │  CreateDeviceForm
    │         │  - Device Type (select: Laptop/Mobile/Console/Tablet/Other)
    │         │  - Brand, Model, Serial Number
    │         │  - POST /api/devices
    └────┬────┘
         │ onCreated(deviceId)
         ▼
    ┌────▼────┐
    │ Step 3  │  CreateJobForm
    │         │  - Description (required)
    │         │  - Estimated Cost (optional)
    │         │  - POST /api/repair-jobs
    └────┬────┘
         │ onCompleted()
         ▼
    [Close sheet → refresh job list → toast "Job created!"]
```

### 10.2 Status Change

```
[Click "Status" on JobCard]
         │
         ▼
    [Dialog opens: "Update Status"]
         │
         ▼
    (RadioGroup: valid next statuses only)
    Pending  → Repairing, Cancelled (customer)
    Repairing → Ready
    Ready    → Delivered
         │
         ▼
    PUT /api/repair-jobs/:job_id { status }
         │
         ▼
    [Close dialog → refresh job list → toast "Status updated!"]
```

### 10.3 Log Part

```
[Click "+ Part" on JobCard]
         │
         ▼
    [Sheet opens: "Log Part"]
         │
         ▼
    - Part Name (required)
    - Part Cost (optional, number)
         │
         ▼
    POST /api/inventory-usage { job_id, part_name, part_cost }
         │
         ▼
    [Close sheet → refresh job list → toast "Part logged!"]
```

### 10.4 Cancel Job (Customer)

```
[Click "Cancel" on Pending job in MyRepairsPage]
         │
         ▼
    [AlertDialog: "Cancel Repair Job?"]
         │
         ├── "Keep Job" → close dialog
         │
         └── "Yes, Cancel" → POST /api/repair-jobs/:id/cancel
                              │
                              ▼
                      [Refresh data → toast success]
```

---

## 11. Design System

### 11.1 Color Tokens

| Token           | Hex       | Usage                                     |
| --------------- | --------- | ----------------------------------------- |
| `--color-coral` | `#F26B4A` | Primary buttons, active elements, accent  |
| `--color-teal`  | `#2A9D8F` | Secondary, success states, "Ready" status |
| `--color-sky`   | `#2D7BD1` | Accent, "Repairing" status                |
| `--color-clay`  | `#B86B4B` | "Pending" status                          |
| `--color-ink`   | `#141414` | Text, foreground                          |
| `--color-cream` | `#F7F3ED` | Background                                |
| `--color-beige` | `#EFE7DA` | Card backgrounds                          |
| `--color-grey`  | `#9A958C` | Muted text, "Cancelled" status            |

### 11.2 Semantic CSS Variable Mapping (in `index.css`)

| shadcn Variable        | Maps To                          |
| ---------------------- | -------------------------------- |
| `--primary`            | Coral `#F26B4A`                  |
| `--primary-foreground` | Cream `#F7F3ED`                  |
| `--secondary`          | Teal `#2A9D8F`                   |
| `--background`         | Cream `#F7F3ED`                  |
| `--foreground`         | Ink `#141414`                    |
| `--card`               | Beige `#EFE7DA`                  |
| `--muted`              | Grey `#9A958C`                   |
| `--border`             | `color-mix(ink 8%, transparent)` |
| `--ring`               | Coral `#F26B4A`                  |
| `--radius`             | `0.75rem`                        |

### 11.3 Typography

- **Font:** Space Grotesk (Google Fonts), imported in `index.css`.
- **Weight range:** 300–700.
- Applied via Tailwind `font-family-sans` token; no hardcoded `fontFamily` on individual elements.

### 11.4 Status Color Helpers (from `src/lib/constants.js`)

| Status    | Color          | Background                |
| --------- | -------------- | ------------------------- |
| Pending   | Clay `#B86B4B` | `#B86B4B1A` (10% opacity) |
| Repairing | Sky `#2D7BD1`  | `#2D7BD11A`               |
| Ready     | Teal `#2A9D8F` | `#2A9D8F1A`               |
| Delivered | Teal `#2A9D8F` | `#2A9D8F1A`               |
| Cancelled | Grey `#9A958C` | `#9A958C1A`               |

### 11.5 Device Type Icons

| Type    | Lucide Icon  |
| ------- | ------------ |
| Laptop  | `Laptop`     |
| Mobile  | `Smartphone` |
| Console | `Gamepad2`   |
| Tablet  | `Tablet`     |
| Other   | `Package`    |

---

## 12. Error & Loading Patterns

### 12.1 Three-State Pattern

Every data-fetching component follows this exact pattern:

```jsx
{loading ? (
  <LoadingState count={3} />
) : error ? (
  <ErrorState message={error} onRetry={fetchData} />
) : (
  // Actual content
)}
```

### 12.2 Toast Notifications

- Uses `react-hot-toast` configured at `App.jsx` root.
- Toaster position: `top-right`, max 2 visible.
- Success toasts: teal background.
- Error toasts: dark coral background.
- `toast.dismiss()` called before each new toast to avoid stacking.

### 12.3 401 Handling

- Axios response interceptor in `src/config/api.js` checks for 401 status.
- On 401: calls the `onUnauthorized` callback (passed from `useApi`).
- `onUnauthorized` calls `logout()` + redirects to `/login`.
- After a part is logged or a mutation fails anywhere, the 401 interceptor ensures the user is redirected.

### 12.4 Error Boundary

- `ErrorBoundary` wraps the entire app in `App.jsx`.
- Catches render-phase errors and displays a fallback UI with "Something went wrong" + retry button.

### 12.5 Action Feedback

Every mutation follows this pattern:

```js
try {
  await api.post("/api/endpoint", payload);
  toast.dismiss();
  toast.success("Success message!");
  fetchData();          // Refresh affected data
} catch (err) {
  toast.dismiss();
  toast.error(err.message);
}
```

---

## 13. File Inventory

Total: **50 source files** (excluding `dist/`, `node_modules/`)

| #   | File                                          | Lines | Purpose                                        |
| --- | --------------------------------------------- | ----- | ---------------------------------------------- |
| 1   | `src/main.jsx`                                | 11    | Mounts React app                               |
| 2   | `src/App.jsx`                                 | 83    | Router, providers, toast config                |
| 3   | `src/index.css`                               | 103   | Tailwind theme, design tokens                  |
| 4   | `src/config/api.js`                           | 36    | Axios factory with auth interception           |
| 5   | `src/lib/utils.js`                            | 24    | cn(), fmtMoney(), base64(), emailRegex         |
| 6   | `src/lib/constants.js`                        | 42    | Status colors, device types, role helpers      |
| 7   | `src/context/AuthContext.jsx`                 | 96    | Auth state provider + localStorage persistence |
| 8   | `src/hooks/useApi.js`                         | 17    | Authenticated Axios hook                       |
| 9   | `src/hooks/useAuth.js`                        | 9     | Auth context shortcut                          |
| 10  | `src/services/authService.js`                 | 25    | Auth API calls                                 |
| 11  | `src/components/ui/alert-dialog.jsx`          | 172   | Confirm/cancel modal                           |
| 12  | `src/components/ui/avatar.jsx`                | 107   | User avatar                                    |
| 13  | `src/components/ui/badge.jsx`                 | 50    | Status label                                   |
| 14  | `src/components/ui/button.jsx`                | 58    | Button variants                                |
| 15  | `src/components/ui/card.jsx`                  | 115   | Card container                                 |
| 16  | `src/components/ui/dialog.jsx`                | 155   | Centered modal                                 |
| 17  | `src/components/ui/input.jsx`                 | 24    | Text input                                     |
| 18  | `src/components/ui/label.jsx`                 | 22    | Form label                                     |
| 19  | `src/components/ui/radio-group.jsx`           | 41    | Radio group                                    |
| 20  | `src/components/ui/select.jsx`                | 190   | Dropdown select                                |
| 21  | `src/components/ui/separator.jsx`             | 24    | Divider                                        |
| 22  | `src/components/ui/sheet.jsx`                 | 139   | Slide-in panel                                 |
| 23  | `src/components/ui/skeleton.jsx`              | 16    | Shimmer placeholder                            |
| 24  | `src/components/ui/tabs.jsx`                  | 80    | Tab switcher                                   |
| 25  | `src/components/ui/textarea.jsx`              | 21    | Multi-line input                               |
| 26  | `src/components/ui/toggle.jsx`                | 44    | Toggle button                                  |
| 27  | `src/components/layout/AppLayout.jsx`         | 23    | Layout shell                                   |
| 28  | `src/components/layout/ProtectedRoute.jsx`    | 22    | Auth guard                                     |
| 29  | `src/components/layout/TopBar.jsx`            | 41    | Top header                                     |
| 30  | `src/components/shared/StatusBadge.jsx`       | 18    | Status-colored badge                           |
| 31  | `src/components/shared/JobCard.jsx`           | 115   | Job display card                               |
| 32  | `src/components/shared/StatCard.jsx`          | 20    | Metric card                                    |
| 33  | `src/components/shared/LoadingState.jsx`      | 24    | Skeleton grid                                  |
| 34  | `src/components/shared/EmptyState.jsx`        | 19    | Empty placeholder                              |
| 35  | `src/components/shared/ErrorState.jsx`        | 18    | Error + retry                                  |
| 36  | `src/components/shared/ErrorBoundary.jsx`     | 42    | Error boundary                                 |
| 37  | `src/components/shared/RevenueCard.jsx`       | 31    | Revenue display                                |
| 38  | `src/components/forms/LoginForm.jsx`          | 97    | Email/password form                            |
| 39  | `src/components/forms/OwnerSignUpForm.jsx`    | 111   | Registration form                              |
| 40  | `src/components/forms/CreateCustomerForm.jsx` | 120   | Wizard step 1                                  |
| 41  | `src/components/forms/CreateDeviceForm.jsx`   | 118   | Wizard step 2                                  |
| 42  | `src/components/forms/CreateJobForm.jsx`      | 107   | Wizard step 3                                  |
| 43  | `src/components/forms/StatusChangeForm.jsx`   | 67    | Status radio                                   |
| 44  | `src/components/forms/EditJobForm.jsx`        | 69    | Edit description dialog                        |
| 45  | `src/components/forms/LogPartForm.jsx`        | 91    | Log part sheet                                 |
| 46  | `src/components/forms/AddStaffForm.jsx`       | 103   | Add employee (Owner only)                      |
| 47  | `src/pages/LoginPage.jsx`                     | 100   | 3-mode auth screen                             |
| 48  | `src/pages/TechnicianPage.jsx`                | 283   | Technician job management                      |
| 49  | `src/pages/ManagerPage.jsx`                   | 198   | Owner dashboard + Add Staff                    |
| 50  | `src/pages/MyRepairsPage.jsx`                 | 219   | Customer self-service                          |

---

*End of Documentation*
