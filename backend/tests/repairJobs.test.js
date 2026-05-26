import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";

test("GET /api/repair-jobs requires employee_id", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app).get("/api/repair-jobs");

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "employee_id is required");
});

test("GET /api/repair-jobs rejects invalid status", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app).get(
    "/api/repair-jobs?employee_id=1&status=Unknown",
  );

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "status is invalid");
});

test("GET /api/repair-jobs returns data", async () => {
  const rows = [
    {
      job_id: 1,
      status: "Pending",
      description: "Battery drains quickly",
    },
  ];

  const app = createApp({
    callProcedure: async () => rows,
  });

  const response = await request(app).get("/api/repair-jobs?employee_id=1");

  assert.equal(response.status, 200);
  assert.deepEqual(response.body.data, rows);
});

test("POST /api/repair-jobs validates required fields", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app).post("/api/repair-jobs").send({});

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "employee_id is required");
});

test("POST /api/repair-jobs creates a job", async () => {
  const rows = [{ job_id: 55 }];
  const app = createApp({
    callProcedure: async () => rows,
  });

  const response = await request(app).post("/api/repair-jobs").send({
    employee_id: 1,
    device_id: 2,
    description: "Battery drains",
    estimated_cost: 4500,
    status: "Pending",
  });

  assert.equal(response.status, 201);
  assert.deepEqual(response.body.data, rows[0]);
});

test("PUT /api/repair-jobs/:job_id validates status", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app)
    .put("/api/repair-jobs/10")
    .send({ employee_id: 1, status: "Cancelled" });

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "status is invalid");
});

test("PUT /api/repair-jobs/:job_id updates status", async () => {
  const rows = [{ rows_affected: 1 }];
  const app = createApp({
    callProcedure: async () => rows,
  });

  const response = await request(app)
    .put("/api/repair-jobs/10")
    .send({ employee_id: 1, status: "Ready" });

  assert.equal(response.status, 200);
  assert.deepEqual(response.body.data, rows[0]);
});
