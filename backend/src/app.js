import cors from "cors";
import express from "express";
import { callProcedure } from "./db/callProcedure.js";
import errorHandler from "./middleware/errorHandler.js";
import createRepairJobsRouter from "./routes/repairJobs.js";

export function createApp({ callProcedure: callProcedureFn } = {}) {
  const app = express();
  const procedures = callProcedureFn || callProcedure;

  app.use(cors());
  app.use(express.json());

  app.get("/health", (req, res) => {
    res.status(200).json({ status: "ok" });
  });

  app.use("/api/repair-jobs", createRepairJobsRouter({ callProcedure: procedures }));

  app.use((req, res) => {
    res.status(404).json({ error: "Not Found" });
  });

  app.use(errorHandler);

  return app;
}

const app = createApp();

export default app;
