// Owner sign-up form — org name, owner name, email, password; calls POST /api/employees/owner
import { useState } from "react";
import toast from "react-hot-toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { emailRegex, minPasswordLength } from "@/lib/utils";
import { Loader2 } from "lucide-react";

export function OwnerSignUpForm({ onSubmit }) {
  const [orgName, setOrgName] = useState("");
  const [ownerName, setOwnerName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const validate = () => {
    const e = {};
    if (!orgName.trim()) e.orgName = "Organization name is required";
    if (!ownerName.trim()) e.ownerName = "Owner name is required";
    if (!email.trim()) e.email = "Email is required";
    else if (!emailRegex.test(email.trim())) e.email = "Invalid email format";
    if (!password) e.password = "Password is required";
    else if (password.length < minPasswordLength) e.password = `Minimum ${minPasswordLength} characters`;
    return e;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const validationErrors = validate();
    setErrors(validationErrors);
    if (Object.keys(validationErrors).length > 0) {
      const firstError = Object.values(validationErrors)[0];
      toast.dismiss();
      toast.error(firstError);
      return;
    }

    setLoading(true);
    try {
      await onSubmit({
        organizationName: orgName.trim(),
        ownerName: ownerName.trim(),
        ownerEmail: email.trim(),
        password,
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="orgName">Organization Name</Label>
        <Input
          id="orgName"
          placeholder="My Repair Shop"
          value={orgName}
          onChange={(e) => setOrgName(e.target.value)}
          aria-invalid={!!errors.orgName}
        />
        {errors.orgName && <p className="text-xs text-destructive">{errors.orgName}</p>}
      </div>

      <div className="space-y-2">
        <Label htmlFor="ownerName">Your Name</Label>
        <Input
          id="ownerName"
          placeholder="John Smith"
          value={ownerName}
          onChange={(e) => setOwnerName(e.target.value)}
          aria-invalid={!!errors.ownerName}
        />
        {errors.ownerName && <p className="text-xs text-destructive">{errors.ownerName}</p>}
      </div>

      <div className="space-y-2">
        <Label htmlFor="signupEmail">Email</Label>
        <Input
          id="signupEmail"
          type="email"
          placeholder="owner@example.com"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          aria-invalid={!!errors.email}
        />
        {errors.email && <p className="text-xs text-destructive">{errors.email}</p>}
      </div>

      <div className="space-y-2">
        <Label htmlFor="signupPassword">Password</Label>
        <Input
          id="signupPassword"
          type="password"
          placeholder="Create a password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          aria-invalid={!!errors.password}
        />
        {errors.password && <p className="text-xs text-destructive">{errors.password}</p>}
      </div>

      <Button type="submit" className="w-full" disabled={loading}>
        {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
        Create Organization
      </Button>
    </form>
  );
}
