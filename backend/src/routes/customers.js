import express from "express";
import { createCustomersController } from "../controllers/customersController.js";
import { createCustomerAuth, createEmployeeAuth } from "../middleware/auth.js";

export default function createCustomersRouter({
  callProcedure,
  callProcedureMulti,
}) {
  const router = express.Router();
  const requireEmployee = createEmployeeAuth({ callProcedure });
  const requireCustomer = createCustomerAuth({ callProcedure });
  const controller = createCustomersController({
    callProcedure,
    callProcedureMulti,
  });

  router.get("/me", requireCustomer, controller.getCustomerSelf);
  router.use(requireEmployee);
  router.post("/", controller.createCustomer);
  router.get("/:id", controller.getCustomerById);

  return router;
}
