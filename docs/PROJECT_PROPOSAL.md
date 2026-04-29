# TechFix – Digital Repair Workflow Manager

## Introduction

This project is developed as part of the DBMS course requirement. It demonstrates core relational database concepts in a practical, real-world scenario that solves an actual business problem faced by local repair shops.

## Group Members

- 70153904  Muhammad Saad Khan
- 70152951  Muhammad Shahrose Rafique
- 70152488  Junaid Ahmad
- 70149352  Mohsin Qureshi

---

## Project Title

**TechFix** – A practical, centralized digital repair workflow management system for local repair shops (mobile, laptop, gaming console repair).

---

## WHAT – The Problem & The Solution

### Problem Statement

Local repair shops today rely on paper receipts or simple spreadsheets, which creates major headaches:

- **Lost Information**: Forgetting which charger belongs to which laptop or which screen is intended for which device.
- **Customer Anxiety**: Customers calling constantly asking "Is it fixed yet?" without a reliable tracking system.
- **Parts Tracking**: No visibility into which parts have already been used, leading to waste or double-use of expensive components.
- **No Accountability**: No centralized record of who worked on what, when, and for how much.

TechFix solves this by creating a centralized MySQL database that tracks a device from the moment it's "Checked In" to the moment it's "Collected" by the customer.

### What We're Building

TechFix is a centralized database system that tracks a device from the moment it's "Checked In" to the moment it's "Collected" by the customer. The system allows:

- Technicians to check in devices, create repair jobs, update progress, and log parts used.
- Managers to view dashboards showing all repairs and inventory usage.
- Customers to check the status of their device repair.

Core workflow: **Check-In → Create Job → Repair → Log Parts → Mark Ready → Deliver**.

---

## WHY – Why This Matters

### Why TechFix Stands Out

While classmates are doing "Cinema" or "Hostel" management systems, TechFix stands out because:

- **Real Business Problem**: This solves an actual pain point for repair shops in Lahore, Karachi, and other cities. You could deploy this to a real business once completed.
- **Process-Driven**: You aren't just storing static data; you're tracking a real-world lifecycle—from a device arriving broken to leaving fixed. This reflects how businesses actually work.
- **Multi-Table Design**: To retrieve a complete repair receipt, you need to JOIN all four tables (Customers → Devices → Repair_Jobs → Inventory_Usage). This demonstrates technical depth and query complexity.
- **State Management**: The status field (Pending → Repairing → Ready → Delivered) shows how databases can track process workflows, not just store information.

### Why Relational Database Design Matters Here

A well-designed relational schema ensures:

- **Data Integrity**: Foreign keys prevent invalid data (e.g., a repair job can't reference a non-existent device).
- **No Redundancy**: Customer info is stored once; device info is stored once. Updates happen in one place.
- **Consistency**: Triggers can automatically calculate costs or prevent invalid transitions.

---

## HOW – The Technical Design

### Database Schema (The MySQL Design)

The design uses Foreign Keys to connect your data logically, which is exactly what your professors want to see in your EER Diagram:

- **Customers**: customer_id (PK), name, phone, email.
- **Devices**: device_id (PK), customer_id (FK), type (Laptop/Mobile/Console), brand, model, serial_number.
- **Repair_Jobs**: job_id (PK), device_id (FK), description (the issue), estimated_cost, status (Enum: 'Pending', 'Repairing', 'Ready', 'Delivered'), created_at.
- **Inventory_Usage**: usage_id (PK), job_id (FK), part_name, part_cost.

### CRUD Operations in Action

**CREATE**

- A new customer walks in → create record in Customers table.
- Their device is checked in → create Devices record linked to that customer.
- A repair job is created → link to that device.
- When a part is used → create Inventory_Usage record.

**READ**

- Technician dashboard reads all jobs where status = 'Repairing' to know what to work on today.
- Customer can read their repair job status by phone number or customer ID.
- Manager reads Inventory_Usage table to see which parts were used most and calculate total repair costs.

**UPDATE**

- When technician finishes a job → update status to 'Ready'.
- When customer collects device → update status to 'Delivered' and fill final_cost.
- Technician can update description if new issues are discovered.

**DELETE**

- If customer cancels a repair before work starts → delete that Repair_Job (with cascade rules).
- Alternatively, soft-delete (mark as cancelled) to keep audit trails.

### REST API Endpoints

The Express.js backend will expose these endpoints:

```
POST   /api/customers              → Register a new customer
POST   /api/devices                → Check in a device for repair
POST   /api/repair-jobs            → Create a repair job
GET    /api/repair-jobs            → Fetch all repair jobs with optional status filter
PUT    /api/repair-jobs/:job_id    → Update job status or description
POST   /api/inventory-usage        → Log parts used in a repair
GET    /api/customers/:customer_id → Fetch customer with all devices and repair jobs
```

---

## Expected Outcome

Upon completion, you will have built a complete, working system that demonstrates:

- ✅ **Normalized relational schema** with primary keys, foreign keys, and referential integrity.
- ✅ **Full CRUD operations** implemented and working via REST API.
- ✅ **Multi-table SELECT queries** with JOINs that retrieve complex data (e.g., a complete repair receipt).
- ✅ **Database triggers** that automate business logic (e.g., auto-calculate final cost).
- ✅ **A functional Flutter mobile app** that reads and writes to the database in real-time.
- ✅ **Error handling and validation** at both database and application layers.
- ✅ **A system ready for real-world deployment** to an actual repair shop.

---

## Flutter Frontend as Course Practice

This project also serves as excellent **practical hands-on experience for your Flutter course**. While the database and backend are the focus of DBMS, building the Flutter frontend allows you to:

- Practice state management and API integration in a real application context.
- Build three distinct user interfaces (Technician, Manager, Customer) in one app.
- Handle real-time data updates and error handling.
- Learn how a mobile app communicates with a backend database system.
- Reinforce DBMS concepts by seeing exactly how data flows: App → API → MySQL Database → Back to App.

This cross-course integration makes your project more valuable—you're learning both DBMS and Flutter simultaneously with a single codebase.

---

## Technology Stack

- **Frontend**: Flutter (mobile-first, also runnable on desktop)
- **Backend**: Node.js + Express.js (REST API)
- **Database**: MySQL

---

## Suggested PPT Presentation Flow

1. **Introduction Slide**: Team name and course details
2. **Group Members**: List of team members
3. **Project Title**: TechFix – Digital Repair Workflow Manager
4. **The Problem (WHAT)**: Challenges repair shops face today
5. **What We're Building**: Overview of the system and core workflow
6. **Why It Matters (WHY)**: Why this stands out compared to other projects + real-world relevance
7. **Why Relational Design Is Important**: How a well-designed schema maintains integrity
8. **How It Works (HOW) – Part 1**: Database schema with EER Diagram (all four tables and relationships)
9. **How It Works – Part 2**: Primary Keys and Foreign Keys explained
10. **How It Works – Part 3**: CRUD operations with real-world examples
11. **How It Works – Part 4**: Complex JOIN queries (e.g., a repair receipt)
12. **REST API Endpoints**: Brief overview of backend routes
13. **Flutter Frontend**: Screenshots or walkthrough of the app UI (Technician, Manager, Customer screens)
14. **Expected Outcome**: What the completed system will do
15. **Learning Across Courses**: How this project serves both DBMS and Flutter courses
16. **Conclusion & Key Takeaways**: What this project teaches about databases and real-world applications
