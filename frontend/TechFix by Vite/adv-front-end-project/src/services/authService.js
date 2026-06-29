// Auth API calls — loginEmployee, loginCustomer, createOwner; used by LoginPage for authentication flows
import { createApiClient } from "@/config/api";

export async function loginEmployee(baseUrl, email, password) {
  const api = createApiClient(baseUrl, email, password);
  const { data } = await api.post("/api/auth/employee");
  return data.data;
}

export async function loginCustomer(baseUrl, email) {
  const api = createApiClient(baseUrl, email, "");
  const { data } = await api.post("/api/auth/customer");
  return data.data;
}

export async function createOwner(baseUrl, payload) {
  const api = createApiClient(baseUrl, "", "");
  const { data } = await api.post("/api/employees/owner", {
    organization_name: payload.organizationName,
    owner_name: payload.ownerName,
    owner_email: payload.ownerEmail,
    password: payload.password,
  });
  return data.data;
}
