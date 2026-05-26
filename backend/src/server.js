import dotenv from "dotenv";
import app from "./app.js";

dotenv.config();

const port = Number(process.env.PORT) || 3000;

app.listen(port, () => {
  console.log(`TechFix API listening on port ${port}`);
});
