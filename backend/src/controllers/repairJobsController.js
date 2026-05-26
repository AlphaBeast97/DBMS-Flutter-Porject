const ALLOWED_STATUSES = new Set([
  "Pending",
  "Repairing",
  "Ready",
  "Delivered",
  "Cancelled"
]);

function parseEmployeeId(value) {
  const parsed = Number(value);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    return null;
  }

  return parsed;
}

export function createRepairJobsController({ callProcedure }) {
  return {
    getRepairJobs: async (req, res, next) => {
      try {
        const employeeId = parseEmployeeId(req.query.employee_id);
        const status = req.query.status;

        if (!employeeId) {
          return res.status(400).json({ error: "employee_id is required" });
        }

        if (status && !ALLOWED_STATUSES.has(status)) {
          return res.status(400).json({ error: "status is invalid" });
        }

        const rows = await callProcedure("sp_get_repair_jobs", [
          employeeId,
          status || null
        ]);

        return res.status(200).json({ data: rows });
      } catch (err) {
        return next(err);
      }
    }
  };
}
