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
          employee_id: 2,
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

test("POST /api/customers requires authorization", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app).post("/api/customers").send({});

  assert.equal(response.status, 401);
  assert.equal(response.body.error, "authorization required");
});

test("POST /api/customers creates a customer", async () => {
  const rows = [{ customer_id: 101 }];
  const app = createApp({
    callProcedure: createMockCallProcedure(rows),
  });

  const response = await request(app)
    .post("/api/customers")
    .set("Authorization", authHeader)
    .send({
      organization_id: 1,
      name: "Ayesha Malik",
      phone: "03001234567",
      email: "ayesha@example.com",
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
      [{ usage_id: 30 }],
    ],
    callProcedure: createMockCallProcedure([]),
  });

  const response = await request(app)
    .get("/api/customers/1")
    .set("Authorization", authHeader);

  assert.equal(response.status, 200);
  assert.equal(response.body.data.customer.customer_id, 1);
  assert.equal(response.body.data.devices.length, 1);
  assert.equal(response.body.data.repair_jobs.length, 1);
  assert.equal(response.body.data.inventory_usage.length, 1);
});
