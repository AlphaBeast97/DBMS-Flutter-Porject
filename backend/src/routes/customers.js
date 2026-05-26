import express from "express";
import { createCustomersController } from "../controllers/customersController.js";

export default function createCustomersRouter({ callProcedure, callProcedureMulti }) {
  const router = express.Router();
  const controller = createCustomersController({ callProcedure, callProcedureMulti });

  router.post("/", controller.createCustomer);
  router.get("/:id", controller.getCustomerById);

  return router;
}
