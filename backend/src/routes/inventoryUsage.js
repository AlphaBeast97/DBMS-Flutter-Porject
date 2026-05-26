import express from "express";
import { createInventoryUsageController } from "../controllers/inventoryUsageController.js";

export default function createInventoryUsageRouter({ callProcedure }) {
  const router = express.Router();
  const controller = createInventoryUsageController({ callProcedure });

  router.post("/", controller.createInventoryUsage);

  return router;
}
