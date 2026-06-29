# TechFix React Frontend — Implementation Plan

> **Project:** TechFix — Digital Repair Workflow Manager
> **Frontend:** React 19 + Vite + Tailwind CSS v4
> **Backend:** Node.js + Express 5 (15 REST endpoints, HTTP Basic Auth)
> **Database:** MySQL 8 (business logic in stored procedures)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Backend API Summary](#2-backend-api-summary)
3. [Frontend Architecture](#3-frontend-architecture)
4. [Folder Structure](#4-folder-structure)
5. [Required Dependencies](#5-required-dependencies)
6. [Route Map](#6-route-map)
7. [Component Hierarchy](#7-component-hierarchy)
8. [API Integration Strategy](#8-api-integration-strategy)
9. [Authentication Implementation Plan](#9-authentication-implementation-plan)
10. [State Management Plan](#10-state-management-plan)
11. [Design System](#11-design-system)
12. [UI Implementation Order](#12-ui-implementation-order)
13. [Step-by-Step Development Roadmap](#13-step-by-step-development-roadmap)
14. [Milestones](#14-milestones)
15. [Testing Checklist](#15-testing-checklist)
16. [Final Polish Checklist](#16-final-polish-checklist)
17. [Potential Backend Improvements](#17-potential-backend-improvements)

---

## 1. Project Overview

### 1.1 What TechFix Does

TechFix is a repair shop management system with three user personas:

| Persona | Role | Capabilities |
|---------|------|-------------|
| **Owner** | `Owner` | Dashboard, manage staff, view all jobs/customers |
| **Technician** | `Employee` | Create/manage repair jobs, log parts used |
| **Customer** | (no role field) | View own devices/jobs, cancel pending repairs |

### 1.2 Backend Philosophy

- **All business logic lives in MySQL stored procedures.** The Express backend is a thin validation + routing layer.
- **Authentication is HTTP Basic Auth** — no JWT, no sessions. Email:password is base64-encoded and sent with every request.
- **Customer auth uses email only** (no password). Basic Auth header is `email:` with empty password.
- **Org-scope isolation** is enforced by stored procedures — employees can only access data within their organization.

### 1.3 Status Lifecycle

```
Pending → Repairing → Ready → Delivered  (employee transitions)
Pending → Cancelled                       (customer only)
Ready   → Cancelled                       (customer only)
```

- `Delivered` and `Cancelled` are terminal states.
- When a job is marked `Delivered`, the trigger auto-computes `final_cost` by summing all `part_cost` values from `inventory_usage`.

---

## 2. Backend API Summary

### 2.1 Complete Endpoint Catalog (15 endpoints)

#### Authentication (3 endpoints)

| # | Method | Route | Auth | Request | Response (200/201) | Errors |
|---|--------|-------|------|---------|-------------------|--------|
| 1 | POST | `/api/auth/employee` | Basic header (email:password) | None (body) | `{ data: { employee_id, organization_id, name, email, role } }` | 401 |
| 2 | POST | `/api/auth/customer` | Basic header (email:) | None (body) | `{ data: { customer_id, organization_id, name, phone, email } }` | 401 |
| 3 | POST | `/api/employees/owner` | Public | `{ organization_name, owner_name, owner_email, password }` | `{ data: { organization_id, owner_employee_id } }` | 400 |

#### Employees (1 endpoint)

| # | Method | Route | Auth | Request | Response | Errors |
|---|--------|-------|------|---------|----------|--------|
| 4 | POST | `/api/employees` | Employee (Owner only) | `{ name, email, password }` | `{ data: { employee_id } }` | 400, 401, 403 |

#### Customers (3 endpoints)

| # | Method | Route | Auth | Request | Response | Errors |
|---|--------|-------|------|---------|----------|--------|
| 5 | POST | `/api/customers` | Employee | `{ name, phone, email?, employee_id?, organization_id? }` | `{ data: { customer_id } }` | 400, 401, 403 |
| 6 | GET | `/api/customers/:id` | Employee | Path: `id` | `{ data: { customer, devices[], repair_jobs[], inventory_usage[] } }` | 400, 401, 403, 404 |
| 7 | GET | `/api/customers/me` | Customer | None | `{ data: { customer, devices[], repair_jobs[], inventory_usage[] } }` | 400, 401, 404 |

#### Devices (1 endpoint)

| # | Method | Route | Auth | Request | Response | Errors |
|---|--------|-------|------|---------|----------|--------|
| 8 | POST | `/api/devices` | Employee | `{ customer_id, type, brand, model, serial_number, employee_id? }` | `{ data: { device_id } }` | 400, 401, 403 |

#### Repair Jobs (5 endpoints)

| # | Method | Route | Auth | Request | Response | Errors |
|---|--------|-------|------|---------|----------|--------|
| 9 | GET | `/api/repair-jobs` | Employee | Query: `?status=Pending&organization_id=1&employee_id=1` | `{ data: [{ job_id, status, description, estimated_cost, final_cost, created_at, device_id, type, brand, model, customer_id, customer_name, customer_phone }] }` | 400, 401, 403 |
| 10 | POST | `/api/repair-jobs` | Employee | `{ device_id, description, estimated_cost?, status?, employee_id? }` | `{ data: { job_id } }` | 400, 401, 403 |
| 11 | PUT | `/api/repair-jobs/:job_id` | Employee | Path: `job_id`, Body: `{ status, employee_id? }` | `{ data: { rows_affected } }` | 400, 401, 403 |
| 12 | PUT | `/api/repair-jobs/:job_id/description` | Employee | Path: `job_id`, Body: `{ description, employee_id? }` | `{ data: { rows_affected } }` | 400, 401, 403 |
| 13 | POST | `/api/repair-jobs/:job_id/cancel` | Customer | Path: `job_id` | `{ data: { rows_affected } }` | 400, 401 |

#### Inventory Usage (1 endpoint)

| # | Method | Route | Auth | Request | Response | Errors |
|---|--------|-------|------|---------|----------|--------|
| 14 | POST | `/api/inventory-usage` | Employee | `{ job_id, part_name, part_cost?, employee_id? }` | `{ data: { usage_id } }` | 400, 401, 403 |

#### Health (1 endpoint)

| # | Method | Route | Auth | Request | Response |
|---|--------|-------|------|---------|----------|
| 15 | GET | `/health` | Public | None | `{ status: "ok" }` |

### 2.2 Auth Header Formats

**Employee:**
```
Authorization: Basic base64("email:password")
```

**Customer:**
```
Authorization: Basic base64("email:")
```

### 2.3 Error Response Format

All errors return: `{ error: "message" }`

| Status | Meaning |
|--------|---------|
| 400 | Bad request (missing/invalid fields) |
| 401 | Unauthorized (missing/invalid Basic Auth) |
| 403 | Forbidden (wrong role, credential mismatch) |
| 404 | Not found |
| 500 | Internal server error |

### 2.4 Device Type ENUM Values

`Laptop`, `Mobile`, `Console`, `Tablet`, `Other`

### 2.5 Status ENUM Values

`Pending`, `Repairing`, `Ready`, `Delivered`, `Cancelled`

### 2.6 Key Response Shapes

**GET /api/repair-jobs** returns array of:
```
{ job_id, status, description, estimated_cost, final_cost, created_at,
  device_id, type, brand, model, customer_id, customer_name, customer_phone }
```

**GET /api/customers/:id** and **GET /api/customers/me** return:
```
{
  customer: { customer_id, organization_id, name, phone, email, created_at },
  devices: [{ device_id, type, brand, model, serial_number, created_at }],
  repair_jobs: [{ job_id, device_id, description, estimated_cost, final_cost, status, created_at }],
  inventory_usage: [{ usage_id, job_id, part_name, part_cost, created_at, employee_name }]
}
```

### 2.7 Employee Object (from login + attached to req.employee)

```
{ employee_id, organization_id, name, email, role }
```

### 2.8 Customer Object (from customer login)

```
{ customer_id, organization_id, name, phone, email, created_at }
```

---

## 3. Frontend Architecture

### 3.1 Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Bundler** | Vite 8 | Already scaffolded |
| **UI Framework** | React 19 | Already scaffolded |
| **Styling** | Tailwind CSS v4 | Already scaffolded + configured |
| **Component Library** | shadcn/ui | Copy-paste components built on Radix UI primitives; fully customizable with Tailwind; avoids maintaining custom UI code |
| **Routing** | React Router v7 | Industry standard for SPA routing |
| **HTTP Client** | Axios | Interceptors for auth header injection, cleaner error handling |
| **State Management** | React Context + useReducer | Matches complexity level (3-4 screens). No external lib needed. |
| **Forms** | React Hook Form + Zod + shadcn Form | shadcn's Form component wraps RHF with accessible Radix primitives |
| **Charts** | Recharts | Lightweight, composable React chart library for donut chart |
| **Notifications** | react-hot-toast | Lightweight, declarative toast system |
| **Icons** | Lucide React | Consistent icon set matching the existing design tokens |
| **Date Formatting** | date-fns | Tree-shakeable date utilities |

### 3.2 Component Strategy

- **shadcn/ui components** (`src/components/ui/`) are installed via the shadcn CLI (`npx shadcn@latest add <component>`). They are copied directly into the project as editable source files — no locked dependency.
- **Custom shared components** (`src/components/shared/`) are app-specific composites built on top of shadcn primitives (e.g. `JobCard`, `StatusBadge`, `StatCard`, `EmptyState`, `ErrorState`).
- **Form components** (`src/components/forms/`) use `react-hook-form` + `zod` + shadcn's `Form` field wrappers for accessible, validated form fields.
- **shadcn components to install:** `button`, `input`, `select`, `dialog`, `sheet`, `badge`, `skeleton`, `avatar`, `card`, `tabs`, `separator`, `radio-group`, `label`, `form`, `alert-dialog`, `command`, `popover`, `toggle`, `tooltip`.

### 3.3 shadcn/ui Setup Notes

- **Path alias:** shadcn expects `@/` to map to `src/`. Add to `vite.config.js`:
  ```js
  resolve: {
    alias: { '@': '/src' },
  },
  ```
- **shadcn config file:** `components.json` at project root, pointing to `@/components/ui` and using `tailwindcss` (v4 compatible with `@tailwindcss/vite` plugin).
- **Tailwind v4 compatibility:** shadcn's CSS variable approach (colors defined as `--primary`, `--background`, etc. in `index.css`) works with Tailwind v4's `@theme` directive. Define both our custom color tokens AND shadcn's semantic CSS variables in the same `@theme` block. If shadcn's `animate-in` classes don't work out of the box, add the animation keyframes manually in `index.css` (since `tailwindcss-animate` is a v3 PostCSS plugin; in v4, keyframes + `@utility` is the equivalent).
- **cn() utility:** shadcn's `cn()` (clsx + tailwind-merge) is generated by the CLI in `src/lib/utils.js`.

### 3.4 Layout Strategy

- **Login page** — full-screen, standalone, no layout wrapper.
- **Authenticated pages** — shared `AppLayout` with:
  - Top navigation bar with role-based items
  - Mobile-responsive sidebar
  - Sign-out button in header
  - Toast container

### 3.5 Role-Based Navigation

| Role | Visible Pages |
|------|---------------|
| **Owner** | Dashboard, Customers |
| **Employee** | Technician (jobs), Customers |
| **Customer** | My Repairs only |

### 3.6 Error & Loading Strategy

- Every data-fetching component uses: loading → error → empty → data pattern.
- `react-hot-toast` for all action feedback.
- Axios response interceptor globally handles 401 errors (redirect to login).

### 3.7 Auth Flow

1. User fills login form (email + password for employee, email-only for customer).
2. Client validates (email regex, password min 6 chars).
3. Creates Basic Auth header, calls appropriate login endpoint.
4. On success: store credentials + user data in `AuthContext`, redirect to appropriate dashboard.
5. On error: display toast with error message.
6. On 401 during any subsequent request: clear auth, redirect to login.

---

## 4. Folder Structure

```
src/
├── main.jsx                        # Entry point, renders App
├── App.jsx                         # Router setup, providers wrap
├── index.css                       # Tailwind imports + global base styles
│
├── config/
│   └── api.js                      # Base URL constant, Axios instance factory
│
├── lib/
│   ├── utils.js                    # fmtMoney, emailRegex, cn() class merge
│   └── constants.js                # STATUS_COLORS, DEVICE_TYPES, status helpers
│
├── context/
│   ├── AuthContext.jsx             # Auth state + provider (credentials, user, role)
│   └── AuthProvider.jsx            # Provider component wrapping children
│
├── hooks/
│   ├── useApi.js                   # Hook to get authenticated Axios instance
│   ├── useAuth.js                  # Shortcut to AuthContext
│   └── useJobs.js                  # Fetch/manage repair jobs
│
├── services/
│   ├── authService.js              # loginEmployee, loginCustomer, createOwner
│   ├── employeeService.js          # createEmployee
│   ├── customerService.js          # createCustomer, getCustomerById (employee)
│   ├── deviceService.js            # createDevice
│   ├── repairJobService.js         # getJobs, createJob, updateStatus, updateDesc, cancelJob
│   └── inventoryService.js         # logPartUsage
│
├── components/
│   ├── ui/                         # shadcn/ui components (installed via CLI)
│   │   ├── button.jsx              # shadcn Button (variants: default, outline, ghost, etc.)
│   │   ├── input.jsx               # shadcn Input
│   │   ├── select.jsx              # shadcn Select (Radix-based dropdown)
│   │   ├── dialog.jsx              # shadcn Dialog (modal overlay)
│   │   ├── sheet.jsx               # shadcn Sheet (slide-in panel)
│   │   ├── badge.jsx               # shadcn Badge (variant, status-colored)
│   │   ├── skeleton.jsx            # shadcn Skeleton (loading placeholder)
│   │   ├── card.jsx                # shadcn Card (Card, CardHeader, CardContent, etc.)
│   │   ├── avatar.jsx              # shadcn Avatar (image + fallback initials)
│   │   ├── tabs.jsx                # shadcn Tabs (role selector on login)
│   │   ├── radio-group.jsx         # shadcn RadioGroup (status change form)
│   │   ├── label.jsx               # shadcn Label (form field label)
│   │   ├── form.jsx                # shadcn Form (react-hook-form wrapper)
│   │   ├── alert-dialog.jsx        # shadcn AlertDialog (confirm/cancel)
│   │   ├── command.jsx             # shadcn Command (search combobox)
│   │   ├── popover.jsx             # shadcn Popover
│   │   ├── toggle.jsx              # shadcn Toggle (pill-shaped filter buttons)
│   │   ├── separator.jsx           # shadcn Separator (visual divider)
│   │   └── tooltip.jsx             # shadcn Tooltip
│   │
│   ├── layout/
│   │   ├── AppLayout.jsx           # Sidebar/topbar + main content area
│   │   ├── Sidebar.jsx             # Navigation sidebar (uses shadcn Button + Separator)
│   │   ├── TopBar.jsx              # Header with user info + sign out
│   │   └── ProtectedRoute.jsx      # Role-gated route wrapper
│   │
│   ├── shared/
│   │   ├── StatusBadge.jsx         # Wraps shadcn Badge with status-specific colors
│   │   ├── JobCard.jsx             # Repair job card (uses shadcn Card + Badge + Button)
│   │   ├── StatCard.jsx            # Metric display card (uses shadcn Card)
│   │   ├── LoadingState.jsx        # Skeleton grid (uses shadcn Skeleton + Card)
│   │   ├── EmptyState.jsx          # Empty placeholder (icon + message + optional action)
│   │   ├── ErrorState.jsx          # Error message with retry Button
│   │   ├── SectionHeader.jsx       # Section title + optional action
│   │   ├── CustomerSearch.jsx      # Search customer by ID (uses shadcn Input + Button)
│   │   └── RevenueCard.jsx         # Dual-column revenue display
│   │
│   └── forms/
│       ├── LoginForm.jsx           # Uses shadcn Form + Input + Button + Tabs
│       ├── OwnerSignUpForm.jsx     # Uses shadcn Form + Input + Button
│       ├── CreateCustomerForm.jsx  # Uses shadcn Form + Input + Button
│       ├── CreateDeviceForm.jsx    # Uses shadcn Form + Input + Select (device type) + Button
│       ├── CreateJobForm.jsx       # Uses shadcn Form + Input + Select (status) + Button
│       ├── EditJobForm.jsx         # Uses shadcn Form + Input + Button, wrapped in Dialog
│       ├── StatusChangeForm.jsx    # Uses shadcn Form + RadioGroup + Button, wrapped in Dialog
│       ├── LogPartForm.jsx         # Uses shadcn Form + Input + Button, wrapped in Sheet
│       └── AddStaffForm.jsx        # Uses shadcn Form + Input + Button, wrapped in Dialog
│
├── pages/
│   ├── LoginPage.jsx               # Login screen with 3 auth modes
│   ├── TechnicianPage.jsx          # Technician job list + actions
│   ├── ManagerPage.jsx             # Manager dashboard (donut, revenue, jobs)
│   ├── CustomerDetailPage.jsx      # Employee view of a customer (full profile)
│   └── MyRepairsPage.jsx           # Customer self-service portal
│
└── styles/
    └── theme.js                    # Design tokens as JS constants
```

---

## 5. Required Dependencies

### 5.1 Step 1: Install Runtime Dependencies

```bash
npm install react-router-dom axios react-hook-form @hookform/resolvers zod \
  recharts react-hot-toast lucide-react date-fns clsx tailwind-merge
```

| Package | Purpose |
|---------|---------|
| `react-router-dom` | Client-side routing with role protection |
| `axios` | HTTP client with interceptors |
| `react-hook-form` | Performant form management |
| `@hookform/resolvers` | Zod integration for RHF |
| `zod` | Schema validation for forms |
| `recharts` | Donut chart for manager dashboard |
| `react-hot-toast` | Toast notifications |
| `lucide-react` | Icon library (used by shadcn/ui and app) |
| `date-fns` | Date formatting |
| `clsx` | Conditional class utilities (shadcn dependency) |
| `tailwind-merge` | Merge Tailwind classes without conflicts (shadcn dependency) |

### 5.2 Step 2: Initialize shadcn/ui

```bash
npx shadcn@latest init
```

During init:
- Set `style` to `default` (uses Tailwind CSS classes).
- Set `base color` to `slate` (we will override with custom design tokens).
- Set `CSS variables` to `yes` (enables semantic theme tokens).
- Set `src/components/ui` as the component path (default).
- Set `src/lib/utils` as the utils path (default, generates the `cn()` function).
- Enable `React Server Components` if prompted — NO (this is a Vite SPA).

> **Tailwind v4 note:** If the shadcn CLI prompts about Tailwind config, select the CSS variables option. The `@theme` directive in `index.css` can accommodate both shadcn's CSS variable tokens (`--primary`, `--background`, etc.) and our custom color tokens (`--color-coral`, etc.) in the same block.

### 5.3 Step 3: Install shadcn Components

```bash
npx shadcn@latest add button input select dialog sheet badge skeleton avatar \
  card tabs separator radio-group label form alert-dialog command popover toggle tooltip
```

This copies the source files into `src/components/ui/`. Each component is now editable — customize their styles directly in the installed file to match the TechFix design tokens.

### 5.4 Step 4: Add Vite Path Alias

In `vite.config.js`, add the `@/` alias:

```js
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import path from "path";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
});
```

### 5.5 Dev Dependencies

The scaffold already includes: `vite`, `@vitejs/plugin-react`, `tailwindcss`, `@tailwindcss/vite`, `oxlint`. No additional dev deps needed.

---

## 6. Route Map

| Route | Page | Auth | Role | Description |
|-------|------|------|------|-------------|
| `/login` | `LoginPage` | Public | — | Owner/Employee/Customer login |
| `/` | Redirect | Auth | Any | Redirects to role-appropriate page |
| `/technician` | `TechnicianPage` | Auth | Employee, Owner | Job list with create/update/log part |
| `/dashboard` | `ManagerPage` | Auth | Owner | Analytics donut chart, revenue, all jobs |
| `/customers/:id` | `CustomerDetailPage` | Auth | Employee, Owner | Full customer profile (4 result sets) |
| `/my-repairs` | `MyRepairsPage` | Auth | Customer | Self-service: devices, jobs, cancel |

### 6.1 Route Protection

- `ProtectedRoute` component wraps authenticated routes.
- Checks `AuthContext` for `isAuthenticated` and required `role`.
- Redirects to `/login` if not authenticated.
- Shows "Access denied" if role doesn't match.

### 6.2 Redirect Logic

- After login: redirect based on role:
  - `Owner` → `/dashboard`
  - `Employee` → `/technician`
  - `Customer` → `/my-repairs`
- On `/` (root): redirect based on stored role.
- On 401 from any API call: redirect to `/login`.

---

## 7. Component Hierarchy

```
App
├── AuthProvider (context)
│   ├── BrowserRouter
│   │   ├── /login → LoginPage
│   │   │   ├── Background (CSS gradient + glow effects)
│   │   │   ├── Brandmark (logo/title)
│   │   │   ├── shadcn Tabs (Owner / Employee / Customer)
│   │   │   ├── LoginForm (shadcn Form + Input + Button)
│   │   │   │   ├── shadcn FormField + Input (email, type="email")
│   │   │   │   ├── shadcn FormField + Input (password, type="password", hidden for customer)
│   │   │   │   └── shadcn Button (type="submit", variant="default" = coral)
│   │   │   └── OwnerSignUpForm (shadcn Form + Input + Button)
│   │   │       ├── shadcn FormFields: org name, owner name, email, password
│   │   │       └── shadcn Button (type="submit")
│   │   │
│   │   └── ProtectedRoute → AppLayout
│   │       ├── Sidebar / TopBar
│   │       │   ├── shadcn Avatar (user initials, name, role fallback)
│   │       │   ├── NavLinks (uses shadcn Button variant="ghost")
│   │       │   ├── shadcn Separator
│   │       │   └── shadcn Button variant="ghost" (Sign Out)
│   │       │
│   │       ├── /technician → TechnicianPage
│   │       │   ├── shadcn Input (search bar, type="search")
│   │       │   ├── shadcn Toggle[] (Filter chips: All / Pending / Repairing)
│   │       │   ├── JobCard[] (expandable, using shadcn Card)
│   │       │   │   ├── StatusBadge (wraps shadcn Badge)
│   │       │   │   ├── shadcn Button[] (Edit Status / Edit Desc / Log Part)
│   │       │   │   └── Expandable usage list
│   │       │   ├── shadcn Sheet (create job wizard, 3-step)
│   │       │   │   ├── Step indicator
│   │       │   │   ├── CreateCustomerForm (step 1)
│   │       │   │   ├── CreateDeviceForm (step 2, uses shadcn Select for device type)
│   │       │   │   └── CreateJobForm (step 3, uses shadcn Select for status)
│   │       │   ├── shadcn Sheet (LogPartForm)
│   │       │   ├── shadcn Dialog (StatusChangeForm, uses shadcn RadioGroup)
│   │       │   └── shadcn Dialog (EditJobForm)
│   │       │
│   │       ├── /dashboard → ManagerPage
│   │       │   ├── DonutChart (Recharts PieChart in shadcn Card)
│   │       │   ├── RevenueCard (custom, in shadcn Card)
│   │       │   ├── shadcn Card header ("Recent Jobs")
│   │       │   ├── JobCard[] (paginated, all statuses)
│   │       │   ├── shadcn Button variant="outline" ("Show more")
│   │       │   └── shadcn Dialog (AddStaffForm)
│   │       │
│   │       ├── /customers/:id → CustomerDetailPage
│   │       │   ├── shadcn Avatar + Card (Profile: name, phone, email)
│   │       │   ├── StatCard[] (active repairs, ready today)
│   │       │   ├── Device cards (using shadcn Card)
│   │       │   ├── Job list (per device, shadcn AlertDialog for cancel confirm)
│   │       │   └── Usage table
│   │       │
│   │       └── /my-repairs → MyRepairsPage
│   │           ├── shadcn Card (profile info)
│   │           ├── StatCard[] (active, ready)
│   │           ├── Device section + jobs
│   │           └── shadcn AlertDialog (confirm cancel for Pending jobs)
```

---

## 8. API Integration Strategy

### 8.1 Axios Instance Factory

Create a factory function `createApiClient(baseUrl, email, password)` that returns an Axios instance with:

- `baseURL` set to the backend URL (default `http://localhost:3000`).
- Request interceptor that injects `Authorization: Basic <base64(email:password)>` header.
- Response interceptor that:
  - Unwraps `response.data.data` for success paths.
  - On 401: clears auth context and redirects to `/login`.
  - On error: normalizes error messages from `{ error: "..." }` response format.

### 8.2 Service Modules

Each service module receives the Axios instance (obtained via `useApi()` hook) and exposes async functions:

```js
// services/repairJobService.js
export const getRepairJobs = (api, { status, organizationId } = {}) =>
  api.get('/api/repair-jobs', { params: { status, organization_id: organizationId } })
     .then(res => res.data);

export const createRepairJob = (api, { deviceId, description, estimatedCost, status }) =>
  api.post('/api/repair-jobs', { device_id: deviceId, description, estimated_cost: estimatedCost, status })
     .then(res => res.data.job_id);
```

### 8.3 useApi Hook

```js
function useApi() {
  const { baseUrl, email, password } = useAuth();
  return useMemo(() => createApiClient(baseUrl, email, password), [baseUrl, email, password]);
}
```

### 8.4 API Method Mapping to Service Files

| Service File | Functions | Backend Endpoints |
|-------------|-----------|-------------------|
| `authService.js` | `loginEmployee`, `loginCustomer`, `createOwner` | 1, 2, 3 |
| `employeeService.js` | `createEmployee` | 4 |
| `customerService.js` | `createCustomer`, `getCustomerById` | 5, 6 |
| `repairJobService.js` | `getJobs`, `createJob`, `updateStatus`, `updateDescription`, `cancelJob` | 9, 10, 11, 12, 13 |
| `deviceService.js` | `createDevice` | 8 |
| `inventoryService.js` | `logPartUsage` | 14 |

Note: `GET /api/customers/me` (endpoint 7) uses customer auth (different auth header). The API client must be built with customer credentials.

### 8.5 Error Handling Convention

```js
// Component layer: catch and display toast
try {
  await createRepairJob(api, data);
  toast.success('Job created!');
} catch (err) {
  toast.error(err.message);
}
```

---

## 9. Authentication Implementation Plan

### 9.1 AuthContext State Shape

```js
{
  user: null | { id, organizationId, name, email, role },
  baseUrl: string,
  email: string,
  password: string,
  isAuthenticated: boolean,
  role: null | 'Owner' | 'Employee' | 'Customer',
  login: (baseUrl, email, password) => Promise<void>,
  logout: () => void,
}
```

### 9.2 Login Flow Detail

```
[Login Page]
   │
   ├── Owner Tab
   │   ├── Sign In sub-tab
   │   │   ├── Email + password fields
   │   │   ├── POST /api/auth/employee (Basic Auth)
   │   │   ├── Check role === 'Owner'
   │   │   ├── Store credentials + user → redirect /dashboard
   │   │   └── Error → toast
   │   │
   │   └── Sign Up sub-tab
   │       ├── Org name + owner name + email + password fields
   │       ├── POST /api/employees/owner (no auth)
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
       ├── POST /api/auth/customer (Basic Auth with empty password)
       ├── Store + inject role='Customer' + redirect /my-repairs
       └── Error → toast
```

### 9.3 Credential Storage

- **localStorage** — auth data is persisted via `localStorage` key `techfix_auth`. On reload, the app restores the session automatically.
- Sign out clears localStorage and redirects to `/login`.

### 9.4 Sign Out

- Clear context state → triggers `ProtectedRoute` redirect to `/login`.
- Toast "Signed out".

---

## 10. State Management Plan

### 10.1 AuthContext

The only global state. Manages credentials, current user, auth status, login/logout.

### 10.2 Page-Level State

Each page manages its own data-fetching state:

```
[TechnicianPage]
  jobs: Job[]           → useState, loaded on mount
  loading: boolean      → useState
  error: string | null  → useState
  searchQuery: string   → useState
  statusFilter: string | null → useState
  dialogType: string | null   → useState (orchestration)
  dialogJob: Job | null       → useState

[ManagerPage]
  jobs: Job[]           → useState
  loading: boolean
  error: string | null
  displayCount: number  → useState (pagination)

[CustomerDetailPage]
  customerData: {...}   → useState
  loading, error

[MyRepairsPage]
  customerData: {...}   → useState
  loading, error
```

### 10.3 Dialog Orchestration Pattern

Match the Flutter pattern: parent page stores `dialogType` and `dialogJob` state, conditionally renders shadcn Dialog/Sheet components:

```jsx
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Sheet, SheetContent, SheetHeader, SheetTitle } from '@/components/ui/sheet';

// In TechnicianPage render:
{dialogType === 'status' && dialogJob && (
  <Dialog open onOpenChange={(open) => !open && closeDialog()}>
    <DialogContent>
      <DialogHeader>
        <DialogTitle>Update Status</DialogTitle>
      </DialogHeader>
      <StatusChangeForm job={dialogJob} onSave={handleStatusChange} onCancel={closeDialog} />
    </DialogContent>
  </Dialog>
)}

{dialogType === 'create' && (
  <Sheet open onOpenChange={(open) => !open && closeDialog()}>
    <SheetContent side="right" className="sm:max-w-lg">
      <SheetHeader>
        <SheetTitle>Create Repair Job</SheetTitle>
      </SheetHeader>
      {/* 3-step wizard content */}
    </SheetContent>
  </Sheet>
)}
```

**Key shadcn components for overlay orchestration:**

| Purpose | shadcn Component | Notes |
|---------|-----------------|-------|
| Status change, Edit job, Add staff | `Dialog` + `DialogContent` | Centered modal |
| Confirm/cancel action | `AlertDialog` | Built-in confirm/cancel pattern |
| Create job wizard, Log part | `Sheet` | Slides in from right |
| Customer search results | `Popover` or `Sheet` | Lightweight overlay |

### 10.4 Data Refresh Pattern

After any mutation:
1. Show success toast.
2. Close dialog/sheet.
3. Re-fetch the affected data list.

---

## 11. Design System

The design system merges the existing TechFix brand tokens (coral, teal, sky, etc.) with shadcn/ui's semantic CSS variable system. shadcn components reference variables like `--primary`, `--background`, `--muted` — we map our brand colors onto these variables.

### 11.1 Semantic CSS Variable Mapping

```
shadcn Variable  →  TechFix Token
─────────────────────────────────
--primary        →  Coral #F26B4A
--primary-foreground → Cream #F7F3ED
--secondary      →  Teal #2A9D8F
--secondary-foreground → Cream
--accent         →  Sky #2D7BD1
--accent-foreground → Cream
--destructive    →  Coral (darker shade)
--background     →  Cream #F7F3ED
--foreground     →  Ink #141414
--card           →  Beige #EFE7DA
--card-foreground → Ink
--muted          →  Grey #9A958C
--muted-foreground → Grey
--border         →  line (8% ink)
--ring           →  Coral #F26B4A
```

### 11.2 CSS Theme (`index.css`)

```css
@import "tailwindcss";
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap');

@theme {
  --font-family-sans: 'Space Grotesk', sans-serif;

  /* Custom brand tokens */
  --color-coral: #F26B4A;
  --color-teal: #2A9D8F;
  --color-sky: #2D7BD1;
  --color-clay: #B86B4B;
  --color-ink: #141414;
  --color-cream: #F7F3ED;
  --color-beige: #EFE7DA;
  --color-grey: #9A958C;

  /* shadcn semantic tokens */
  --primary: var(--color-coral);
  --primary-foreground: var(--color-cream);
  --secondary: var(--color-teal);
  --secondary-foreground: var(--color-cream);
  --accent: var(--color-sky);
  --accent-foreground: var(--color-cream);
  --destructive: #e05a3a;
  --background: var(--color-cream);
  --foreground: var(--color-ink);
  --card: var(--color-beige);
  --card-foreground: var(--color-ink);
  --muted: var(--color-grey);
  --muted-foreground: var(--color-grey);
  --border: color-mix(in srgb, var(--color-ink) 8%, transparent);
  --ring: var(--color-coral);
  --radius: 0.75rem;
}
```

### 11.3 Status Color Helpers (`src/lib/constants.js`)

```js
export function statusColor(status) {
  const map = {
    Pending: '#B86B4B',    // clay
    Repairing: '#2D7BD1',  // sky
    Ready: '#2A9D8F',      // teal
    Delivered: '#2A9D8F',  // teal
    Cancelled: '#9A958C',  // grey
  };
  return map[status] || '#9A958C';
}

export function statusBg(status) {
  // Return color with 12% opacity for background fills
}
```

### 11.4 Customizing shadcn Components for Our Design

After installing each shadcn component, update its default styles:

- **button.jsx** — Set `default` variant to use `bg-primary` (auto-inherits coral). Add a `coral` variant (`bg-coral`) and `teal` variant (`bg-teal`).
- **badge.jsx** — The `secondary` variant auto-inherits teal from our variable mapping. Leave as-is since we wrap with `StatusBadge` for status-specific colors.
- **dialog.jsx** — Overlay scrim uses `bg-ink/60` with `backdrop-blur-sm`. Content uses `rounded-2xl` and `shadow-2xl`.
- **sheet.jsx** — Side panel uses `bg-beige` with `shadow-2xl`. Sidebar variant (left side) for layout.
- **tabs.jsx** — Active tab trigger uses `bg-coral text-cream`, inactive uses `text-muted-foreground`.
- **card.jsx** — Uses `bg-card` (beige) with `shadow-sm` and `rounded-xl`.
- **input.jsx** — Focus ring uses `ring-coral`. Background `bg-beige`, border `border-[color-mix(in_srgb,var(--color-ink)_14%,transparent)]`.

---

## 12. UI Implementation Order

### Phase 1: Foundation (skeleton)

| Step | File(s) | Description |
|------|---------|-------------|
| 1.1 | `src/styles/theme.js` | Color tokens, status helpers |
| 1.2 | `src/index.css` | Tailwind config, font import, global base styles |
| 1.3 | `src/lib/utils.js` | `fmtMoney`, `cn()` (clsx + tailwind-merge), helpers |
| 1.4 | `src/lib/constants.js` | Device types, status values, role labels |

### Phase 2: Auth + API Layer

| Step | File(s) | Description |
|------|---------|-------------|
| 2.1 | `src/config/api.js` | `createApiClient` with interceptors |
| 2.2 | `src/services/authService.js` | Login functions |
| 2.3 | `src/services/employeeService.js` | Create employee |
| 2.4 | `src/services/customerService.js` | Customer CRUD |
| 2.5 | `src/services/deviceService.js` | Device CRUD |
| 2.6 | `src/services/repairJobService.js` | Job CRUD |
| 2.7 | `src/services/inventoryService.js` | Part usage |
| 2.8 | `src/hooks/useApi.js` | Authenticated API hook |
| 2.9 | `src/hooks/useAuth.js` | Auth context shortcut |
| 2.10 | `src/context/AuthContext.jsx` | Auth state + provider |

### Phase 3: Layout + Routing

| Step | File(s) | Description |
|------|---------|-------------|
| 3.1 | `src/components/layout/ProtectedRoute.jsx` | Role-guard |
| 3.2 | `src/components/layout/Sidebar.jsx` | Nav sidebar |
| 3.3 | `src/components/layout/TopBar.jsx` | Header bar |
| 3.4 | `src/components/layout/AppLayout.jsx` | Layout shell |
| 3.5 | `src/App.jsx` | Router + provider wiring |
| 3.6 | `src/pages/LoginPage.jsx` | Login page with 3 modes |

### Phase 4: Shared UI Components

| Step | File(s) | Description |
|------|---------|-------------|
| 4.1 | — | `npx shadcn@latest add button input select dialog sheet badge skeleton avatar card tabs separator radio-group label form alert-dialog command popover toggle tooltip` |
| 4.2 | `src/components/ui/*.jsx` | Customize installed shadcn components: set coral as primary color, update focus rings, match button variants to our palette |
| 4.3 | `src/components/shared/StatusBadge.jsx` | Wraps shadcn `Badge` with color-map for each job status (Pending=clay, Repairing=sky, Ready=teal, etc.) |
| 4.4 | `src/components/shared/LoadingState.jsx` | Uses shadcn `Skeleton` + `Card` to render shimmer placeholders (configurable count) |
| 4.5 | `src/components/shared/EmptyState.jsx` | Icon + title + body text + optional shadcn `Button` action |
| 4.6 | `src/components/shared/ErrorState.jsx` | Error message + shadcn `Button` (variant="outline") for retry |
| 4.7 | `src/components/shared/SectionHeader.jsx` | Section title + optional action (e.g. shadcn `Button` variant="ghost") |
| 4.8 | `src/components/shared/StatCard.jsx` | Wraps shadcn `Card` with icon, animated value, and label |
| 4.9 | `src/components/shared/JobCard.jsx` | Expands to show device/customer info, status badge, cost; uses shadcn `Card` + `Badge` + `Button` |
| 4.10 | `src/components/shared/CustomerSearch.jsx` | Input + Button combo for employee customer lookup by ID |
| 4.11 | `src/components/shared/RevenueCard.jsx` | Dual-column finalized vs estimated revenue display |

### Phase 5: Login Page

| Step | File(s) | Description |
|------|---------|-------------|
| 5.1 | `src/pages/LoginPage.jsx` | Role tabs, form switching |
| 5.2 | `src/components/forms/LoginForm.jsx` | Email/password form with validation |
| 5.3 | `src/components/forms/OwnerSignUpForm.jsx` | Org registration form |

### Phase 6: Technician Page

| Step | File(s) | Description |
|------|---------|-------------|
| 6.1 | `src/pages/TechnicianPage.jsx` | Main page, job list, search, filter |
| 6.2 | `src/components/forms/CreateCustomerForm.jsx` | Step 1 of job creation |
| 6.3 | `src/components/forms/CreateDeviceForm.jsx` | Step 2 of job creation |
| 6.4 | `src/components/forms/CreateJobForm.jsx` | Step 3 of job creation |
| 6.5 | `src/components/forms/StatusChangeForm.jsx` | Status radio dialog |
| 6.6 | `src/components/forms/EditJobForm.jsx` | Edit desc/cost dialog |
| 6.7 | `src/components/forms/LogPartForm.jsx` | Log part sheet |

### Phase 7: Manager Dashboard

| Step | File(s) | Description |
|------|---------|-------------|
| 7.1 | `src/pages/ManagerPage.jsx` | Dashboard with donut + revenue + paginated jobs |
| 7.2 | Donut chart (inline via Recharts `PieChart`) | Status distribution |
| 7.3 | Revenue card | Dual-column finalized/estimated |
| 7.4 | `src/components/forms/AddStaffForm.jsx` | Create employee dialog |

### Phase 8: Customer Pages

| Step | File(s) | Description |
|------|---------|-------------|
| 8.1 | `src/pages/MyRepairsPage.jsx` | Customer self-service |
| 8.2 | `src/pages/CustomerDetailPage.jsx` | Employee view of customer |

---

## 13. Step-by-Step Development Roadmap

### Milestone 1: Foundation & Auth
**Goal:** User can log in as Owner/Employee/Customer and get redirected.

1. Set up Tailwind theme with design tokens.
2. Create utility functions (`fmtMoney`, `cn`).
3. Create Axios client factory with auth interceptor.
4. Build all service modules.
5. Build `AuthContext` with login/logout/state.
6. Build `ProtectedRoute` component.
7. Build `AppLayout` (sidebar + top bar).
8. Wire up `App.jsx` with router + providers.
9. Build `LoginPage` with 3 auth modes.
10. Test: Owner login → dashboard redirect. Employee login → technician redirect. Customer login → my-repairs redirect. Bad credentials → toast error.

### Milestone 2: Shared UI
**Goal:** All reusable UI primitives and shared components are installed and customized.

11. Run `npx shadcn@latest add button input select dialog sheet badge skeleton avatar card tabs separator radio-group label form alert-dialog command popover toggle tooltip`.
12. Customize installed shadcn components: update button default variant to coral, patch badge styling, configure dialog/sheet overlay colors.
13. Build `shared/` composites: `StatusBadge` (wraps shadcn Badge), `JobCard` (wraps shadcn Card), `StatCard`, `LoadingState` (uses shadcn Skeleton), `EmptyState`, `ErrorState`, `SectionHeader`, `CustomerSearch`, `RevenueCard`.

### Milestone 3: Technician Workflow
**Goal:** Full technician workflow — create jobs, update status, edit description, log parts.

14. Build `TechnicianPage` with job list, search, filter chips.
15. Build `StatusChangeForm` dialog.
16. Build `EditJobForm` dialog.
17. Build `LogPartForm` sheet.
18. Build 3-step create job flow.
19. Test: Create customer+device+job. Update status through lifecycle. Edit description. Log part.

### Milestone 4: Manager Dashboard
**Goal:** Owner sees analytics, all org jobs, can add staff.

20. Build `ManagerPage` with donut chart (Recharts PieChart).
21. Build revenue card (finalized vs estimated).
22. Build paginated job list with "Show more".
23. Build `AddStaffForm` dialog.
24. Test: Correct stats, donut chart, revenue numbers, adding staff works.

### Milestone 5: Customer Pages
**Goal:** Customer self-service and employee customer lookup.

25. Build `MyRepairsPage` (self-service).
26. Build `CustomerDetailPage` (employee customer search).
27. Test: Customer sees devices, cancels job. Employee loads customer by ID.

### Milestone 6: Polish & Testing
**Goal:** All flows verified, edge cases handled, responsive.

28. Global error boundary.
29. 401 auto-redirect interceptor.
30. Verify loading/error/empty states.
31. Verify responsive layout.
32. Verify all toast notifications.

---

## 14. Milestones

| # | Milestone | Deliverables | Status |
|---|-----------|-------------|--------|
| M1 | Foundation & Auth | Theme, API layer, AuthContext, LoginPage, ProtectedRoute, AppLayout | ✅ Complete |
| M2 | Shared UI | All UI primitives + shared components | ✅ Complete |
| M3 | Technician Workflow | TechnicianPage + all dialogs/sheets | ✅ Complete |
| M4 | Manager Dashboard | ManagerPage + donut + revenue + staff mgmt | ✅ Complete |
| M5 | Customer Pages | MyRepairsPage + CustomerDetailPage | ✅ Complete |
| M6 | Polish & Testing | Error handling, loading states, responsive, edge cases | ✅ Complete |

**All 6 milestones complete.**

---

## 15. Implementation Status

### 15.1 Testing Checklist (All ✅ Verified)

#### Authentication
- [x] Owner Sign In with valid credentials → redirects to `/dashboard`
- [x] Owner Sign In with employee credentials → error toast ("not an Owner account")
- [x] Employee Sign In → redirects to `/technician`
- [x] Customer Sign In with valid email → redirects to `/my-repairs`
- [x] Customer Sign In with invalid email → error toast
- [x] Owner Sign Up creates org + authenticates
- [x] Sign Out clears state and redirects to login
- [x] Visiting protected route while unauthenticated → redirects to login

#### Technician Flows
- [x] Job list loads with filter chips (All / Pending / Repairing)
- [x] Search filters by device name, customer name, job ID
- [x] Create job: 3-step wizard works end to end
- [x] Create job: validation catches empty required fields
- [x] Create job: can create with existing customer email (via customer auth lookup)
- [x] Update job status: only valid transitions shown
- [x] Edit job description: saves and reflects in list
- [x] Log part usage: part appears in job card expandable section
- [x] Loading state shown while fetching jobs
- [x] Error state with retry button on network failure
- [x] Empty state when no jobs match filter

#### Manager Dashboard
- [x] Donut chart displays correct status distribution
- [x] Revenue card shows correct finalized vs estimated totals
- [x] Job list loads with all statuses visible
- [x] Pagination: "Show more" increments by 10

#### Customer Pages
- [x] My Repairs: customer sees own profile, devices, jobs, parts used
- [x] My Repairs: cancel button appears only on Pending jobs
- [x] My Repairs: cancel sends POST and refreshes list
- [x] Customer Detail (employee): customer search by ID, shows 4 result sets

#### General
- [x] All API errors show toast with meaningful message
- [x] 401 from any API call → redirects to login
- [x] All loading states show skeleton animations
- [x] All empty states show appropriate message
- [x] Consistent spacing, colors, and typography across all pages

### 15.2 Current State & Deviations from Plan

| Plan Item | Actual | Note |
|-----------|--------|------|
| Route `/customers/:id` → CustomerDetailPage | **Not routed** | Component exists but no route in `App.jsx` — customer lookup is done via `CustomerSearch` on other pages |
| `Sidebar.jsx` in AppLayout | **Unused** | Layout simplified to single TopBar; Sidebar file kept for reference |
| Service modules (5 files) | **Dead code** | `customerService`, `deviceService`, `employeeService`, `inventoryService`, `repairJobService` are never imported — all API calls go through `useApi()` axios instance directly |
| Auth persistence | localStorage | Improvement over plan's "in-memory only" — session survives page refresh |
| AddStaff button/dialog | Removed from UI | Staff management deferred; `AddStaffForm.jsx` exists but not wired |
| Duplicate email handling | Auth endpoint lookup | `POST /api/auth/customer` checks for existing customer before creating |
| Parts display | Batch-fetch | Jobs carry `inventory_usage` via per-customer detail fetch (mirrors Flutter pattern) |

---

## 16. Final Polish Checklist (All ✅ Verified)

### UI Consistency
- [x] All buttons use correct color variant (coral primary)
- [x] All inputs have consistent height, padding, border radius
- [x] Status badges use correct colors per status
- [x] Cards have consistent shadow and border radius
- [x] Font is Space Grotesk throughout
- [x] No hardcoded `fontFamily` on individual elements

### Performance
- [x] Unused imports removed
- [x] No unnecessary re-renders (useCallback/useMemo where needed)

### Accessibility
- [x] All form inputs have associated labels
- [x] Buttons have discernible text
- [x] Color is never the only indicator (status badges have text)
- [x] Focus states visible on all interactive elements

### Code Quality
- [x] No console.log statements
- [x] All async operations have try/catch
- [x] Consistent naming conventions (camelCase)
- [x] No commented-out code

### Edge Cases
- [x] Empty job list displays EmptyState
- [x] Very long names don't break layout
- [x] Decimal cost values display correctly ($0.00, $1,234.56)
- [x] Date values format correctly
- [x] Network timeout shows error state
- [x] Duplicate email submission handled via customer auth lookup

---

## 17. Potential Backend Improvements

These are observations from analyzing the backend. They are **not required** for the frontend to function, but would improve the overall system:

### 17.1 Missing: Customer Update Endpoint

No `PUT /api/customers/:id` to update customer details (name, phone, email).

### 17.2 Missing: Job-Level Cost Summary

The manager dashboard currently needs N+1 requests to collect inventory usage per job. A `sp_get_job_with_usage(job_id)` procedure would eliminate this.

### 17.3 Missing: Organization Statistics Endpoint

A `sp_get_org_stats(org_id)` procedure could return counts per status, sum of final_cost, sum of estimated_cost, sum of part_cost — eliminating client-side KPI computation.

### 17.4 Pagination Support

`sp_get_repair_jobs` has no LIMIT/OFFSET. Adding pagination to the procedure would be more efficient for large orgs.

### 17.5 Employee Update/Delete

No endpoints to update or deactivate employees.

### 17.6 Device Search Endpoint

No `GET /api/devices?q=search` endpoint for finding devices faster during job creation.

---

## Appendix A: Flutter → React Mapping

| Flutter Screen | React Page | Notes |
|---------------|------------|-------|
| `LoginScreen` | `LoginPage` | Same 3-mode auth, match design tokens |
| `HomeShell` | `AppLayout` + `ProtectedRoute` | Replace IndexedStack with React Router |
| `TechnicianScreen` | `TechnicianPage` | Same layout: search, filter chips, job list, FAB |
| `ManagerScreen` | `ManagerPage` | Donut via Recharts instead of CustomPainter |
| `CustomerStatusScreen` | `CustomerDetailPage` / `MyRepairsPage` | Split into employee-view and customer-self |
| `StatusRadioDialog` | `StatusChangeForm` | Same radio pattern in Dialog shell |
| `EditDescDialog` | `EditJobForm` | Same fields in Dialog shell |
| `CreateJobSheet` | 3 forms in Sheet | Same 3-step wizard |
| `LogPartSheet` | `LogPartForm` | Same fields in Sheet shell |
| `AddStaffDialog` | `AddStaffForm` | Same fields in Dialog shell |

---

## Appendix B: Flutter Patterns → React Equivalents

| Flutter Pattern | React Equivalent |
|----------------|------------------|
| `AppSession` (ChangeNotifier) | `AuthContext` (useReducer) |
| `AppSessionScope.of(context)` | `useAuth()` hook |
| `showToast(context, msg, type)` | `toast.success()` / `toast.error()` |
| `TechFixApi` class | Axios instance + service modules |
| `_dialogType` + `_dialogJob` state | `dialogType` + `dialogJob` state |
| `TechFixDialog` shell | shadcn `Dialog` |
| `Sheet` shell | shadcn `Sheet` |
| `LoadingState` skeleton | shadcn `Skeleton` in `LoadingState` wrapper |
| `ErrorState` + retry | Custom `ErrorState` with shadcn `Button` |
| `EmptyState` | Custom `EmptyState` with shadcn `Button` |
| `JobCard` | Custom `JobCard` with shadcn `Card` + `Badge` + `Button` |
| `StatusBadge` | Custom `StatusBadge` wrapping shadcn `Badge` |
| `FilterChip` | shadcn `Toggle` with active state styling |
| `StatCard` | Custom `StatCard` with shadcn `Card` |
| `SectionHeader` | Custom `SectionHeader` with shadcn `Button` variant="ghost" |
| `Avatar` | shadcn `Avatar` with `AvatarFallback` (initials) |
| `Field` | shadcn `Input` + `Label` inside shadcn `FormField` |
| `DonutPainter` | Recharts `PieChart` in shadcn `Card` |
| `ConfirmDialog` | shadcn `AlertDialog` |

---

*End of Plan*
