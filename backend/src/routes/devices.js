import express from "express";
import { createDevicesController } from "../controllers/devicesController.js";
import { createEmployeeAuth } from "../middleware/auth.js";

export default function createDevicesRouter({ callProcedure }) {
  const router = express.Router();
  const requireEmployee = createEmployeeAuth({ callProcedure });
  const controller = createDevicesController({ callProcedure });

  router.use(requireEmployee);
  router.post("/", controller.createDevice);

  return router;
}
