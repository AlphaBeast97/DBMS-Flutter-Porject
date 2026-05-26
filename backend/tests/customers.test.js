import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";

test("POST /api/customers validates required fields", async () => {
  const app = createApp({
    callProcedure: async () => []
  });

  const response = await request(app).post("/api/customers").send({});

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "organization_id is required");
});

test("POST /api/customers creates a customer", async () => {
  const rows = [{ customer_id: 101 }];
  const app = createApp({
    callProcedure: async () => rows
  });

  const response = await request(app).post("/api/customers").send({
    organization_id: 1,
    employee_id: 2,
    name: "Ayesha Malik",
    phone: "03001234567",
    email: "ayesha@example.com"
  });

  assert.equal(response.status, 201);
  assert.deepEqual(response.body.data, rows[0]);
});

test("GET /api/customers/:id returns grouped data", async () => {
  const app = createApp({
    callProcedureMulti: async () => [
      [{ customer_id: 1, name: "Ayesha Malik" }],
      [{ device_id: 10 }],
      [{ job_id: 20 }],
      [{ usage_id: 30 }]
    ],
    callProcedure: async () => []
  });

  const response = await request(app).get("/api/customers/1?employee_id=2");

  assert.equal(response.status, 200);
  assert.equal(response.body.data.customer.customer_id, 1);
  assert.equal(response.body.data.devices.length, 1);
  assert.equal(response.body.data.repair_jobs.length, 1);
  assert.equal(response.body.data.inventory_usage.length, 1);
});
