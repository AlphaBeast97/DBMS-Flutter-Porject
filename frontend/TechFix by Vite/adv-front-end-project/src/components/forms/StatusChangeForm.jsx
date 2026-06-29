// Status change form — radio group of valid next statuses; wrapped in Dialog on TechnicianPage
import { useState } from "react";
import toast from "react-hot-toast";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Loader2 } from "lucide-react";
import { getValidTransitions, statusColor } from "@/lib/constants";

export function StatusChangeForm({ api, job, role, onSaved, onCancel }) {
  const transitions = getValidTransitions(job.status, role);
  const [selected, setSelected] = useState(transitions[0] || "");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!selected) return;

    setLoading(true);
    try {
      await api.put(`/api/repair-jobs/${job.job_id}`, { status: selected });
      toast.dismiss();
      toast.success(`Status updated to ${selected}`);
      onSaved();
    } catch (err) {
      toast.dismiss();
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (transitions.length === 0) {
    return (
      <div className="py-4 text-center text-sm text-muted-foreground">
        No valid status transitions from "{job.status}".
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <p className="text-sm text-muted-foreground">
        Current status: <span className="font-medium text-foreground">{job.status}</span>
      </p>
      <RadioGroup value={selected} onValueChange={setSelected}>
        {transitions.map((t) => (
          <div key={t} className="flex items-center gap-3 rounded-lg border border-border p-3">
            <RadioGroupItem value={t} id={`status-${t}`} />
            <Label htmlFor={`status-${t}`} className="flex-1 font-medium" style={{ color: statusColor(t) }}>
              {t}
            </Label>
          </div>
        ))}
      </RadioGroup>
      <div className="flex justify-end gap-2">
        <Button type="button" variant="outline" onClick={onCancel}>
          Cancel
        </Button>
        <Button type="submit" disabled={loading}>
          {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
          Update Status
        </Button>
      </div>
    </form>
  );
}
