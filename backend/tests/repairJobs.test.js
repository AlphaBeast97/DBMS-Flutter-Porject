import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";

test("GET /api/repair-jobs requires employee_id", async () => {
  const app = createApp({
    callProcedure: async () => []
  });

  const response = await request(app).get("/api/repair-jobs");

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "employee_id is required");
});

test("GET /api/repair-jobs rejects invalid status", async () => {
  const app = createApp({
    callProcedure: async () => []
  });

  const response = await request(app).get(
    "/api/repair-jobs?employee_id=1&status=Unknown"
  );

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "status is invalid");
});

test("GET /api/repair-jobs returns data", async () => {
  const rows = [
    {
      job_id: 1,
      status: "Pending",
      description: "Battery drains quickly"
    }
  ];

  const app = createApp({
    callProcedure: async () => rows
  });

  const response = await request(app).get("/api/repair-jobs?employee_id=1");

  assert.equal(response.status, 200);
  assert.deepEqual(response.body.data, rows);
});
