import express from "express";
import { createRepairJobsController } from "../controllers/repairJobsController.js";

export default function createRepairJobsRouter({ callProcedure }) {
  const router = express.Router();
  const controller = createRepairJobsController({ callProcedure });

  router.get("/", controller.getRepairJobs);

  return router;
}
