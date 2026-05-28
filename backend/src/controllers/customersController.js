import { parsePositiveInt, requireString } from "../utils/validation.js";

export function createCustomersController({
  callProcedure,
  callProcedureMulti,
}) {
  return {
    createCustomer: async (req, res, next) => {
      try {
        const employeeId = req.employee?.employee_id;
        const employeeOrgId = req.employee?.organization_id;
        const requestedEmployeeId = parsePositiveInt(req.body.employee_id);
        const requestedOrgId = parsePositiveInt(req.body.organization_id);
        const organizationId = requestedOrgId || employeeOrgId;
        const name = requireString(req.body.name);
        const phone = requireString(req.body.phone);
        const email = requireString(req.body.email || "") || null;

        if (requestedEmployeeId && requestedEmployeeId !== employeeId) {
          return res
            .status(403)
            .json({ error: "employee_id does not match credentials" });
        }

        if (requestedOrgId && requestedOrgId !== employeeOrgId) {
          return res
            .status(403)
            .json({ error: "organization_id does not match credentials" });
        }

        if (!name) {
          return res.status(400).json({ error: "name is required" });
        }

        if (!phone) {
          return res.status(400).json({ error: "phone is required" });
        }

        const rows = await callProcedure("sp_create_customer", [
          organizationId,
          employeeId,
          name,
          phone,
          email,
        ]);

        return res.status(201).json({ data: rows[0] || {} });
      } catch (err) {
        return next(err);
      }
    },
    getCustomerById: async (req, res, next) => {
      try {
        const employeeId = req.employee?.employee_id;
        const requestedEmployeeId = parsePositiveInt(req.query.employee_id);
        const customerId = parsePositiveInt(req.params.id);

        if (requestedEmployeeId && requestedEmployeeId !== employeeId) {
          return res
            .status(403)
            .json({ error: "employee_id does not match credentials" });
        }

        if (!customerId) {
          return res.status(400).json({ error: "customer_id is required" });
        }

        const resultSets = await callProcedureMulti(
          "sp_get_customer_full_for_employee",
          [employeeId, customerId],
        );

        const customer = resultSets[0]?.[0] || null;
        const devices = resultSets[1] || [];
        const repairJobs = resultSets[2] || [];
        const inventoryUsage = resultSets[3] || [];

        if (!customer) {
          return res.status(404).json({ error: "customer not found" });
        }

        return res.status(200).json({
          data: {
            customer,
            devices,
            repair_jobs: repairJobs,
            inventory_usage: inventoryUsage,
          },
        });
      } catch (err) {
        return next(err);
      }
    },
    getCustomerSelf: async (req, res, next) => {
      try {
        const customerEmail = req.customer?.email;

        if (!customerEmail) {
          return res.status(400).json({ error: "customer email is required" });
        }

        const resultSets = await callProcedureMulti(
          "sp_get_customer_full_for_customer",
          [customerEmail],
        );

        const customer = resultSets[0]?.[0] || null;
        const devices = resultSets[1] || [];
        const repairJobs = resultSets[2] || [];
        const inventoryUsage = resultSets[3] || [];

        if (!customer) {
          return res.status(404).json({ error: "customer not found" });
        }

        return res.status(200).json({
          data: {
            customer,
            devices,
            repair_jobs: repairJobs,
            inventory_usage: inventoryUsage,
          },
        });
      } catch (err) {
        return next(err);
      }
    },
  };
}
