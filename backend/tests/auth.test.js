import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";

const employeeAuth =
  "Basic " + Buffer.from("tech@example.com:pass").toString("base64");
const customerAuth =
  "Basic " + Buffer.from("customer@example.com:").toString("base64");

function createMockCallProcedure() {
  return async (name) => {
    if (name === "sp_employee_login") {
      return [
        {
          employee_id: 1,
          organization_id: 1,
          name: "Test",
          email: "tech@example.com",
          role: "Owner",
        },
      ];
    }

    if (name === "sp_customer_login") {
      return [
        {
          customer_id: 1,
          organization_id: 1,
          name: "Test Customer",
          email: "customer@example.com",
        },
      ];
    }

    return [];
  };
}

test("POST /api/auth/employee requires authorization", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app).post("/api/auth/employee");

  assert.equal(response.status, 401);
  assert.equal(response.body.error, "authorization required");
});

test("POST /api/auth/employee returns employee data", async () => {
  const app = createApp({
    callProcedure: createMockCallProcedure(),
  });

  const response = await request(app)
    .post("/api/auth/employee")
    .set("Authorization", employeeAuth);

  assert.equal(response.status, 200);
  assert.equal(response.body.data.employee_id, 1);
});

test("POST /api/auth/customer returns customer data", async () => {
  const app = createApp({
    callProcedure: createMockCallProcedure(),
  });

  const response = await request(app)
    .post("/api/auth/customer")
    .set("Authorization", customerAuth);

  assert.equal(response.status, 200);
  assert.equal(response.body.data.customer_id, 1);
});
