// Login page — 3 auth modes (Owner/Employee/Customer) with tab switching, sign in/sign up for Owner
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import { useAuth } from "@/hooks/useAuth";
import { createOwner } from "@/services/authService";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { LoginForm } from "@/components/forms/LoginForm";
import { OwnerSignUpForm } from "@/components/forms/OwnerSignUpForm";
import { Wrench } from "lucide-react";

export function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [role, setRole] = useState("Owner");
  const [ownerTab, setOwnerTab] = useState("sign-in");

  const handleLogin = async (email, password, loginRole) => {
    try {
      await login(email, password, loginRole);
      const redirectMap = {
        Owner: "/dashboard",
        Employee: "/technician",
        Customer: "/my-repairs",
      };
      navigate(redirectMap[loginRole] || "/technician");
      toast.dismiss();
      toast.success("Welcome back!");
    } catch (err) {
      toast.dismiss();
      toast.error("Sign in failed. Please check your credentials.");
    }
  };

  const handleSignUp = async (payload) => {
    try {
      await createOwner("http://localhost:3000", payload);
      await login(payload.ownerEmail, payload.password, "Owner");
      navigate("/dashboard");
      toast.dismiss();
      toast.success("Organization created!");
    } catch (err) {
      toast.dismiss();
      toast.error("Could not create organization. Please try again.");
    }
  };

  return (
    <div className="relative flex min-h-screen items-center justify-center bg-background overflow-hidden">
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_left,_var(--color-coral)_0%,_transparent_40%),radial-gradient(ellipse_at_bottom_right,_var(--color-teal)_0%,_transparent_40%)] opacity-20" />

      <div className="relative w-full max-w-md px-4">
        <div className="mb-8 text-center">
          <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-coral shadow-lg">
            <Wrench className="h-7 w-7 text-primary-foreground" />
          </div>
          <h1 className="text-3xl font-bold text-foreground">TechFix</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Digital Repair Workflow Manager
          </p>
        </div>

        <div className="rounded-2xl border border-border bg-card p-6 shadow-lg">
          <Tabs value={role} onValueChange={setRole}>
            <TabsList className="mb-6 grid w-full grid-cols-3">
              <TabsTrigger value="Owner">Owner</TabsTrigger>
              <TabsTrigger value="Employee">Employee</TabsTrigger>
              <TabsTrigger value="Customer">Customer</TabsTrigger>
            </TabsList>

            <TabsContent value="Owner">
              <Tabs value={ownerTab} onValueChange={setOwnerTab}>
                <TabsList className="mb-4 grid w-full grid-cols-2">
                  <TabsTrigger value="sign-in">Sign In</TabsTrigger>
                  <TabsTrigger value="sign-up">Sign Up</TabsTrigger>
                </TabsList>

                <TabsContent value="sign-in">
                  <LoginForm role="Owner" onSubmit={handleLogin} />
                </TabsContent>

                <TabsContent value="sign-up">
                  <OwnerSignUpForm onSubmit={handleSignUp} />
                </TabsContent>
              </Tabs>
            </TabsContent>

            <TabsContent value="Employee">
              <LoginForm role="Employee" onSubmit={handleLogin} />
            </TabsContent>

            <TabsContent value="Customer">
              <LoginForm role="Customer" onSubmit={handleLogin} />
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </div>
  );
}
