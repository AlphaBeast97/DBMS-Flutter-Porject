import pool from "./pool.js";

function buildPlaceholders(count) {
  if (!count) {
    return "";
  }

  return new Array(count).fill("?").join(", ");
}

export async function callProcedure(name, params = []) {
  const placeholders = buildPlaceholders(params.length);
  const sql = `CALL ${name}(${placeholders})`;
  const [resultSets] = await pool.execute(sql, params);

  if (Array.isArray(resultSets)) {
    return resultSets[0] || [];
  }

  return resultSets || [];
}
