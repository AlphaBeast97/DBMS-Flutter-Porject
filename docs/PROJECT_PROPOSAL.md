# Mini-Store Management System Project Proposal

## Overview

This project is a DBMS-based mini-store application designed to demonstrate how a relational database can be used to manage store operations in a structured and reliable way. The system focuses on core database concepts such as table design, primary keys, foreign keys, normalization, constraints, triggers, and transactions. The main goal is to build a small but practical system that shows how product inventory, customer orders, and order details can be stored and managed efficiently.

## Problem Statement

Small store workflows often need a simple and reliable way to store product data, category information, customer orders, and stock updates. A relational database is a good fit because it can enforce rules, keep data consistent, and prevent duplicate or invalid records. This project demonstrates how a well-designed database can support those operations without unnecessary complexity.

## Objectives

- Design a normalized relational schema for store data.
- Enforce data integrity with primary keys, foreign keys, and constraints.
- Use a trigger to automatically update stock after order items are inserted.
- Use transactions to keep order creation consistent.
- Build a simple Flutter and Express interface to interact with the database.

## Core Database Entities

- Categories: stores product group names.
- Products: stores item details, price, stock, and category.
- Orders: stores order-level purchase data.
- Order_Items: stores the individual products and quantities inside each order.

## DBMS Focus

A major part of the project is maintaining referential integrity. Every product must belong to a valid category, and every order item must reference an existing order and product. This prevents invalid data from being inserted into the database and keeps the system reliable.

The schema also uses normalization to reduce redundancy. Category data is stored once in the categories table instead of being repeated for every product. Order data is separated from order item data so each table stores only its own responsibility.

The project will also use a trigger to reduce product stock automatically when a new order item is inserted. This is a practical example of database automation. In addition, the order creation process will use a transaction so that all related inserts succeed together or fail together, which protects the database from partial updates.

## Application Flow

- Customer views available products.
- Customer places an order using a Buy button.
- Admin adds new products through a simple form.
- The backend sends requests from Flutter to MySQL through an Express API.

## Technology Stack

- Frontend: Flutter
- Middleware: Node.js + Express.js
- Database: MySQL

## Expected Outcome

The result will be a small but complete DBMS project that clearly demonstrates relational database design and usage in a practical application. It will show how a well-structured schema, constraints, triggers, and transactions work together to maintain accurate and reliable store data.

## Suggested PPT Flow

1. Title slide
2. Problem statement from a DBMS perspective
3. Objectives of the project
4. Why relational database design is needed
5. Technology stack
6. Database schema overview
7. Table relationships and foreign keys
8. Normalization and data integrity
9. Trigger and transaction usage
10. Backend and frontend integration
11. Expected output
12. Conclusion
