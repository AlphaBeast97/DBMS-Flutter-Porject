import { parsePositiveInt, requireString } from "../utils/validation.js";

export function createDevicesController({ callProcedure }) {
  return {
    createDevice: async (req, res, next) => {
      try {
        const employeeId = parsePositiveInt(req.body.employee_id);
        const customerId = parsePositiveInt(req.body.customer_id);
        const type = requireString(req.body.type);
        const brand = requireString(req.body.brand);
        const model = requireString(req.body.model);
        const serialNumber = requireString(req.body.serial_number);

        if (!employeeId) {
          return res.status(400).json({ error: "employee_id is required" });
        }

        if (!customerId) {
          return res.status(400).json({ error: "customer_id is required" });
        }

        if (!type) {
          return res.status(400).json({ error: "type is required" });
        }

        if (!brand) {
          return res.status(400).json({ error: "brand is required" });
        }

        if (!model) {
          return res.status(400).json({ error: "model is required" });
        }

        if (!serialNumber) {
          return res.status(400).json({ error: "serial_number is required" });
        }

        const rows = await callProcedure("sp_create_device", [
          employeeId,
          customerId,
          type,
          brand,
          model,
          serialNumber,
        ]);

        return res.status(201).json({ data: rows[0] || {} });
      } catch (err) {
        return next(err);
      }
    },
  };
}
