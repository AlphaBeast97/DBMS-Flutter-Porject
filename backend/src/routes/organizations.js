import express from "express";
import { createOrganizationsController } from "../controllers/organizationsController.js";
import { createEmployeeAuth } from "../middleware/auth.js";

export default function createOrganizationsRouter({ callProcedure }) {
  const router = express.Router();
  const requireOwner = createEmployeeAuth({ callProcedure, roles: ["Owner"] });
  const controller = createOrganizationsController({ callProcedure });

  router.use(requireOwner);
  router.post("/", controller.createOrganization);

  return router;
}
