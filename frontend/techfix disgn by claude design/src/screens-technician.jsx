// screens-technician.jsx — Technician console
// Self-created pending/repairing jobs, search, status update, edit, parts,
// Create Job (multi-step sheet) and Log Part flows.
// Exports: TechnicianScreen

function StatusRadioDialog({ job, onClose, onSave }) {
  const [val, setVal] = React.useState(job.status);
  const order = ['pending', 'repairing', 'ready', 'delivered', 'cancelled'];
  return (
    <Dialog title="Update status" icon="cached" iconColor={COLORS.sky} onClose={onClose}
      actions={[
        <Btn key="c" variant="text" color={COLORS.muted} onClick={onClose}>Cancel</Btn>,
        <Btn key="s" color={COLORS.sky} onClick={() => onSave(val)}>Save</Btn>,
      ]}>
      <div style={{ fontFamily: 'Space Grotesk', fontSize: 13, color: COLORS.muted, textAlign: 'center', marginTop: -4, marginBottom: 14 }}>
        {job.device} · #{job.id}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        {order.map(st => {
          const s = STATUS[st];
          const active = val === st;
          return (
            <button key={st} onClick={() => setVal(st)} style={{
              display: 'flex', alignItems: 'center', gap: 12, padding: '11px 13px', borderRadius: 14, cursor: 'pointer',
              border: `1.5px solid ${active ? s.color : COLORS.line}`, background: active ? s.bg : '#fff', transition: 'all .15s',
            }}>
              <Icon name={s.icon} size={20} color={s.color} fill={active ? 1 : 0} />
              <span style={{ flex: 1, textAlign: 'left', fontFamily: 'Space Grotesk', fontSize: 15, fontWeight: 600, color: COLORS.ink }}>{s.label}</span>
              <Icon name={active ? 'radio_button_checked' : 'radio_button_unchecked'} size={20} color={active ? s.color : COLORS.faint} />
            </button>
          );
        })}
      </div>
    </Dialog>
  );
}

function EditDescDialog({ job, onClose, onSave }) {
  const [desc, setDesc] = React.useState(job.description);
  const [cost, setCost] = React.useState(String(job.cost));
  return (
    <Dialog title="Edit job" icon="edit" iconColor={COLORS.ink} onClose={onClose}
      actions={[
        <Btn key="c" variant="text" color={COLORS.muted} onClick={onClose}>Cancel</Btn>,
        <Btn key="s" onClick={() => onSave({ description: desc, cost: parseFloat(cost) || 0 })}>Save</Btn>,
      ]}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Field label="Description" value={desc} onChange={setDesc} multiline rows={4} autoFocus />
        <Field label="Estimated cost" icon="payments" value={cost} onChange={setCost} type="number" suffix="USD" />
      </div>
    </Dialog>
  );
}

const DEVICE_TYPES = [
  { label: 'Phone', icon: 'smartphone' }, { label: 'Laptop', icon: 'laptop_mac' },
  { label: 'Tablet', icon: 'tablet_mac' }, { label: 'Watch', icon: 'watch' },
  { label: 'Audio', icon: 'headphones' }, { label: 'Other', icon: 'devices_other' },
];

