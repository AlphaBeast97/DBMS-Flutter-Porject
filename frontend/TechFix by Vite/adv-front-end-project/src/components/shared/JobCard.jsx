// Repair job card — displays device info, status badge, costs, collapsible parts used; actions via callbacks
import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { StatusBadge } from "@/components/shared/StatusBadge";
import { fmtMoney } from "@/lib/utils";
import { ChevronDown, ChevronUp, Laptop, Smartphone, Gamepad2, Tablet, Package } from "lucide-react";

const deviceIcons = {
  Laptop: Laptop,
  Mobile: Smartphone,
  Console: Gamepad2,
  Tablet: Tablet,
  Other: Package,
};

export function JobCard({
  job,
  actions,
  onEditStatus,
  onEditDesc,
  onLogPart,
}) {
  const [expanded, setExpanded] = useState(false);
  const DeviceIcon = deviceIcons[job.type] || Package;

  return (
    <Card>
      <CardContent className="p-4">
        <div className="flex items-start justify-between">
          <div className="flex items-start gap-3">
            <div className="mt-1 flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
              <DeviceIcon className="h-5 w-5 text-primary" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <p className="font-medium text-foreground">
                  {job.brand} {job.model}
                </p>
                <StatusBadge status={job.status} />
              </div>
              <p className="mt-0.5 text-sm text-muted-foreground">
                {job.customer_name} &middot; #{job.job_id}
              </p>
              <p className="mt-1 text-sm text-foreground line-clamp-1">
                {job.description}
              </p>
              <div className="mt-2 flex items-center gap-4 text-sm">
                <span className="text-muted-foreground">
                  Est: {fmtMoney(job.estimated_cost)}
                </span>
                {job.final_cost != null && (
                  <span className="font-medium text-teal">
                    Final: {fmtMoney(job.final_cost)}
                  </span>
                )}
              </div>
            </div>
          </div>

          {actions && (
            <div className="flex flex-col gap-1">
              {onEditStatus && (
                <Button size="sm" variant="outline" onClick={() => onEditStatus(job)}>
                  Status
                </Button>
              )}
              {onEditDesc && (
                <Button size="sm" variant="ghost" onClick={() => onEditDesc(job)}>
                  Edit
                </Button>
              )}
              {onLogPart && (
                <Button size="sm" variant="ghost" onClick={() => onLogPart(job)}>
                  + Part
                </Button>
              )}
            </div>
          )}
        </div>

        {job.inventory_usage && job.inventory_usage.length > 0 && (
          <>
            <button
              className="mt-3 flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground"
              onClick={() => setExpanded(!expanded)}
            >
              {expanded ? (
                <ChevronUp className="h-3 w-3" />
              ) : (
                <ChevronDown className="h-3 w-3" />
              )}
              {job.inventory_usage.length} part{job.inventory_usage.length > 1 ? "s" : ""} used
            </button>
            {expanded && (
              <div className="mt-2 space-y-1 border-t border-border pt-2">
                {job.inventory_usage.map((part) => (
                  <div
                    key={part.usage_id}
                    className="flex items-center justify-between text-sm"
                  >
                    <span className="text-foreground">{part.part_name}</span>
                    <span className="text-muted-foreground">
                      {fmtMoney(part.part_cost)} &middot; {part.employee_name}
                    </span>
                  </div>
                ))}
              </div>
            )}
          </>
        )}
      </CardContent>
    </Card>
  );
}
