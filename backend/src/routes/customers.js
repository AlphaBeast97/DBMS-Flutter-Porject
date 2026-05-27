import express from "express";
import { createCustomersController } from "../controllers/customersController.js";
import { createEmployeeAuth } from "../middleware/auth.js";

export default function createCustomersRouter({
  callProcedure,
  callProcedureMulti,
}) {
  const router = express.Router();
  const requireEmployee = createEmployeeAuth({ callProcedure });
  const controller = createCustomersController({
    callProcedure,
    callProcedureMulti,
  });

  router.use(requireEmployee);
  router.post("/", controller.createCustomer);
  router.get("/:id", controller.getCustomerById);

  return router;
}
