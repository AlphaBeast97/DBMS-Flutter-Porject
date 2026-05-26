import express from "express";
import { createDevicesController } from "../controllers/devicesController.js";

export default function createDevicesRouter({ callProcedure }) {
  const router = express.Router();
  const controller = createDevicesController({ callProcedure });

  router.post("/", controller.createDevice);

  return router;
}
