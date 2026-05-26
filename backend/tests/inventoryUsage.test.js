import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";

test("POST /api/inventory-usage validates required fields", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app).post("/api/inventory-usage").send({});

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "employee_id is required");
});

test("POST /api/inventory-usage logs usage", async () => {
  const rows = [{ usage_id: 301 }];
  const app = createApp({
    callProcedure: async () => rows,
  });

  const response = await request(app).post("/api/inventory-usage").send({
    employee_id: 2,
    job_id: 5,
    part_name: "Battery pack",
    part_cost: 3200,
  });

  assert.equal(response.status, 201);
  assert.deepEqual(response.body.data, rows[0]);
});
