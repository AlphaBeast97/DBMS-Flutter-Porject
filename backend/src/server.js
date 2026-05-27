import dotenv from "dotenv";

dotenv.config();

const port = Number(process.env.PORT) || 3000;
const { default: app } = await import("./app.js");

app.listen(port, () => {
  console.log(`TechFix API listening on port ${port}`);
});
