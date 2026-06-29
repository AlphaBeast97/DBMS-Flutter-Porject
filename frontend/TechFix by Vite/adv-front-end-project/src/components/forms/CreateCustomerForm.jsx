// Create customer form — step 1 of 3-step wizard; checks existing email via /api/auth/customer before creating
import { useState } from "react";
import toast from "react-hot-toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Loader2 } from "lucide-react";
import { base64, emailRegex } from "@/lib/utils";

export function CreateCustomerForm({ api, baseUrl, onCreated, onBack }) {
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const validate = () => {
    const e = {};
    if (!name.trim()) e.name = "Customer name is required";
    if (!phone.trim()) e.phone = "Phone is required";
    if (!email.trim()) e.email = "Email is required";
    else if (!emailRegex.test(email.trim())) e.email = "Invalid email format";
    return e;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const validationErrors = validate();
    setErrors(validationErrors);
    if (Object.keys(validationErrors).length > 0) {
      toast.dismiss();
      toast.error(Object.values(validationErrors)[0]);
      return;
    }

    setLoading(true);
    try {
      const encoded = base64(`${email.trim()}:`);
      const res = await fetch(`${baseUrl || ""}/api/auth/customer`, {
        method: "POST",
        headers: {
          Authorization: `Basic ${encoded}`,
          "Content-Type": "application/json",
        },
      });
      if (res.ok) {
        const body = await res.json();
        toast.dismiss();
        toast.success("Customer found — linking to existing account.");
        onCreated(body.data);
        return;
      }
    } catch {
    }

    try {
      const result = await api.post("/api/customers", {
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim() || undefined,
      });
      toast.dismiss();
      toast.success("Customer created!");
      onCreated(result.data.data);
    } catch (err) {
      toast.dismiss();
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="custName">Customer Name</Label>
        <Input
          id="custName"
          placeholder="Jane Doe"
          value={name}
          onChange={(e) => setName(e.target.value)}
          aria-invalid={!!errors.name}
        />
        {errors.name && <p className="text-xs text-destructive">{errors.name}</p>}
      </div>
      <div className="space-y-2">
        <Label htmlFor="custPhone">Phone</Label>
        <Input
          id="custPhone"
          placeholder="+1234567890"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
          aria-invalid={!!errors.phone}
        />
        {errors.phone && <p className="text-xs text-destructive">{errors.phone}</p>}
      </div>
      <div className="space-y-2">
        <Label htmlFor="custEmail">Email</Label>
        <Input
          id="custEmail"
          type="email"
          placeholder="jane@example.com"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          aria-invalid={!!errors.email}
        />
        {errors.email && <p className="text-xs text-destructive">{errors.email}</p>}
      </div>
      <div className="flex gap-2">
        <Button type="button" variant="outline" onClick={onBack}>
          Back
        </Button>
        <Button type="submit" disabled={loading}>
          {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
          Create & Continue
        </Button>
      </div>
    </form>
  );
}
