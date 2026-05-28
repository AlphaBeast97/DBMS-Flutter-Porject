import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";
import { createMockCallProcedure } from "./testUtils.js";

const ownerAuth =
  "Basic " + Buffer.from("owner@orgx.com:Owner123").toString("base64");

test("POST /api/employees/owner creates owner (org + owner)", async () => {
  const rows = [{ organization_id: 101, owner_employee_id: 201 }];
  const app = createApp({ callProcedure: createMockCallProcedure(rows) });

  const response = await request(app).post("/api/employees/owner").send({
    organization_name: "Org X",
    owner_name: "Alice",
    owner_email: "alice@orgx.com",
    password: "Secret1",
  });

  assert.equal(response.status, 201);
  assert.deepEqual(response.body.data, rows[0]);
});

test("POST /api/employees creates employee (owner-protected route)", async () => {
  const rows = [{ employee_id: 301 }];
  const app = createApp({
    callProcedure: async (name) => {
      if (name === "sp_employee_login") {
        return [
          {
            employee_id: 1,
            organization_id: 1,
            name: "Owner",
            email: "owner@orgx.com",
            role: "Owner",
          },
        ];
      }

      if (name === "sp_create_employee") return rows;
      return [];
    },
  });

  const response = await request(app)
    .post("/api/employees")
    .set("Authorization", ownerAuth)
    .send({ name: "Bob", email: "bob@orgx.com", password: "P@ssw0rd" });

  assert.equal(response.status, 201);
  assert.deepEqual(response.body.data, rows[0]);
});
