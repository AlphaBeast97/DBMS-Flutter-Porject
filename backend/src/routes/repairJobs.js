import express from "express";
import { createRepairJobsController } from "../controllers/repairJobsController.js";
import { createCustomerAuth, createEmployeeAuth } from "../middleware/auth.js";

export default function createRepairJobsRouter({ callProcedure }) {
  const router = express.Router();
  const requireEmployee = createEmployeeAuth({ callProcedure });
  const requireCustomer = createCustomerAuth({ callProcedure });
  const controller = createRepairJobsController({ callProcedure });

  router.post(
    "/:job_id/cancel",
    requireCustomer,
    controller.cancelRepairJobByCustomer,
  );
  router.use(requireEmployee);
  router.get("/", controller.getRepairJobs);
  router.post("/", controller.createRepairJob);
  router.put("/:job_id", controller.updateRepairJobStatus);
  router.put("/:job_id/description", controller.updateRepairJobDescription);

  return router;
}
