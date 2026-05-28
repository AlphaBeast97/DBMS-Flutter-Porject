import { requireString } from "../utils/validation.js";

export function createOrganizationsController({ callProcedure }) {
  return {
    createOrganization: async (req, res, next) => {
      try {
        const name = requireString(req.body.name);

        if (!name) {
          return res.status(400).json({ error: "name is required" });
        }

        const rows = await callProcedure("sp_create_organization", [name]);

        return res.status(201).json({ data: rows[0] || {} });
      } catch (err) {
        return next(err);
      }
    },
  };
}
