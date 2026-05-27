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

test("POST /api/inventory-usage requires authorization", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app).post("/api/inventory-usage").send({});

  assert.equal(response.status, 401);
  assert.equal(response.body.error, "authorization required");
});

test("POST /api/inventory-usage logs usage", async () => {
  const rows = [{ usage_id: 301 }];
  const app = createApp({
    callProcedure: createMockCallProcedure(rows),
  });

  const response = await request(app)
    .post("/api/inventory-usage")
    .set("Authorization", authHeader)
    .send({
      job_id: 5,
      part_name: "Battery pack",
      part_cost: 3200,
    });

  assert.equal(response.status, 201);
  assert.deepEqual(response.body.data, rows[0]);
});
