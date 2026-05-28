import express from "express";
import { createEmployeesController } from "../controllers/employeesController.js";
import { createEmployeeAuth } from "../middleware/auth.js";

export default function createEmployeesRouter({ callProcedure }) {
  const router = express.Router();
  const requireOwner = createEmployeeAuth({ callProcedure, roles: ["Owner"] });
  const controller = createEmployeesController({ callProcedure });

  router.post("/owner", controller.createOwner);
  router.post("/", requireOwner, controller.createEmployee);

  return router;
}
