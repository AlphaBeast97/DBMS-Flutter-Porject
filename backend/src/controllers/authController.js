import { hashPassword, parseBasicAuth } from "../utils/auth.js";

export function createAuthController({ callProcedure }) {
  return {
    loginEmployee: async (req, res, next) => {
      try {
        const credentials = parseBasicAuth(req.headers.authorization);

        if (!credentials || !credentials.password) {
          return res.status(401).json({ error: "authorization required" });
        }

        const passwordHash = hashPassword(credentials.password);
        const rows = await callProcedure("sp_employee_login", [
          credentials.username,
          passwordHash,
        ]);

        const employee = rows[0];
        if (!employee) {
          return res.status(401).json({ error: "invalid credentials" });
        }

        return res.status(200).json({ data: employee });
      } catch (err) {
        return next(err);
      }
    },
    loginCustomer: async (req, res, next) => {
      try {
        const credentials = parseBasicAuth(req.headers.authorization);

        if (!credentials) {
          return res.status(401).json({ error: "authorization required" });
        }

        const rows = await callProcedure("sp_customer_login", [
          credentials.username,
        ]);

        const customer = rows[0];
        if (!customer) {
          return res.status(401).json({ error: "invalid credentials" });
        }

        return res.status(200).json({ data: customer });
      } catch (err) {
        return next(err);
      }
    },
  };
}
