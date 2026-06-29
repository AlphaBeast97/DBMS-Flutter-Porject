// Status badge — wraps shadcn Badge with job status-specific color mapping (Pending=clay, Repairing=sky, etc.)
import { Badge } from "@/components/ui/badge";
import { statusColor, statusBg } from "@/lib/constants";

export function StatusBadge({ status, className }) {
  return (
    <Badge
      className={className}
      style={{
        backgroundColor: statusBg(status),
        color: statusColor(status),
        borderColor: statusColor(status),
      }}
    >
      {status}
    </Badge>
  );
}
