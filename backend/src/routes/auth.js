import express from "express";
import { createAuthController } from "../controllers/authController.js";

export default function createAuthRouter({ callProcedure }) {
  const router = express.Router();
  const controller = createAuthController({ callProcedure });

  router.post("/employee", controller.loginEmployee);
  router.post("/customer", controller.loginCustomer);

  return router;
}
