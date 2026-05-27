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

test("POST /api/devices requires authorization", async () => {
  const app = createApp({
    callProcedure: async () => [],
  });

  const response = await request(app).post("/api/devices").send({});

  assert.equal(response.status, 401);
  assert.equal(response.body.error, "authorization required");
});

test("POST /api/devices creates a device", async () => {
  const rows = [{ device_id: 200 }];
  const app = createApp({
    callProcedure: createMockCallProcedure(rows),
  });

  const response = await request(app)
    .post("/api/devices")
    .set("Authorization", authHeader)
    .send({
      customer_id: 1,
      type: "Laptop",
      brand: "Dell",
      model: "Inspiron 15",
      serial_number: "DL-INSP-001",
    });

  assert.equal(response.status, 201);
  assert.deepEqual(response.body.data, rows[0]);
});
