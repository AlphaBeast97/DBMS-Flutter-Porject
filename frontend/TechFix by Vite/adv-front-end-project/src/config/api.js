// Axios instance factory — injects Basic Auth header from credentials, handles 401 auto-redirect
import axios from "axios";
import { base64 } from "@/lib/utils";

const DEFAULT_BASE_URL = "http://localhost:3000";

export function createApiClient(baseUrl, email, password, onUnauthorized) {
  const client = axios.create({
    baseURL: baseUrl || DEFAULT_BASE_URL,
    headers: { "Content-Type": "application/json" },
  });

  client.interceptors.request.use((config) => {
    const encoded = base64(`${email}:${password || ""}`);
    config.headers.Authorization = `Basic ${encoded}`;
    return config;
  });

  client.interceptors.response.use(
    (res) => res,
    (error) => {
      if (error.response) {
        if (error.response.status === 401 && onUnauthorized) {
          onUnauthorized();
        }
        const msg = error.response.data?.error || "Something went wrong";
        const e = new Error(msg);
        e.status = error.response.status;
        throw e;
      }
      throw new Error("Network error — is the server running?");
    }
  );

  return client;
}
