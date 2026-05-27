import express from "express";
import { createRepairJobsController } from "../controllers/repairJobsController.js";
import { createEmployeeAuth } from "../middleware/auth.js";

export default function createRepairJobsRouter({ callProcedure }) {
  const router = express.Router();
  const requireEmployee = createEmployeeAuth({ callProcedure });
  const controller = createRepairJobsController({ callProcedure });

  router.use(requireEmployee);
  router.get("/", controller.getRepairJobs);
  router.post("/", controller.createRepairJob);
  router.put("/:job_id", controller.updateRepairJobStatus);

  return router;
}
