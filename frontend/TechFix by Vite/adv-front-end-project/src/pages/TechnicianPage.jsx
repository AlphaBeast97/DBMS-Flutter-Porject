// Technician page — job list with search/filter, 3-step create wizard, status/desc/part dialogs/sheets
import { useState, useEffect, useCallback, useMemo } from "react";
import toast from "react-hot-toast";
import { useAuth } from "@/hooks/useAuth";
import { useApi } from "@/hooks/useApi";
import { Input } from "@/components/ui/input";
import { Toggle } from "@/components/ui/toggle";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Sheet, SheetContent, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { JobCard } from "@/components/shared/JobCard";
import { LoadingState } from "@/components/shared/LoadingState";
import { EmptyState } from "@/components/shared/EmptyState";
import { ErrorState } from "@/components/shared/ErrorState";
import { CreateCustomerForm } from "@/components/forms/CreateCustomerForm";
import { CreateDeviceForm } from "@/components/forms/CreateDeviceForm";
import { CreateJobForm } from "@/components/forms/CreateJobForm";
import { StatusChangeForm } from "@/components/forms/StatusChangeForm";
import { EditJobForm } from "@/components/forms/EditJobForm";
import { LogPartForm } from "@/components/forms/LogPartForm";
import { Search, Plus, Wrench } from "lucide-react";

const FILTERS = [null, "Pending", "Repairing", "Ready"];

export function TechnicianPage() {
  const { role, baseUrl } = useAuth();
  const api = useApi();
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState(null);
  const [dialogType, setDialogType] = useState(null);
  const [dialogJob, setDialogJob] = useState(null);

  const [wizardStep, setWizardStep] = useState(0);
  const [wizardCustomerId, setWizardCustomerId] = useState(null);
  const [wizardDeviceId, setWizardDeviceId] = useState(null);

  const fetchJobs = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await api.get("/api/repair-jobs");
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
  }, [api]);

  useEffect(() => {
    fetchJobs();
  }, [fetchJobs]);

  const filteredJobs = useMemo(() => {
    let result = jobs;
    if (statusFilter) {
      result = result.filter((j) => j.status === statusFilter);
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      result = result.filter(
        (j) =>
          j.customer_name?.toLowerCase().includes(q) ||
          j.brand?.toLowerCase().includes(q) ||
          j.model?.toLowerCase().includes(q) ||
          String(j.job_id).includes(q)
      );
    }
    return result;
  }, [jobs, statusFilter, searchQuery]);

  const openDialog = (type, job = null) => {
    setDialogType(type);
    setDialogJob(job);
  };

  const closeDialog = () => {
    setDialogType(null);
    setDialogJob(null);
    setWizardStep(0);
    setWizardCustomerId(null);
    setWizardDeviceId(null);
  };

  const handleSaved = () => {
    closeDialog();
    fetchJobs();
  };

  const handleWizardCustomerCreated = (data) => {
    setWizardCustomerId(data.customer_id);
    setWizardStep(1);
  };

  const handleWizardDeviceCreated = (data) => {
    setWizardDeviceId(data.device_id);
    setWizardStep(2);
  };

  const handleWizardCompleted = () => {
    closeDialog();
    fetchJobs();
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-foreground">Repair Jobs</h1>
        <Button onClick={() => openDialog("create")}>
          <Plus className="mr-2 h-4 w-4" />
          New Job
        </Button>
      </div>

      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="relative max-w-xs">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            type="search"
            placeholder="Search jobs..."
            className="pl-9"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <div className="flex gap-1">
          {FILTERS.map((f) => (
            <Toggle
              key={f || "all"}
              pressed={statusFilter === f}
              onPressedChange={() => setStatusFilter(f)}
              size="sm"
            >
              {f || "All"}
            </Toggle>
          ))}
        </div>
      </div>

      {loading ? (
        <LoadingState count={4} />
      ) : error ? (
        <ErrorState message={error} onRetry={fetchJobs} />
      ) : filteredJobs.length === 0 ? (
        <EmptyState
          icon={Wrench}
          title="No jobs found"
          description={searchQuery || statusFilter ? "Try a different search or filter." : "Create your first repair job to get started."}
          actionLabel={!searchQuery && !statusFilter ? "New Job" : undefined}
          onAction={() => openDialog("create")}
        />
      ) : (
        <div className="space-y-3">
          {filteredJobs.map((job) => (
            <JobCard
              key={job.job_id}
              job={job}
              actions={job.status !== "Cancelled" && job.status !== "Delivered"}
              onEditStatus={(j) => openDialog("status", j)}
              onEditDesc={(j) => openDialog("edit", j)}
              onLogPart={(j) => openDialog("part", j)}
            />
          ))}
        </div>
      )}

      <Sheet open={dialogType === "create"} onOpenChange={(o) => !o && closeDialog()}>
        <SheetContent side="right" className="sm:max-w-lg w-full">
          <SheetHeader>
            <SheetTitle>
              {wizardStep === 0 && "Step 1: Create Customer"}
              {wizardStep === 1 && "Step 2: Add Device"}
              {wizardStep === 2 && "Step 3: Create Job"}
            </SheetTitle>
          </SheetHeader>
          <div className="px-4 pb-6">
            <div className="mb-4 flex gap-1">
              {[0, 1, 2].map((s) => (
                <div
                  key={s}
                  className={`h-1 flex-1 rounded-full ${s <= wizardStep ? "bg-coral" : "bg-border"}`}
                />
              ))}
            </div>
            {wizardStep === 0 && (
              <CreateCustomerForm
                api={api}
                baseUrl={baseUrl}
                onCreated={handleWizardCustomerCreated}
                onBack={closeDialog}
              />
            )}
            {wizardStep === 1 && (
              <CreateDeviceForm
                api={api}
                customerId={wizardCustomerId}
                onCreated={handleWizardDeviceCreated}
                onBack={() => setWizardStep(0)}
              />
            )}
            {wizardStep === 2 && (
              <CreateJobForm
                api={api}
                deviceId={wizardDeviceId}
                onCompleted={handleWizardCompleted}
                onBack={() => setWizardStep(1)}
              />
            )}
          </div>
        </SheetContent>
      </Sheet>

      <Dialog open={dialogType === "status"} onOpenChange={(o) => !o && closeDialog()}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Update Status</DialogTitle>
          </DialogHeader>
          {dialogJob && (
            <StatusChangeForm
              api={api}
              job={dialogJob}
              role={role}
              onSaved={handleSaved}
              onCancel={closeDialog}
            />
          )}
        </DialogContent>
      </Dialog>

      <Dialog open={dialogType === "edit"} onOpenChange={(o) => !o && closeDialog()}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Job</DialogTitle>
          </DialogHeader>
          {dialogJob && (
            <EditJobForm
              api={api}
              job={dialogJob}
              onSaved={handleSaved}
              onCancel={closeDialog}
            />
          )}
        </DialogContent>
      </Dialog>

      <Sheet open={dialogType === "part"} onOpenChange={(o) => !o && closeDialog()}>
        <SheetContent side="right" className="sm:max-w-md w-full">
          <SheetHeader>
            <SheetTitle>Log Part</SheetTitle>
          </SheetHeader>
          <div className="px-4 pb-6">
            {dialogJob && (
              <LogPartForm
                api={api}
                job={dialogJob}
                onSaved={handleSaved}
                onCancel={closeDialog}
              />
            )}
          </div>
        </SheetContent>
      </Sheet>
    </div>
  );
}
