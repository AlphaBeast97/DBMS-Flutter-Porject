import cors from "cors";
import express from "express";
import { callProcedure, callProcedureMulti } from "./db/callProcedure.js";
import errorHandler from "./middleware/errorHandler.js";
import createCustomersRouter from "./routes/customers.js";
import createDevicesRouter from "./routes/devices.js";
import createInventoryUsageRouter from "./routes/inventoryUsage.js";
import createRepairJobsRouter from "./routes/repairJobs.js";

export function createApp({
  callProcedure: callProcedureFn,
  callProcedureMulti: callProcedureMultiFn,
} = {}) {
  const app = express();
  const procedures = {
    callProcedure: callProcedureFn || callProcedure,
    callProcedureMulti: callProcedureMultiFn || callProcedureMulti,
  };

  app.use(cors());
  app.use(express.json());

  app.get("/health", (req, res) => {
    res.status(200).json({ status: "ok" });
  });

  app.use("/api/customers", createCustomersRouter(procedures));
  app.use("/api/devices", createDevicesRouter(procedures));
  app.use("/api/repair-jobs", createRepairJobsRouter(procedures));
  app.use("/api/inventory-usage", createInventoryUsageRouter(procedures));

  app.use((req, res) => {
    res.status(404).json({ error: "Not Found" });
  });

  app.use(errorHandler);

  return app;
}

const app = createApp();

export default app;