function CreateJobSheet({ onClose, onCreate }) {
  const [step, setStep] = React.useState(0); // 0 customer, 1 device, 2 issue
  const [f, setF] = React.useState({ cEmail: '', cName: '', cPhone: '', dType: 'Phone', dIcon: 'smartphone', brand: '', model: '', serial: '', desc: '', cost: '' });
  const set = (k, v) => setF(s => ({ ...s, [k]: v }));
  const steps = ['Customer', 'Device', 'Issue'];

  const next = () => step < 2 ? setStep(step + 1) : onCreate(f);
  const valid = step === 0 ? f.cEmail && f.cName : step === 1 ? f.brand && f.model : f.desc && f.cost;

  return (
    <Sheet title="New repair job" subtitle="Creates customer → device → job" onClose={onClose}
      actions={[
        step > 0 ? <Btn key="b" variant="outlined" color={COLORS.ink} onClick={() => setStep(step - 1)} style={{ flex: 0 }}>Back</Btn> : null,
        <Btn key="n" full color={COLORS.coral} icon={step === 2 ? 'check' : 'arrow_forward'} disabled={!valid} onClick={next} style={{ flex: 1 }}>
          {step === 2 ? 'Create job' : 'Continue'}
        </Btn>,
      ]}>
      {/* stepper */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 18 }}>
        {steps.map((s, i) => (
          <div key={s} style={{ flex: 1 }}>
            <div style={{ height: 4, borderRadius: 2, background: i <= step ? COLORS.coral : COLORS.line2, transition: 'background .2s' }} />
            <div style={{ fontFamily: 'Space Grotesk', fontSize: 11.5, fontWeight: 600, color: i <= step ? COLORS.ink : COLORS.faint, marginTop: 6 }}>{i + 1}. {s}</div>
          </div>
        ))}
      </div>

      {step === 0 && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <Field label="Customer email" icon="mail" value={f.cEmail} onChange={v => set('cEmail', v)} type="email" autoFocus />
          <Field label="Customer name" icon="person" value={f.cName} onChange={v => set('cName', v)} />
          <Field label="Phone" icon="call" value={f.cPhone} onChange={v => set('cPhone', v)} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'rgba(45,123,209,0.08)', borderRadius: 12, padding: '10px 12px' }}>
            <Icon name="info" size={17} color={COLORS.sky} />
            <span style={{ fontFamily: 'Space Grotesk', fontSize: 12, color: COLORS.muted, lineHeight: 1.4 }}>Existing customers are matched by email automatically.</span>
          </div>
        </div>
      )}

      {step === 1 && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <div>
            <div style={{ fontFamily: 'Space Grotesk', fontSize: 13, fontWeight: 600, color: COLORS.muted, marginBottom: 8 }}>Device type</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
              {DEVICE_TYPES.map(d => (
                <Chip key={d.label} icon={d.icon} active={f.dType === d.label} color={COLORS.teal}
                  onClick={() => setF(s => ({ ...s, dType: d.label, dIcon: d.icon }))}>{d.label}</Chip>
              ))}
            </div>
          </div>
          <Field label="Brand" icon="sell" value={f.brand} onChange={v => set('brand', v)} />
          <Field label="Model" icon="devices" value={f.model} onChange={v => set('model', v)} />
          <Field label="Serial / IMEI" icon="qr_code_2" value={f.serial} onChange={v => set('serial', v)} />
        </div>
      )}

      {step === 2 && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <Field label="Issue description" value={f.desc} onChange={v => set('desc', v)} multiline rows={4} autoFocus placeholder="What's wrong with the device?" />
          <Field label="Estimated cost" icon="payments" value={f.cost} onChange={v => set('cost', v)} type="number" suffix="USD" />
          <Card pad={13} tone="white" style={{ background: COLORS.white }}>
            <div style={{ fontFamily: 'Space Grotesk', fontSize: 12, fontWeight: 700, color: COLORS.faint, textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 8 }}>Summary</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <Avatar name={f.cName || '?'} size={36} color={COLORS.sky} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: 600, color: COLORS.ink }}>{f.cName || 'New customer'}</div>
                <div style={{ fontFamily: 'Space Grotesk', fontSize: 12, color: COLORS.faint }}>{f.dType} · {f.brand || '—'} {f.model}</div>
              </div>
            </div>
          </Card>
        </div>
      )}
    </Sheet>
  );
}

function LogPartSheet({ jobs, onClose, onLog }) {
  const [jobId, setJobId] = React.useState(jobs[0]?.id || '');
  const [name, setName] = React.useState('');
  const [cost, setCost] = React.useState('');
  const valid = jobId && name && cost;
  return (
    <Sheet title="Log a part" subtitle="Record inventory used on a job" onClose={onClose}
      actions={[<Btn key="l" full color={COLORS.clay} icon="add" disabled={!valid} onClick={() => onLog({ jobId, name, cost: parseFloat(cost) || 0 })}>Log part</Btn>]}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div>
          <div style={{ fontFamily: 'Space Grotesk', fontSize: 13, fontWeight: 600, color: COLORS.muted, marginBottom: 8 }}>Assign to job</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {jobs.map(j => (
              <button key={j.id} onClick={() => setJobId(j.id)} style={{
                display: 'flex', alignItems: 'center', gap: 11, padding: '11px 13px', borderRadius: 14, cursor: 'pointer',
                border: `1.5px solid ${jobId === j.id ? COLORS.clay : COLORS.line}`, background: jobId === j.id ? 'rgba(184,107,75,0.08)' : '#fff', transition: 'all .15s',
              }}>
                <Icon name={j.deviceIcon} size={20} color={COLORS.ink} />
                <div style={{ flex: 1, textAlign: 'left', minWidth: 0 }}>
                  <div style={{ fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: 600, color: COLORS.ink }}>{j.device}</div>
                  <div style={{ fontFamily: 'Space Grotesk', fontSize: 12, color: COLORS.faint }}>#{j.id} · {j.customer}</div>
                </div>
                <Icon name={jobId === j.id ? 'radio_button_checked' : 'radio_button_unchecked'} size={20} color={jobId === j.id ? COLORS.clay : COLORS.faint} />
              </button>
            ))}
          </div>
        </div>
        <Field label="Part name" icon="memory" value={name} onChange={setName} placeholder="e.g. AMOLED display assembly" />
        <Field label="Part cost" icon="payments" value={cost} onChange={setCost} type="number" suffix="USD" />
      </div>
    </Sheet>
  );
}

