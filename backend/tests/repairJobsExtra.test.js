import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";
import { createMockCallProcedure } from "./testUtils.js";

const authHeader =
  "Basic " + Buffer.from("tech@example.com:Tech123").toString("base64");

test("PUT /api/repair-jobs/:job_id/description updates job description", async () => {
  const rows = [{ rows_affected: 1 }];
  const app = createApp({
    callProcedure: async (name) => {
      if (name === "sp_employee_login") {
        return [
          {
            employee_id: 1,
            organization_id: 1,
            name: "Tech",
            email: "tech@example.com",
            role: "Employee",
          },
        ];
      }

      if (name === "sp_update_repair_job_description") return rows;
      return [];
    },
  });

  const response = await request(app)
    .put("/api/repair-jobs/123/description")
    .set("Authorization", authHeader)
    .send({ description: "Updated description" });

  assert.equal(response.status, 200);
  assert.deepEqual(response.body.data, rows[0]);
});

test("POST /api/repair-jobs/:job_id/cancel cancels a repair job by customer", async () => {
  const rows = [{ rows_affected: 1 }];
  const app = createApp({
    callProcedure: async (name) => {
      if (name === "sp_customer_login") {
        return [
          {
            customer_id: 1,
            organization_id: 1,
            name: "Cust",
            email: "customer@example.com",
          },
        ];
      }

      if (name === "sp_cancel_repair_job_by_customer") return rows;
      return [];
    },
  });

  const response = await request(app)
    .post("/api/repair-jobs/123/cancel")
    .set("Authorization", authHeader) // customer auth uses same header in mock
    .send();

  assert.equal(response.status, 200);
  assert.deepEqual(response.body.data, rows[0]);
});
