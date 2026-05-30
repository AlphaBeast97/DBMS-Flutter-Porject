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
  const [resultSets] = await pool.query(sql, params);

  if (Array.isArray(resultSets)) {
    const rows = resultSets.filter((set) => Array.isArray(set));
    return rows.length > 0 ? rows[rows.length - 1] : [];
  }

  return resultSets || [];
}

function normalizeResultSets(resultSets) {
  if (!Array.isArray(resultSets)) {
    return [];
  }

  return resultSets.filter((set) => Array.isArray(set));
}

export async function callProcedureMulti(name, params = []) {
  const placeholders = buildPlaceholders(params.length);
  const sql = `CALL ${name}(${placeholders})`;
  const [resultSets] = await pool.query(sql, params);

  return normalizeResultSets(resultSets);
}
