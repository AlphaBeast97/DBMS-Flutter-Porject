// Auth state provider — manages login/logout, localStorage persistence, role-based access, credentials for API client
import { createContext, useState, useEffect, useCallback, useMemo } from "react";
import { loginEmployee, loginCustomer } from "@/services/authService";

export const AuthContext = createContext(null);

const DEFAULT_BASE_URL = "http://localhost:3000";
const STORAGE_KEY = "techfix_auth";

function loadStored() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function saveStored(data) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  } catch {
  }
}

function clearStored() {
  try {
    localStorage.removeItem(STORAGE_KEY);
  } catch {
  }
}

export function AuthProvider({ children }) {
  const stored = useMemo(() => loadStored(), []);

  const [user, setUser] = useState(stored?.user || null);
  const [baseUrl, setBaseUrl] = useState(stored?.baseUrl || DEFAULT_BASE_URL);
  const [email, setEmail] = useState(stored?.email || "");
  const [password, setPassword] = useState(stored?.password || "");
  const [initialized, setInitialized] = useState(false);

  useEffect(() => {
    setInitialized(true);
  }, []);

  const persist = useCallback((u, b, e, p) => {
    saveStored({ user: u, baseUrl: b, email: e, password: p });
  }, []);

  const isAuthenticated = !!user;
  const role = user?.role || null;

  const login = useCallback(async (loginEmail, loginPassword, loginRole) => {
    if (loginRole === "Customer") {
      const result = await loginCustomer(DEFAULT_BASE_URL, loginEmail);
      const u = { ...result, role: "Customer" };
      setBaseUrl(DEFAULT_BASE_URL);
      setEmail(loginEmail);
      setPassword("");
      setUser(u);
      persist(u, DEFAULT_BASE_URL, loginEmail, "");
    } else {
      const result = await loginEmployee(DEFAULT_BASE_URL, loginEmail, loginPassword);
      if (loginRole === "Owner" && result.role !== "Owner") {
        throw new Error("This account is not an Owner account");
      }
      const u = {
        id: result.employee_id,
        organizationId: result.organization_id,
        name: result.name,
        email: result.email,
        role: result.role,
      };
      setBaseUrl(DEFAULT_BASE_URL);
      setEmail(loginEmail);
      setPassword(loginPassword);
      setUser(u);
      persist(u, DEFAULT_BASE_URL, loginEmail, loginPassword);
    }
  }, [persist]);

  const logout = useCallback(() => {
    setUser(null);
    setEmail("");
    setPassword("");
    clearStored();
  }, []);

  const value = useMemo(
    () => ({ user, baseUrl, email, password, isAuthenticated, role, login, logout, initialized }),
    [user, baseUrl, email, password, isAuthenticated, role, login, logout, initialized]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
