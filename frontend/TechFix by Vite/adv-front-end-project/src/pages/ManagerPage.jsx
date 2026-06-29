// Manager dashboard — donut chart, revenue card, paginated job list; Owner-only analytics view
import { useState, useEffect, useCallback, useMemo } from "react";
import { useAuth } from "@/hooks/useAuth";
import { useApi } from "@/hooks/useApi";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from "recharts";
import { JobCard } from "@/components/shared/JobCard";
import { RevenueCard } from "@/components/shared/RevenueCard";
import { StatCard } from "@/components/shared/StatCard";
import { LoadingState } from "@/components/shared/LoadingState";
import { EmptyState } from "@/components/shared/EmptyState";
import { ErrorState } from "@/components/shared/ErrorState";
import { STATUS_COLORS, STATUS_LABELS } from "@/lib/constants";
import { fmtMoney } from "@/lib/utils";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { AddStaffForm } from "@/components/forms/AddStaffForm";
import { Wrench, DollarSign, BarChart3, Plus } from "lucide-react";

const PAGE_SIZE = 10;

export function ManagerPage() {
  const { user } = useAuth();
  const api = useApi();
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [displayCount, setDisplayCount] = useState(PAGE_SIZE);
  const [dialogOpen, setDialogOpen] = useState(false);
  const fetchJobs = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = {};
      if (user?.organizationId) params.organization_id = user.organizationId;
      const res = await api.get("/api/repair-jobs", { params });
      const jobs = res.data.data || [];

      const customerIds = [...new Set(jobs.map((j) => j.customer_id).filter(Boolean))];
      const usageMap = {};
      for (const cid of customerIds) {
        try {
          const detailRes = await api.get(`/api/customers/${cid}`);
          const list = detailRes.data.data?.inventory_usage || [];
          for (const u of list) {
            if (!usageMap[u.job_id]) usageMap[u.job_id] = [];
            usageMap[u.job_id].push(u);
          }
        } catch {}
      }

      setJobs(jobs.map((j) => ({ ...j, inventory_usage: usageMap[j.job_id] || [] })));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [api, user?.organizationId]);

  useEffect(() => {
    fetchJobs();
  }, [fetchJobs]);

  const stats = useMemo(() => {
    const statusCounts = {};
    let estTotal = 0;
    let finTotal = 0;
    jobs.forEach((j) => {
      statusCounts[j.status] = (statusCounts[j.status] || 0) + 1;
      estTotal += Number(j.estimated_cost) || 0;
      if (j.status === "Delivered") finTotal += Number(j.final_cost) || 0;
    });
    const pieData = Object.entries(statusCounts).map(([name, value]) => ({
      name: STATUS_LABELS[name] || name,
      value,
      color: STATUS_COLORS[name] || "#9A958C",
    }));
    return { statusCounts, estTotal, finTotal, pieData, total: jobs.length };
  }, [jobs]);

  const visibleJobs = useMemo(
    () => jobs.slice(0, displayCount),
    [jobs, displayCount]
  );

  const activeCount = (stats.statusCounts["Pending"] || 0) + (stats.statusCounts["Repairing"] || 0);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-foreground">Dashboard</h1>
        <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="mr-1 h-4 w-4" />
              Add Staff
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Add Staff Member</DialogTitle>
            </DialogHeader>
            <AddStaffForm
              api={api}
              onSaved={() => { setDialogOpen(false); }}
              onCancel={() => setDialogOpen(false)}
            />
          </DialogContent>
        </Dialog>
      </div>

      {loading ? (
        <LoadingState count={3} />
      ) : error ? (
        <ErrorState message={error} onRetry={fetchJobs} />
      ) : (
        <>
          <div className="grid gap-4 sm:grid-cols-3">
            <StatCard icon={Wrench} value={stats.total} label="Total Jobs" />
            <StatCard icon={BarChart3} value={activeCount} label="Active Jobs" />
            <StatCard icon={DollarSign} value={fmtMoney(stats.estTotal)} label="Estimated Revenue" />
          </div>

          <div className="grid gap-6 lg:grid-cols-2">
            <RevenueCard estimated={stats.estTotal} finalized={stats.finTotal} />

            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="flex items-center gap-2 text-base">
                  <BarChart3 className="h-4 w-4 text-coral" />
                  Job Status Distribution
                </CardTitle>
              </CardHeader>
              <CardContent>
                {stats.pieData.length > 0 ? (
                  <div className="flex items-center justify-center">
                    <ResponsiveContainer width="100%" height={200}>
                      <PieChart>
                        <Pie
                          data={stats.pieData}
                          cx="50%"
                          cy="50%"
                          innerRadius={50}
                          outerRadius={80}
                          paddingAngle={2}
                          dataKey="value"
                        >
                          {stats.pieData.map((entry, i) => (
                            <Cell key={i} fill={entry.color} />
                          ))}
                        </Pie>
                        <Tooltip />
                      </PieChart>
                    </ResponsiveContainer>
                    <div className="space-y-2 text-sm">
                      {stats.pieData.map((entry) => (
                        <div key={entry.name} className="flex items-center gap-2">
                          <div
                            className="h-3 w-3 rounded-sm"
                            style={{ backgroundColor: entry.color }}
                          />
                          <span className="text-muted-foreground">{entry.name}</span>
                          <span className="font-medium text-foreground">{entry.value}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                ) : (
                  <p className="py-8 text-center text-sm text-muted-foreground">No job data yet.</p>
                )}
              </CardContent>
            </Card>
          </div>

          <div>
            <h2 className="mb-3 text-lg font-semibold text-foreground">Recent Jobs</h2>
            {visibleJobs.length > 0 ? (
              <div className="space-y-3">
                {visibleJobs.map((job) => (
                  <JobCard key={job.job_id} job={job} />
                ))}
              </div>
            ) : (
              <EmptyState icon={Wrench} title="No jobs yet" description="Jobs will appear here once technicians create them." />
            )}
            {displayCount < jobs.length && (
              <div className="mt-4 text-center">
                <Button variant="outline" onClick={() => setDisplayCount((c) => c + PAGE_SIZE)}>
                  Show more ({jobs.length - displayCount} remaining)
                </Button>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}
