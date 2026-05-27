import express from "express";
import { createInventoryUsageController } from "../controllers/inventoryUsageController.js";
import { createEmployeeAuth } from "../middleware/auth.js";

export default function createInventoryUsageRouter({ callProcedure }) {
  const router = express.Router();
  const requireEmployee = createEmployeeAuth({ callProcedure });
  const controller = createInventoryUsageController({ callProcedure });

  router.use(requireEmployee);
  router.post("/", controller.createInventoryUsage);

  return router;
}
