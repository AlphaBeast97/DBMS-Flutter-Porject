// My repairs page — customer self-service portal: profile, devices, repair jobs, cancel pending, parts used
import { useState, useEffect, useCallback } from "react";
import toast from "react-hot-toast";
import { useApi } from "@/hooks/useApi";
import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { AlertDialog, AlertDialogContent, AlertDialogHeader, AlertDialogTitle, AlertDialogDescription, AlertDialogFooter, AlertDialogCancel, AlertDialogAction } from "@/components/ui/alert-dialog";
import { StatusBadge } from "@/components/shared/StatusBadge";
import { StatCard } from "@/components/shared/StatCard";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import { EmptyState } from "@/components/shared/EmptyState";
import { fmtMoney } from "@/lib/utils";
import { Phone, Mail, Wrench, ClipboardList, Smartphone, XCircle, Package } from "lucide-react";

export function MyRepairsPage() {
  const api = useApi();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [cancelJobId, setCancelJobId] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await api.get("/api/customers/me");
      setData(res.data.data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [api]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleCancel = async () => {
    if (!cancelJobId) return;
    try {
      await api.post(`/api/repair-jobs/${cancelJobId}/cancel`);
      toast.dismiss();
      toast.success("Job cancelled.");
      setCancelJobId(null);
      fetchData();
    } catch (err) {
      toast.dismiss();
      toast.error(err.message);
    }
  };

  if (loading) return <LoadingState count={3} />;
  if (error) return <ErrorState message={error} onRetry={fetchData} />;
  if (!data) return null;

  const { customer, devices, repair_jobs, inventory_usage } = data;
  const initials = customer.name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);

  const activeCount = repair_jobs.filter((j) => j.status === "Pending" || j.status === "Repairing").length;
  const readyCount = repair_jobs.filter((j) => j.status === "Ready").length;

  const canCancel = (job) => job.status === "Pending";

  return (
    <div className="space-y-6">
      <Card>
        <CardContent className="flex items-center gap-4 p-6">
          <Avatar className="h-16 w-16">
            <AvatarFallback className="bg-coral text-lg text-primary-foreground">
              {initials}
            </AvatarFallback>
          </Avatar>
          <div>
            <h1 className="text-2xl font-bold text-foreground">{customer.name}</h1>
            <div className="mt-1 flex flex-wrap gap-4 text-sm text-muted-foreground">
              <span className="flex items-center gap-1">
                <Mail className="h-3 w-3" />
                {customer.email || "No email"}
              </span>
              <span className="flex items-center gap-1">
                <Phone className="h-3 w-3" />
                {customer.phone}
              </span>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-4 sm:grid-cols-2">
        <StatCard icon={Wrench} value={activeCount} label="Active Repairs" />
        <StatCard icon={ClipboardList} value={readyCount} label="Ready for Pickup" />
      </div>

      {devices.length > 0 && (
        <div>
          <h2 className="mb-3 text-lg font-semibold text-foreground">My Devices</h2>
          <div className="grid gap-3 sm:grid-cols-2">
            {devices.map((d) => (
              <Card key={d.device_id}>
                <CardContent className="p-4">
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
                      <Smartphone className="h-5 w-5 text-primary" />
                    </div>
                    <div>
                      <p className="font-medium text-foreground">{d.brand} {d.model}</p>
                      <p className="text-xs text-muted-foreground">
                        {d.type} &middot; {d.serial_number || "No S/N"}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      )}

      {repair_jobs.length > 0 ? (
        <div>
          <h2 className="mb-3 text-lg font-semibold text-foreground">Repair Jobs</h2>
          <div className="space-y-2">
            {repair_jobs.map((j) => (
              <Card key={j.job_id}>
                <CardContent className="p-4">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-medium text-foreground">#{j.job_id}</span>
                        <StatusBadge status={j.status} />
                      </div>
                      <p className="mt-1 text-sm text-muted-foreground">{j.description}</p>
                      <div className="mt-2 flex items-center gap-4 text-sm">
                        <span className="text-muted-foreground">
                          Est: {fmtMoney(j.estimated_cost)}
                        </span>
                        {j.final_cost != null && (
                          <span className="font-medium text-teal">
                            Final: {fmtMoney(j.final_cost)}
                          </span>
                        )}
                      </div>
                    </div>
                    {canCancel(j) && (
                      <Button
                        size="sm"
                        variant="outline"
                        className="text-destructive border-destructive/30 hover:bg-destructive/10"
                        onClick={() => setCancelJobId(j.job_id)}
                      >
                        <XCircle className="mr-1 h-4 w-4" />
                        Cancel
                      </Button>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      ) : (
        <EmptyState
          icon={Wrench}
          title="No repair jobs"
          description="You don't have any repair jobs yet."
        />
      )}

      {inventory_usage?.length > 0 && (
        <div>
          <h2 className="mb-3 text-lg font-semibold text-foreground">Parts Used</h2>
          <Card>
            <CardContent className="p-4">
              <div className="divide-y divide-border">
                {inventory_usage.map((u) => (
                  <div key={u.usage_id} className="flex items-center justify-between py-2 text-sm">
                    <div className="flex items-center gap-2">
                      <Package className="h-4 w-4 text-muted-foreground" />
                      <span className="text-foreground">{u.part_name}</span>
                    </div>
                    <div className="text-right text-muted-foreground">
                      <p>{fmtMoney(u.part_cost)}</p>
                      <p className="text-xs">{u.employee_name}</p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      <AlertDialog open={!!cancelJobId} onOpenChange={(o) => !o && setCancelJobId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Cancel Repair Job?</AlertDialogTitle>
            <AlertDialogDescription>
              This action cannot be undone. The job will be marked as cancelled.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Keep Job</AlertDialogCancel>
            <AlertDialogAction onClick={handleCancel} className="bg-destructive hover:bg-destructive/90">
              Yes, Cancel
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
