---
marp: true
theme: gaia
paginate: true
---

# **TechFix**
## Repair Workflow Management System
DBMS Project — MySQL 8.0 | Node.js + Express | React

---

# Architecture

```mermaid
graph LR
    subgraph Presentation
        R[React UI]
    end
    subgraph Application
        N[Node.js + Express]
    end
    subgraph Database
        M[(MySQL 8.0)]
    end
    R -->|HTTP Basic Auth| N
    N -->|CALL sp_*| M
    M -->|Result sets| N
    N -->|JSON| R
```

---

## Introduction

- Centralized platform for electronics repair shops
- Replaces paper job cards and verbal handoffs
- Manages full lifecycle: check-in → repair → delivery
- All business logic in MySQL stored procedures & triggers

---

## Domain Selection

- **Real-world** — repair shops everywhere but under-digitized
- **Rich relationships** — customers, devices, jobs, employees, parts
- **Clear workflow** — strict state machine, ideal for DB enforcement
- **Multi-tenant** — each shop is an isolated organization

---

## Problem Statement

- Lost paper job cards
- No real-time job status
- Manual cost calculations → errors
- No parts tracking
- No customer history

**Solution:** Structured, role-aware database with full audit trail

---

## Novelty — Part 1

- **All logic in stored procedures** — backend never executes raw DML
- **Trigger auto-cost** — sums parts cost automatically on delivery
- **Idempotent creation** — duplicate email returns existing record

---

## Novelty — Part 2

- **Org-scoped tenancy** — all writes validate org membership
- **No-password customer portal** — self-service via email only
- **ENUM specialization** — Owner/Employee via single-table discriminator

---

## Entity Relationship Diagram

```mermaid
erDiagram
    organizations ||--o{ employees : employs
    organizations ||--o{ customers : serves
    customers ||--o{ devices : owns
    devices ||--o{ repair_jobs : has
    repair_jobs ||--o{ inventory_usage : consumes
    employees ||--o{ customers : "created by"
    employees ||--o{ devices : "created by"
    employees ||--o{ repair_jobs : "created by"
    employees ||--o{ inventory_usage : "logged by"
```

6 entities · 9 FK relationships · Normalized 3NF

---

## Status Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Pending : Job created
    Pending --> Repairing : Technician starts
    Repairing --> Ready : Technician completes
    Ready --> Delivered : Customer picks up
    Pending --> Cancelled : Customer cancels
    Ready --> Cancelled : Customer cancels
    Delivered --> [*]
    Cancelled --> [*]
```

- Only customers cancel, from **Pending**
- **Delivered / Cancelled** — terminal, no further updates
- Trigger auto-computes `final_cost` on delivery

---

## Entity Overview

| Entity | Key Attributes |
|--------|---------------|
| **organizations** | org_id, name |
| **employees** | emp_id, org_id, name, email, role |
| **customers** | cust_id, org_id, name, phone, email |
| **devices** | device_id, cust_id, type, brand, model, serial |
| **repair_jobs** | job_id, device_id, desc, cost, status |
| **inventory_usage** | usage_id, job_id, part_name, part_cost |

---

## Constraints

| Type | Details |
|------|---------|
| **PKs** | 6 `INT AUTO_INCREMENT` |
| **FKs** | 9 relationships, CASCADE / RESTRICT |
| **UNIQUE** | employee email, customer email |
| **ENUM** | role, device type, job status |
| **CHECK** | Via `SIGNAL` in procedures |

---

## DBMS Features — Data Operations

| Feature | Detail |
|---------|--------|
| **Stored Procedures** | 12 procedures — all DML encapsulated |
| **Functions** | 1 function — `fn_parts_total()` |
| **Triggers** | 1 trigger — auto-cost on Delivered |
| **JOINs** | INNER, LEFT, 4-table chains |

---

## DBMS Features — Programmatic

| Feature | Detail |
|---------|--------|
| **Subqueries** | `EXISTS` for org-scope validation |
| **Transactions** | START TRANSACTION + ROLLBACK |
| **Error Handling** | SIGNAL SQLSTATE '45000' |
| **ENUMs** | Column-level domain enforcement |

---

## Stored Procedures

**12 procedures** across 5 categories:

| Category | Purpose |
|----------|---------|
| **Setup** | Create owner & employee |
| **Auth** | Employee & customer login |
| **Create** | Customer, device, job, inventory |
| **Update** | Job status, description, customer cancel |
| **Read** | Job listing, customer profile |

**Trigger:** `tr_repair_jobs_delivered_cost` auto-sets `final_cost`

---

## Trigger Flow

```mermaid
sequenceDiagram
    participant T as Technician
    participant API as Express API
    participant DB as MySQL
    participant TRG as Trigger
    T->>API: Mark job Delivered
    API->>DB: CALL sp_update_repair_job_status
    DB->>TRG: BEFORE UPDATE fires
    TRG->>DB: SELECT fn_parts_total(job_id)
    TRG->>DB: SET final_cost = sum
    DB-->>API: rows_affected = 1
    API-->>T: 200 OK
```

---

## Use-Cases

```mermaid
graph TD
    O[Owner] --> UC1[Register Organization]
    O --> UC2[View All Jobs]
    E[Employee] --> UC3[Login]
    E --> UC4[Register Customer]
    E --> UC5[Create Repair Job]
    E --> UC6[Update Job Status]
    E --> UC7[Log Parts Used]
    C[Customer] --> UC8[Login via Email]
    C --> UC9[Cancel Pending Job]
    C --> UC10[View My Repair Status]
```

All operations are org-scoped — no cross-shop data access.

---

## Sample Results

**Parts Function:** `SELECT fn_parts_total(3)` → **800.00**

**Trigger (Job 9 → Delivered):**
| | status | final_cost |
|--|--------|-----------|
| Before | Ready | NULL |
| After | Delivered | 1200.00 |

**Customer profile:** email login returns 4 result sets — info, devices, jobs, parts

---

## Workflow

```mermaid
sequenceDiagram
    actor O as Owner
    actor E as Technician
    actor C as Customer
    participant DB as MySQL
    O->>DB: Register organization
    E->>DB: Login
    E->>DB: Register customer + device
    E->>DB: Create repair job (Pending)
    E->>DB: Log parts, update to Repairing
    E->>DB: Mark job Ready
    C->>E: Picks up device
    E->>DB: Mark Delivered
    Note over DB: Trigger fires
    Note over E: final_cost auto-calculated
    O->>DB: View dashboard
    C->>DB: Check repair status
```

---

## Conclusion

- Normalized 3NF schema — 6 entities, full referential integrity
- 12 stored procedures + 1 function + 1 trigger
- Automated cost calculation, no manual entry
- Multi-tenant org-scoped isolation
- Role-aware access: Owner, Employee, Customer
- **Database as authoritative data layer** — consistent across any client
