// Route guard — checks isAuthenticated and allowedRoles; redirects to /login or shows Access Denied
import { Navigate } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";

export function ProtectedRoute({ children, allowedRoles }) {
  const { isAuthenticated, role } = useAuth();

  if (!isAuthenticated) return <Navigate to="/login" replace />;

  if (allowedRoles && !allowedRoles.includes(role)) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-cream">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-ink">Access Denied</h1>
          <p className="mt-2 text-grey">You do not have permission to view this page.</p>
        </div>
      </div>
    );
  }

  return children;
}
