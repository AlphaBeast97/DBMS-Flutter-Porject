// Create job form — step 3 of 3-step wizard; description, estimated cost, optional status fields
import { useState } from "react";
import toast from "react-hot-toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2 } from "lucide-react";
import { STATUS_VALUES } from "@/lib/constants";

export function CreateJobForm({ api, deviceId, onCompleted, onBack }) {
  const [description, setDescription] = useState("");
  const [estimatedCost, setEstimatedCost] = useState("");
  const [status, setStatus] = useState("Pending");
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const validate = () => {
    const e = {};
    if (!description.trim()) e.description = "Description is required";
    if (estimatedCost && isNaN(Number(estimatedCost))) e.estimatedCost = "Cost must be a number";
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
      const body = {
        device_id: deviceId,
        description: description.trim(),
        status,
      };
      if (estimatedCost) body.estimated_cost = Number(estimatedCost);
      const result = await api.post("/api/repair-jobs", body);
      toast.dismiss();
      toast.success("Repair job created!");
      onCompleted(result.data.data);
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
        <Label htmlFor="jobDesc">Description</Label>
        <Textarea
          id="jobDesc"
          placeholder="Describe the issue..."
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          aria-invalid={!!errors.description}
        />
        {errors.description && <p className="text-xs text-destructive">{errors.description}</p>}
      </div>
      <div className="space-y-2">
        <Label htmlFor="jobCost">Estimated Cost ($)</Label>
        <Input
          id="jobCost"
          type="number"
          step="0.01"
          min="0"
          placeholder="99.99"
          value={estimatedCost}
          onChange={(e) => setEstimatedCost(e.target.value)}
          aria-invalid={!!errors.estimatedCost}
        />
        {errors.estimatedCost && <p className="text-xs text-destructive">{errors.estimatedCost}</p>}
      </div>
      <div className="space-y-2">
        <Label htmlFor="jobStatus">Status</Label>
        <Select value={status} onValueChange={setStatus}>
          <SelectTrigger id="jobStatus">
            <SelectValue placeholder="Select status" />
          </SelectTrigger>
          <SelectContent>
            {STATUS_VALUES.filter((s) => s !== "Delivered" && s !== "Cancelled").map((s) => (
              <SelectItem key={s} value={s}>{s}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>
      <div className="flex gap-2">
        <Button type="button" variant="outline" onClick={onBack}>
          Back
        </Button>
        <Button type="submit" disabled={loading}>
          {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
          Create Job
        </Button>
      </div>
    </form>
  );
}
