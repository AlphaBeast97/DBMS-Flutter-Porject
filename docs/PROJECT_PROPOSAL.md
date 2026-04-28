# TechFix – Digital Repair Workflow Manager Project Proposal

## Project Title

**TechFix** – A practical, centralized digital repair workflow management system for local repair shops (mobile, laptop, gaming console repair).

## Problem Statement

Local repair shops today rely on paper receipts or simple spreadsheets, which creates major headaches:

- **Lost Information**: Forgetting which charger belongs to which laptop or which screen is intended for which device.
- **Customer Anxiety**: Customers calling constantly asking "Is it fixed yet?" without a reliable tracking system.
- **Parts Tracking**: No visibility into which parts have already been used, leading to waste or double-use of expensive components.
- **No Accountability**: No centralized record of who worked on what, when, and for how much.

TechFix solves this by creating a centralized MySQL database that tracks a device from the moment it's "Checked In" to the moment it's "Collected" by the customer.

## Solution Overview

A database-driven repair workflow manager that allows technicians to:

- Check in customer devices for repair.
- Create and track repair jobs with descriptions and estimated costs.
- Update job status as work progresses (Pending → Repairing → Ready → Delivered).
- Log parts used and their costs per repair.
- Provide customers with a way to check repair status.

## Database Schema (The MySQL Design)

The design uses Foreign Keys to connect your data logically, which is exactly what your professors want to see in your EER Diagram:

- **Customers**: customer_id (PK), name, phone, email.
- **Devices**: device_id (PK), customer_id (FK), type (Laptop/Mobile/Console), brand, model, serial_number.
- **Repair_Jobs**: job_id (PK), device_id (FK), description (the issue), estimated_cost, status (Enum: 'Pending', 'Repairing', 'Ready', 'Delivered'), created_at.
- **Inventory_Usage**: usage_id (PK), job_id (FK), part_name, part_cost.

## CRUD Operations in Action

For your PPT, explain how your Flutter app will interact with MySQL through the REST API:

### CREATE

- A new customer walks in; you create a record in Customers table.
- Their device is checked in; you create a Devices record linked to that customer.
- A repair job is created with a description, linked to that device.
- When a part is used, you create an Inventory_Usage record.

### READ

- The technician dashboard reads all jobs where status = 'Repairing' to know what to work on today.
- A customer can read their repair job status by phone number or customer ID.
- A manager reads the Inventory_Usage table to see which parts were used most and calculate total repair costs.

### UPDATE

- When the technician finishes a job, they update status to 'Ready'.
- When the customer collects the device, status is updated to 'Delivered' and final_cost is filled in.
- A technician can update the description if new issues are discovered.

### DELETE

- If a customer cancels a repair before work starts, you delete that specific Repair_Job (with proper cascade rules).
- You might soft-delete (mark as cancelled) instead of hard-delete to keep audit trails.

## Why This is "Unique" for Your Class

While classmates are doing "Cinema" or "Hostel" management, TechFix stands out because:

- **State Management**: You aren't just storing static data; you're tracking a real-world process (the lifecycle of a device repair from intake to delivery).
- **Multi-Table Joins**: To show a customer their full receipt and repair history, your SQL query has to JOIN all four tables—this demonstrates technical depth.
- **Real Utility**: You could actually walk into a repair shop in Lahore, Karachi, or any city and offer them this tool once you complete it. It solves a real business problem.
- **Business Logic in DB**: You can implement triggers to calculate total costs automatically, or validate that a job can't be marked "Ready" without required parts being logged.

## Technology Stack

- Frontend: Flutter
- Middleware: Node.js + Express.js
- Database: MySQL

## Expected Outcome

A complete DBMS project that demonstrates:

- Normalized relational schema design with referential integrity.
- Primary keys, foreign keys, and constraints in action.
- Multi-table SELECT queries with JOINs.
- Full CRUD operations implemented via a REST API.
- A frontend that reads and writes to the database in real-time.
- A system that could be deployed to a real business.

## Suggested PPT Flow

1. **Title Slide**: TechFix – Digital Repair Workflow Manager
2. **Problem Statement**: Challenges faced by local repair shops
3. **The Solution**: How a centralized database solves these challenges
4. **Database Design**: Show the EER Diagram with four tables and their relationships
5. **Primary Keys & Foreign Keys**: Explain how tables are connected
6. **Schema Details**: Walk through each table (Customers, Devices, Repair_Jobs, Inventory_Usage)
7. **CRUD Operations**: Demonstrate each operation with real-world examples
8. **Data Integrity & Constraints**: Show how referential integrity is maintained
9. **Complex Queries**: A sample multi-table JOIN query for a repair receipt
10. **Triggers & Automation** (Optional): Any database-level business logic
11. **API & Frontend Integration**: How the Flutter app communicates with the database via REST API
12. **Deployment Scenario**: Why this could work in a real repair shop
13. **Conclusion & Lessons Learned**
