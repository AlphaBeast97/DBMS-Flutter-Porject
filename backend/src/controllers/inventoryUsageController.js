import { parseOptionalNumber, parsePositiveInt, requireString } from "../utils/validation.js";

export function createInventoryUsageController({ callProcedure }) {
  return {
    createInventoryUsage: async (req, res, next) => {
      try {
        const employeeId = parsePositiveInt(req.body.employee_id);
        const jobId = parsePositiveInt(req.body.job_id);
        const partName = requireString(req.body.part_name);
        const partCost = parseOptionalNumber(req.body.part_cost);

        if (!employeeId) {
          return res.status(400).json({ error: "employee_id is required" });
        }

        if (!jobId) {
          return res.status(400).json({ error: "job_id is required" });
        }

        if (!partName) {
          return res.status(400).json({ error: "part_name is required" });
        }

        if (partCost !== null && partCost < 0) {
          return res.status(400).json({ error: "part_cost is invalid" });
        }

        const rows = await callProcedure("sp_log_inventory_usage", [
          employeeId,
          jobId,
          partName,
          partCost
        ]);

        return res.status(201).json({ data: rows[0] || {} });
      } catch (err) {
        return next(err);
      }
    }
  };
}