function TechnicianScreen({ screenState, toast }) {
  const [jobs, setJobs] = React.useState(() => SEED.techJobs.map(j => ({ ...j })));
  const [query, setQuery] = React.useState('');
  const [filter, setFilter] = React.useState('all');
  const [dialog, setDialog] = React.useState(null); // {type, job}

  const filtered = jobs.filter(j => {
    if (filter !== 'all' && j.status !== filter) return false;
    if (!query) return true;
    const q = query.toLowerCase();
    return [j.device, j.customer, j.id, j.status].some(v => String(v).toLowerCase().includes(q));
  });

  const counts = {
    all: jobs.length,
    pending: jobs.filter(j => j.status === 'pending').length,
    repairing: jobs.filter(j => j.status === 'repairing').length,
  };

  const updateJob = (id, patch) => setJobs(js => js.map(j => j.id === id ? { ...j, ...patch } : j));

  const body = () => {
    if (screenState === 'loading') return <div style={{ padding: '4px 18px' }}><LoadingState count={3} /></div>;
    if (screenState === 'error') return <ErrorState onRetry={() => toast('Retrying…', 'sync')} />;
    if (screenState === 'empty' || jobs.length === 0)
      return <EmptyState icon="construction" title="No active jobs" body="You have no pending or in-progress repairs. Create a job to get started." actionLabel="Create job" onAction={() => setDialog({ type: 'create' })} color={COLORS.coral} />;

    return (
      <div style={{ padding: '0 18px 24px' }}>
        {/* search */}
        <Field icon="search" value={query} onChange={setQuery} placeholder="Search device, customer, #id, status" style={{ marginBottom: 12 }} />

        {/* filter chips */}
        <div style={{ display: 'flex', gap: 8, marginBottom: 16, overflowX: 'auto', paddingBottom: 2 }}>
          {[['all', 'All'], ['pending', 'Pending'], ['repairing', 'Repairing']].map(([k, lbl]) => (
            <Chip key={k} active={filter === k} color={k === 'pending' ? COLORS.clay : k === 'repairing' ? COLORS.sky : COLORS.ink} onClick={() => setFilter(k)}>
              {lbl} <span style={{ opacity: 0.6 }}>{counts[k]}</span>
            </Chip>
          ))}
        </div>

        {filtered.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px 20px', fontFamily: 'Space Grotesk', color: COLORS.faint }}>
            <Icon name="search_off" size={34} color={COLORS.faint} />
            <div style={{ fontSize: 14, marginTop: 10 }}>No jobs match "{query || filter}"</div>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {filtered.map((j, i) => (
              <JobCard key={j.id} job={j} defaultOpen={i === 0 && screenState === 'loaded'}
                onStatusTap={(job) => setDialog({ type: 'status', job })}
                onEdit={(job) => setDialog({ type: 'edit', job })}
                onCancel={(job) => { updateJob(job.id, { status: 'cancelled' }); toast('Job cancelled', 'cancel'); }}
              />
            ))}
          </div>
        )}
      </div>
    );
  };

  return (
    <ScreenScaffold
      title="Technician"
      subtitle={USERS.employee.name}
      avatarColor={COLORS.teal}
      fab={{ icon: 'add', label: 'Create job', onClick: () => setDialog({ type: 'create' }) }}
      headerExtra={
        <IconBtn icon="inventory_2" title="Log part" bg="rgba(184,107,75,0.12)" color={COLORS.clay} fill={1} onClick={() => setDialog({ type: 'logpart' })} />
      }
    >
      {body()}

      {dialog?.type === 'status' && (
        <StatusRadioDialog job={dialog.job} onClose={() => setDialog(null)}
          onSave={(st) => { updateJob(dialog.job.id, { status: st }); setDialog(null); toast(`Marked ${STATUS[st].label}`, STATUS[st].icon); }} />
      )}
      {dialog?.type === 'edit' && (
        <EditDescDialog job={dialog.job} onClose={() => setDialog(null)}
          onSave={(patch) => { updateJob(dialog.job.id, patch); setDialog(null); toast('Job updated', 'check'); }} />
      )}
      {dialog?.type === 'create' && (
        <CreateJobSheet onClose={() => setDialog(null)}
          onCreate={(f) => {
            const id = String(4840 + Math.floor(Math.random() * 60));
            setJobs(js => [{ id, device: `${f.brand} ${f.model}`.trim() || f.dType, deviceIcon: f.dIcon, customer: f.cName, status: 'pending', cost: parseFloat(f.cost) || 0, description: f.desc, parts: [] }, ...js]);
            setDialog(null); toast('Job created', 'add_task');
          }} />
      )}
      {dialog?.type === 'logpart' && (
        <LogPartSheet jobs={jobs} onClose={() => setDialog(null)}
          onLog={(p) => {
            setJobs(js => js.map(j => j.id === p.jobId ? { ...j, parts: [...(j.parts || []), { name: p.name, cost: p.cost, jobId: p.jobId, loggedBy: 'Marcus L.' }] } : j));
            setDialog(null); toast('Part logged', 'inventory_2');
          }} />
      )}
    </ScreenScaffold>
  );
}

Object.assign(window, { TechnicianScreen });
