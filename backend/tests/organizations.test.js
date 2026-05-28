import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../src/app.js";
import { createMockCallProcedure } from "./testUtils.js";

const authHeader =
  "Basic " + Buffer.from("owner@techfix.com:Owner123").toString("base64");

test("POST /api/organizations creates an organization", async () => {
  const rows = [{ organization_id: 99 }];
  const app = createApp({
    callProcedure: async (name) => {
      if (name === "sp_employee_login") {
        return [
          {
            employee_id: 1,
            organization_id: 1,
            name: "Test Owner",
            email: "owner@techfix.com",
            role: "Owner",
          },
        ];
      }

      if (name === "sp_create_organization") {
        return rows;
      }

      return [];
    },
  });

  const response = await request(app)
    .post("/api/organizations")
    .set("Authorization", authHeader)
    .send({ name: "New Org Ltd" });

  assert.equal(response.status, 201);
  assert.deepEqual(response.body.data, rows[0]);
});
