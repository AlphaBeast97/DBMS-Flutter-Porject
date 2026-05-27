import crypto from "crypto";

export function parseBasicAuth(header) {
  if (!header || typeof header !== "string") {
    return null;
  }

  const prefix = "Basic ";
  if (!header.startsWith(prefix)) {
    return null;
  }

  const encoded = header.slice(prefix.length).trim();
  if (!encoded) {
    return null;
  }

  let decoded;
  try {
    decoded = Buffer.from(encoded, "base64").toString("utf8");
  } catch {
    return null;
  }

  const separatorIndex = decoded.indexOf(":");
  if (separatorIndex === -1) {
    return null;
  }

  const username = decoded.slice(0, separatorIndex).trim();
  const password = decoded.slice(separatorIndex + 1);

  if (!username) {
    return null;
  }

  return { username, password };
}

export function hashPassword(password) {
  return crypto.createHash("sha256").update(password).digest("hex");
}
