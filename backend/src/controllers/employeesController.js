import { requireString } from "../utils/validation.js";
import { hashPassword } from "../utils/auth.js";

export function createEmployeesController({ callProcedure }) {
  return {
    createOwner: async (req, res, next) => {
      try {
        const organizationName = requireString(req.body.organization_name);
        const ownerName = requireString(req.body.owner_name);
        const ownerEmail = requireString(req.body.owner_email);
        const password = requireString(req.body.password);

        if (!organizationName) {
          return res
            .status(400)
            .json({ error: "organization_name is required" });
        }

        if (!ownerName) {
          return res.status(400).json({ error: "owner_name is required" });
        }

        if (!ownerEmail) {
          return res.status(400).json({ error: "owner_email is required" });
        }

        if (!password) {
          return res.status(400).json({ error: "password is required" });
        }

        const passwordHash = hashPassword(password);
        const rows = await callProcedure("sp_create_owner", [
          organizationName,
          ownerName,
          ownerEmail,
          passwordHash,
        ]);

        return res.status(201).json({ data: rows[0] || {} });
      } catch (err) {
        return next(err);
      }
    },
    createEmployee: async (req, res, next) => {
      try {
        const organizationId = req.employee?.organization_id;
        const name = requireString(req.body.name);
        const email = requireString(req.body.email);
        const password = requireString(req.body.password);

        if (!organizationId) {
          return res.status(400).json({ error: "organization_id is required" });
        }

        if (!name) {
          return res.status(400).json({ error: "name is required" });
        }

        if (!email) {
          return res.status(400).json({ error: "email is required" });
        }

        if (!password) {
          return res.status(400).json({ error: "password is required" });
        }

        const passwordHash = hashPassword(password);
        const rows = await callProcedure("sp_create_employee", [
          organizationId,
          name,
          email,
          passwordHash,
        ]);

        return res.status(201).json({ data: rows[0] || {} });
      } catch (err) {
        return next(err);
      }
    },
  };
}
