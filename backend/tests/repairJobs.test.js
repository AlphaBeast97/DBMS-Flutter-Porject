import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";

const authHeader =
  "Basic " + Buffer.from("tech@example.com:pass").toString("base64");

function createMockCallProcedure(rows) {
  return async (name) => {
    if (name === "sp_employee_login") {
      return [
        {
          employee_id: 1,
          organization_id: 1,
          name: "Test",
          email: "tech@example.com",
          role: "Employee",
        },
      ];
    }

    return rows;
  };
}

test("GET /api/repair-jobs requires authorization", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app).get("/api/repair-jobs");

  assert.equal(response.status, 401);
  assert.equal(response.body.error, "authorization required");
});

test("GET /api/repair-jobs rejects invalid status", async () => {
  const app = createApp({
    callProcedure: createMockCallProcedure([]),
  });

  const response = await request(app)
    .get("/api/repair-jobs?status=Unknown")
    .set("Authorization", authHeader);

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
    callProcedure: createMockCallProcedure(rows),
  });

  const response = await request(app)
    .get("/api/repair-jobs")
    .set("Authorization", authHeader);

  assert.equal(response.status, 200);
  assert.deepEqual(response.body.data, rows);
});

test("GET /api/repair-jobs filters by organization_id", async () => {
  const rows = [
    {
      job_id: 2,
      status: "Repairing",
      description: "Screen replacement",
      organization_id: 5,
    },
  ];

  const app = createApp({
    callProcedure: async (name, params) => {
      if (name === "sp_employee_login") {
        return [
          {
            employee_id: 1,
            organization_id: 1,
            name: "Test",
            email: "tech@example.com",
            role: "Employee",
          },
        ];
      }
      // When org_id is provided, 3rd param should be passed
      if (name === "sp_get_repair_jobs" && params.length === 3 && params[2] === 5) {
        return rows;
      }
      return [];
    },
  });

  const response = await request(app)
    .get("/api/repair-jobs?organization_id=5")
    .set("Authorization", authHeader);

  assert.equal(response.status, 200);
  assert.deepEqual(response.body.data, rows);
});

test("POST /api/repair-jobs validates required fields", async () => {
  const app = createApp({
    callProcedure: createMockCallProcedure([]),
  });

  const response = await request(app)
    .post("/api/repair-jobs")
    .set("Authorization", authHeader)
    .send({});

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "device_id is required");
});

test("POST /api/repair-jobs creates a job", async () => {
  const rows = [{ job_id: 55 }];
  const app = createApp({
    callProcedure: createMockCallProcedure(rows),
  });

  const response = await request(app)
    .post("/api/repair-jobs")
    .set("Authorization", authHeader)
    .send({
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
    callProcedure: createMockCallProcedure([]),
  });

  const response = await request(app)
    .put("/api/repair-jobs/10")
    .set("Authorization", authHeader)
    .send({ status: "Cancelled" });

  assert.equal(response.status, 400);
  assert.equal(response.body.error, "status is invalid");
});

test("PUT /api/repair-jobs/:job_id updates status", async () => {
  const rows = [{ rows_affected: 1 }];
  const app = createApp({
    callProcedure: createMockCallProcedure(rows),
  });

  const response = await request(app)
    .put("/api/repair-jobs/10")
    .set("Authorization", authHeader)
    .send({ status: "Ready" });

  assert.equal(response.status, 200);
  assert.deepEqual(response.body.data, rows[0]);
});
