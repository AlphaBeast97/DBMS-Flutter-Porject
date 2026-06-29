// Log part form — part name + optional cost; wrapped in Sheet; calls POST /api/inventory-usage
import { useState } from "react";
import toast from "react-hot-toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Loader2 } from "lucide-react";

export function LogPartForm({ api, job, onSaved, onCancel }) {
  const [partName, setPartName] = useState("");
  const [partCost, setPartCost] = useState("");
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const validate = () => {
    const e = {};
    if (!partName.trim()) e.partName = "Part name is required";
    if (partCost && isNaN(Number(partCost))) e.partCost = "Cost must be a number";
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
      await api.post("/api/inventory-usage", {
        job_id: job.job_id,
        part_name: partName.trim(),
        part_cost: partCost ? Number(partCost) : undefined,
      });
      toast.dismiss();
      toast.success("Part logged!");
      onSaved();
    } catch (err) {
      toast.dismiss();
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <p className="text-sm text-muted-foreground">
        Logging part for job <span className="font-medium text-foreground">#{job.job_id}</span>
      </p>
      <div className="space-y-2">
        <Label htmlFor="partName">Part Name</Label>
        <Input
          id="partName"
          placeholder="Screen replacement kit"
          value={partName}
          onChange={(e) => setPartName(e.target.value)}
          aria-invalid={!!errors.partName}
        />
        {errors.partName && <p className="text-xs text-destructive">{errors.partName}</p>}
      </div>
      <div className="space-y-2">
        <Label htmlFor="partCost">Part Cost ($) (optional)</Label>
        <Input
          id="partCost"
          type="number"
          step="0.01"
          min="0"
          placeholder="49.99"
          value={partCost}
          onChange={(e) => setPartCost(e.target.value)}
          aria-invalid={!!errors.partCost}
        />
        {errors.partCost && <p className="text-xs text-destructive">{errors.partCost}</p>}
      </div>
      <div className="flex justify-end gap-2">
        <Button type="button" variant="outline" onClick={onCancel}>
          Cancel
        </Button>
        <Button type="submit" disabled={loading}>
          {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
          Log Part
        </Button>
      </div>
    </form>
  );
}
