import { hashPassword, parseBasicAuth } from "../utils/auth.js";

export function createEmployeeAuth({
  callProcedure,
  roles = ["Owner", "Employee"],
}) {
  return async function employeeAuth(req, res, next) {
    try {
      const authHeader = req.headers.authorization;
      const credentials = parseBasicAuth(authHeader);

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

      if (roles.length && !roles.includes(employee.role)) {
        return res.status(403).json({ error: "forbidden" });
      }

      req.employee = employee;
      return next();
    } catch (err) {
      return next(err);
    }
  };
}

export function createCustomerAuth({ callProcedure }) {
  return async function customerAuth(req, res, next) {
    try {
      const authHeader = req.headers.authorization;
      const credentials = parseBasicAuth(authHeader);

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

      req.customer = customer;
      return next();
    } catch (err) {
      return next(err);
    }
  };
}
