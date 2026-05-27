import "dotenv/config";
import assert from "node:assert/strict";
import { test } from "node:test";
import request from "supertest";
import { createApp } from "../../src/app.js";

const runDbTests = process.env.RUN_DB_TESTS === "1";

if (!runDbTests) {
  test.skip("DB integration tests are disabled", () => {});
}

if (runDbTests) {
  test("Integration flow with real database", async () => {
    const app = createApp();
    const uniqueTag = Date.now();

    const customerResponse = await request(app)
      .post("/api/customers")
      .send({
        organization_id: 1,
        employee_id: 1,
        name: `Integration Customer ${uniqueTag}`,
        phone: `0300${uniqueTag.toString().slice(-7)}`,
        email: `integration_${uniqueTag}@example.com`,
      });

    assert.equal(customerResponse.status, 201);
    const customerId = customerResponse.body.data.customer_id;
    assert.ok(customerId);

    const deviceResponse = await request(app)
      .post("/api/devices")
      .send({
        employee_id: 1,
        customer_id: customerId,
        type: "Laptop",
        brand: "Dell",
        model: "XPS",
        serial_number: `INT-${uniqueTag}`,
      });

    assert.equal(deviceResponse.status, 201);
    const deviceId = deviceResponse.body.data.device_id;
    assert.ok(deviceId);

    const jobResponse = await request(app).post("/api/repair-jobs").send({
      employee_id: 1,
      device_id: deviceId,
      description: "Integration test repair job",
      estimated_cost: 5000,
      status: "Pending",
    });

    assert.equal(jobResponse.status, 201);
    const jobId = jobResponse.body.data.job_id;
    assert.ok(jobId);

    const inventoryResponse = await request(app)
      .post("/api/inventory-usage")
      .send({
        employee_id: 1,
        job_id: jobId,
        part_name: "Integration Part",
        part_cost: 1250,
      });

    assert.equal(inventoryResponse.status, 201);
    assert.ok(inventoryResponse.body.data.usage_id);

    const updateResponse = await request(app)
      .put(`/api/repair-jobs/${jobId}`)
      .send({ employee_id: 1, status: "Ready" });

    assert.equal(updateResponse.status, 200);

    const listResponse = await request(app).get(
      "/api/repair-jobs?employee_id=1",
    );

    assert.equal(listResponse.status, 200);
    assert.ok(Array.isArray(listResponse.body.data));

    const customerDetailResponse = await request(app).get(
      `/api/customers/${customerId}?employee_id=1`,
    );

    assert.equal(customerDetailResponse.status, 200);
    assert.equal(
      customerDetailResponse.body.data.customer.customer_id,
      customerId,
    );
  });
}
