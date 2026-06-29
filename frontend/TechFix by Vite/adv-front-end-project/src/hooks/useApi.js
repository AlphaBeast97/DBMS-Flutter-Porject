// Hook — returns a memoized Axios instance wired to the current user's auth credentials
import { useMemo } from "react";
import { useAuth } from "@/hooks/useAuth";
import { createApiClient } from "@/config/api";

export function useApi() {
  const { baseUrl, email, password, logout } = useAuth();

  return useMemo(
    () =>
      createApiClient(baseUrl, email, password, () => {
        logout();
        window.location.href = "/login";
      }),
    [baseUrl, email, password, logout]
  );
}
