import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";
import { createMockCallProcedureMulti } from "./testUtils.js";

const customerAuth = "Basic Y3VzdEBleGFtcGxlLmNvbTo=";

test("GET /api/customers/me returns customer self data (multi result)", async () => {
  const resultSets = [
    [{ customer_id: 1, name: "John" }],
    [{ device_id: 10 }],
    [{ job_id: 100 }],
    [{ usage_id: 500 }],
  ];

  const app = createApp({
    callProcedure: async (name) => {
      if (name === "sp_customer_login") {
        return [
          {
            customer_id: 1,
            organization_id: 1,
            name: "John",
            email: "customer@example.com",
          },
        ];
      }

      return [];
    },
    callProcedureMulti: createMockCallProcedureMulti(resultSets),
  });

  const response = await request(app)
    .get("/api/customers/me")
    .set("Authorization", customerAuth)
    .send();

  assert.equal(response.status, 200);
  assert.equal(response.body.data.customer.customer_id, 1);
  assert.equal(response.body.data.devices.length, 1);
  assert.equal(response.body.data.repair_jobs.length, 1);
  assert.equal(response.body.data.inventory_usage.length, 1);
});
