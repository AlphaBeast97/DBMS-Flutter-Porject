import {
  parseOptionalNumber,
  parsePositiveInt,
  requireString,
} from "../utils/validation.js";

const LIST_STATUSES = new Set([
  "Pending",
  "Repairing",
  "Ready",
  "Delivered",
  "Cancelled",
]);

const WRITE_STATUSES = new Set(["Pending", "Repairing", "Ready", "Delivered"]);

export function createRepairJobsController({ callProcedure }) {
  return {
    getRepairJobs: async (req, res, next) => {
      try {
        const employeeId = req.employee?.employee_id;
        const requestedEmployeeId = parsePositiveInt(req.query.employee_id);
        const status = req.query.status;

        if (requestedEmployeeId && requestedEmployeeId !== employeeId) {
          return res
            .status(403)
            .json({ error: "employee_id does not match credentials" });
        }

        if (status && !LIST_STATUSES.has(status)) {
          return res.status(400).json({ error: "status is invalid" });
        }

        const rows = await callProcedure("sp_get_repair_jobs", [
          employeeId,
          status || null,
        ]);

        return res.status(200).json({ data: rows });
      } catch (err) {
        return next(err);
      }
    },
    createRepairJob: async (req, res, next) => {
      try {
        const employeeId = req.employee?.employee_id;
        const deviceId = parsePositiveInt(req.body.device_id);
        const requestedEmployeeId = parsePositiveInt(req.body.employee_id);
        const description = requireString(req.body.description);
        const status = req.body.status;
        const estimatedCost = parseOptionalNumber(req.body.estimated_cost);

        if (requestedEmployeeId && requestedEmployeeId !== employeeId) {
          return res
            .status(403)
            .json({ error: "employee_id does not match credentials" });
        }

        if (!deviceId) {
          return res.status(400).json({ error: "device_id is required" });
        }

        if (!description) {
          return res.status(400).json({ error: "description is required" });
        }

        if (status && !WRITE_STATUSES.has(status)) {
          return res.status(400).json({ error: "status is invalid" });
        }

        if (estimatedCost !== null && estimatedCost < 0) {
          return res.status(400).json({ error: "estimated_cost is invalid" });
        }

        const rows = await callProcedure("sp_create_repair_job", [
          employeeId,
          deviceId,
          description,
          estimatedCost,
          status || null,
        ]);

        return res.status(201).json({ data: rows[0] || {} });
      } catch (err) {
        return next(err);
      }
    },
    updateRepairJobStatus: async (req, res, next) => {
      try {
        const employeeId = req.employee?.employee_id;
        const jobId = parsePositiveInt(req.params.job_id);
        const requestedEmployeeId = parsePositiveInt(req.body.employee_id);
        const status = req.body.status;

        if (requestedEmployeeId && requestedEmployeeId !== employeeId) {
          return res
            .status(403)
            .json({ error: "employee_id does not match credentials" });
        }

        if (!jobId) {
          return res.status(400).json({ error: "job_id is required" });
        }

        if (!status) {
          return res.status(400).json({ error: "status is required" });
        }

        if (!WRITE_STATUSES.has(status)) {
          return res.status(400).json({ error: "status is invalid" });
        }

        const rows = await callProcedure("sp_update_repair_job_status", [
          employeeId,
          jobId,
          status,
        ]);

        return res.status(200).json({ data: rows[0] || {} });
      } catch (err) {
        return next(err);
      }
    },
    updateRepairJobDescription: async (req, res, next) => {
      try {
        const employeeId = req.employee?.employee_id;
        const jobId = parsePositiveInt(req.params.job_id);
        const requestedEmployeeId = parsePositiveInt(req.body.employee_id);
        const description = requireString(req.body.description);

        if (requestedEmployeeId && requestedEmployeeId !== employeeId) {
          return res
            .status(403)
            .json({ error: "employee_id does not match credentials" });
        }

        if (!jobId) {
          return res.status(400).json({ error: "job_id is required" });
        }

        if (!description) {
          return res.status(400).json({ error: "description is required" });
        }

        const rows = await callProcedure("sp_update_repair_job_description", [
          employeeId,
          jobId,
          description,
        ]);

        return res.status(200).json({ data: rows[0] || {} });
      } catch (err) {
        return next(err);
      }
    },
    cancelRepairJobByCustomer: async (req, res, next) => {
      try {
        const customerId = req.customer?.customer_id;
        const jobId = parsePositiveInt(req.params.job_id);

        if (!customerId) {
          return res.status(400).json({ error: "customer_id is required" });
        }

        if (!jobId) {
          return res.status(400).json({ error: "job_id is required" });
        }

        const rows = await callProcedure("sp_cancel_repair_job_by_customer", [
          customerId,
          jobId,
        ]);

        return res.status(200).json({ data: rows[0] || {} });
      } catch (err) {
        return next(err);
      }
    },
  };
}
