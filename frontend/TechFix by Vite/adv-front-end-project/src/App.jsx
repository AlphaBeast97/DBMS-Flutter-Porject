// Root component — BrowserRouter, AuthProvider, route definitions (login, technician, dashboard, my-repairs)
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { Toaster } from "react-hot-toast";
import { AuthProvider } from "@/context/AuthContext";
import { useAuth } from "@/hooks/useAuth";
import { ErrorBoundary } from "@/components/shared/ErrorBoundary";
import { ProtectedRoute } from "@/components/layout/ProtectedRoute";
import { AppLayout } from "@/components/layout/AppLayout";
import { LoginPage } from "@/pages/LoginPage";
import { TechnicianPage } from "@/pages/TechnicianPage";
import { ManagerPage } from "@/pages/ManagerPage";
import { MyRepairsPage } from "@/pages/MyRepairsPage";

const toasterOptions = {
  position: "top-right",
  limit: 2,
  toastOptions: {
    style: {
      fontFamily: "Space Grotesk, sans-serif",
      borderRadius: "0.75rem",
      padding: "12px 16px",
    },
    success: { style: { background: "#2A9D8F", color: "#F7F3ED" } },
    error: { style: { background: "#e05a3a", color: "#F7F3ED" } },
  },
};

function HomeRedirect() {
  const { role } = useAuth();
  const map = { Owner: "/dashboard", Employee: "/technician", Customer: "/my-repairs" };
  return <Navigate to={map[role] || "/login"} replace />;
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <ErrorBoundary>
          <Toaster {...toasterOptions} />
          <Routes>
            <Route path="/login" element={<LoginPage />} />

            <Route
              element={
                <ProtectedRoute allowedRoles={["Owner", "Employee", "Customer"]}>
                  <AppLayout />
                </ProtectedRoute>
              }
            >
              <Route index element={<HomeRedirect />} />
              <Route
                path="/technician"
                element={
                  <ProtectedRoute allowedRoles={["Employee"]}>
                    <TechnicianPage />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/dashboard"
                element={
                  <ProtectedRoute allowedRoles={["Owner"]}>
                    <ManagerPage />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/my-repairs"
                element={
                  <ProtectedRoute allowedRoles={["Customer"]}>
                    <MyRepairsPage />
                  </ProtectedRoute>
                }
              />
            </Route>

            <Route path="*" element={<LoginPage />} />
          </Routes>
        </ErrorBoundary>
      </AuthProvider>
    </BrowserRouter>
  );
}
