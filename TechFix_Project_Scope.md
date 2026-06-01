# TechFix — Repair Workflow Management System

## Project Scope & Problem Statement

Local electronics repair shops rely on paper job cards and verbal handoffs, leading to lost jobs, unclear accountability, and inaccurate cost tracking. TechFix provides a centralized digital platform that manages the complete repair lifecycle — from device check-in to delivery — for small-to-medium repair businesses.

## System Architecture (3-Tier)

TechFix uses a standard three-tier architecture. The **presentation tier** (React) communicates via REST APIs secured with HTTP Basic Auth. The **application tier** (Node.js/Express) validates requests, authenticates users, and delegates all data operations to the database — it never executes raw SQL or business logic. The **data tier** (MySQL) houses all business logic in stored procedures, functions, and triggers, enforcing referential integrity, status transitions, access scoping, and automated calculations. Data is isolated per organization — all write operations verify org membership, customers can only view their own records, employees see org data, and owners have full visibility across the shop.

## Target Users

| Role | Capabilities |
|------|-------------|
| **Owner** | Manages the shop and employees; has full visibility across all jobs, customers, and inventory. |
| **Employee (Technician)** | Creates and manages repair jobs, logs parts used, updates job statuses, and accesses customer/device records. |
| **Customer** | Views their own devices and repair job statuses via a self-service portal. |

## Core Data Entities

The system tracks six entities: **Organizations** (repair shops with fully isolated data), **Employees** (staff with Owner or Employee roles, authenticated via email and password), **Customers** (clients linked to an organization and the registering employee), **Devices** (physical items — laptop, mobile, console, tablet, or other — with brand, model, and serial number), **Repair Jobs** (the central entity with description, estimated cost, and a tracked status), and **Inventory Usage** (parts and components logged against a job with name and cost).

## Modules & Functionality

**Setup & Auth**: A shop registers by creating an organization and its first Owner in a single transaction. Owners can then add employees. Login uses email/password for employees and email-only for customers.

**Customer & Device Management**: Employees register customers and their devices under the organization. If a customer email already exists, the system returns the existing record (idempotent creation).

**Repair Job Lifecycle** (Core): A technician creates a job for a device with a description and estimated cost (status: *Pending*), begins work (*Repairing*), completes repairs (*Ready*), and marks it *Delivered* on customer pickup. A job can be *Cancelled* from Pending or Ready — but Delivered and Cancelled are terminal states that block all further updates. When a job is marked Delivered, a database trigger automatically calculates the final cost by summing all parts logged against that job.

**Inventory Usage**: During repairs, technicians log each part used (name and cost) against the job. A database function computes total parts cost per job, which feeds the auto-calculated final cost on delivery.

**Dashboard & Queries**: Employees view jobs filtered by status; owners see org-wide data. A detailed customer profile returns their information, all devices, all jobs, and all inventory usage in a single database call.

## End-to-End Workflow

1. An owner creates the organization and registers technicians.
2. A technician logs in, registers a customer and their device, then creates a repair job with a description and estimated cost (status: *Pending*).
3. The technician performs the repair, logs each part used against the job, and progresses the status through *Repairing* → *Ready*.
4. On customer pickup, the technician marks the job *Delivered* — the system auto-calculates the final cost from all logged parts.
5. The owner monitors all jobs via the dashboard; the customer checks their repair status through the self-service portal.
