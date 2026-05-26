import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";

test("POST /api/devices validates required fields", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app).post("/api/devices").send({});

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "employee_id is required");
});

test("POST /api/devices creates a device", async () => {
  const rows = [{ device_id: 200 }];
  const app = createApp({
    callProcedure: async () => rows,
  });

  const response = await request(app).post("/api/devices").send({
    employee_id: 2,
    customer_id: 1,
    type: "Laptop",
    brand: "Dell",
    model: "Inspiron 15",
    serial_number: "DL-INSP-001",
  });

  assert.equal(response.status, 201);
  assert.deepEqual(response.body.data, rows[0]);
});
