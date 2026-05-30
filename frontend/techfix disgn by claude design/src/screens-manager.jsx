// screens-manager.jsx — Manager overview dashboard
// Status distribution donut, revenue (est vs finalized + target), staff, add staff.
// Exports: ManagerScreen

function Donut({ data, size = 150, thickness = 22 }) {
  const total = data.reduce((a, d) => a + d.count, 0) || 1;
  const r = (size - thickness) / 2;
  const c = 2 * Math.PI * r;
  let offset = 0;
  return (
    <div style={{ position: 'relative', width: size, height: size, flexShrink: 0 }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={COLORS.line} strokeWidth={thickness} />
        {data.map((d, i) => {
          const frac = d.count / total;
          const len = frac * c;
          const seg = (
            <circle key={i} cx={size / 2} cy={size / 2} r={r} fill="none"
              stroke={STATUS[d.status].color} strokeWidth={thickness}
              strokeDasharray={`${Math.max(0, len - 3)} ${c - Math.max(0, len - 3)}`}
              strokeDashoffset={-offset} strokeLinecap="round" />
          );
          offset += len;
          return seg;
        })}
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
        <div style={{ fontFamily: 'Space Grotesk', fontSize: 30, fontWeight: 700, color: COLORS.ink, lineHeight: 1 }}>{total}</div>
        <div style={{ fontFamily: 'Space Grotesk', fontSize: 11.5, fontWeight: 600, color: COLORS.faint, marginTop: 3 }}>total jobs</div>
      </div>
    </div>
  );
}

function AddStaffDialog({ onClose, onAdd }) {
  const [name, setName] = React.useState('');
  const [email, setEmail] = React.useState('');
  return (
    <Dialog title="Add technician" icon="person_add" iconColor={COLORS.coral} onClose={onClose}
      actions={[
        <Btn key="c" variant="text" color={COLORS.muted} onClick={onClose}>Cancel</Btn>,
        <Btn key="a" disabled={!name || !email} onClick={() => onAdd({ name, email })}>Add</Btn>,
      ]}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Field label="Full name" icon="badge" value={name} onChange={setName} autoFocus />
        <Field label="Work email" icon="mail" value={email} onChange={setEmail} type="email" />
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'rgba(42,157,143,0.08)', borderRadius: 12, padding: '10px 12px' }}>
          <Icon name="engineering" size={17} color={COLORS.teal} />
          <span style={{ fontFamily: 'Space Grotesk', fontSize: 12, color: COLORS.muted, lineHeight: 1.4 }}>Added as a Technician with their own job console.</span>
        </div>
      </div>
    </Dialog>
  );
}

function ManagerScreen({ screenState, toast }) {
  const [staff, setStaff] = React.useState(() => SEED.staff.map(s => ({ ...s })));
  const [showAdd, setShowAdd] = React.useState(false);
  const m = SEED.managerStats;

  const body = () => {
    if (screenState === 'loading') return <div style={{ padding: '4px 18px' }}><LoadingState count={4} /></div>;
    if (screenState === 'error') return <ErrorState onRetry={() => toast('Retrying…', 'sync')} />;
    if (screenState === 'empty')
      return <EmptyState icon="insights" title="No data yet" body="Once your team logs repair jobs, you'll see status distribution, revenue and team load here." color={COLORS.coral} />;

    const finalizedPct = Math.round((m.revenue.finalized / m.revenue.target) * 100);
    const estPct = Math.round((m.revenue.estimated / m.revenue.target) * 100);

    return (
      <div style={{ padding: '0 18px 24px' }}>
        {/* top KPI row */}
        <div style={{ display: 'flex', gap: 12, marginBottom: 12 }}>
          <StatCard label="Active staff" value={m.activeStaff} icon="groups" accent={COLORS.coral} sub="on shift" />
          <StatCard label="Avg turnaround" value={m.avgTurnaround} icon="timer" accent={COLORS.teal} sub="last 30 days" />
        </div>

        {/* status distribution */}
        <Card pad={18} style={{ marginBottom: 12 }}>
          <SectionHeader title="Job status" />
          <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
            <Donut data={m.distribution} />
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 9 }}>
              {m.distribution.map(d => (
                <div key={d.status} style={{ display: 'flex', alignItems: 'center', gap: 9 }}>
                  <div style={{ width: 10, height: 10, borderRadius: 3, background: STATUS[d.status].color, flexShrink: 0 }} />
                  <span style={{ flex: 1, fontFamily: 'Space Grotesk', fontSize: 13.5, color: COLORS.muted }}>{STATUS[d.status].label}</span>
                  <span style={{ fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: 700, color: COLORS.ink, fontVariantNumeric: 'tabular-nums' }}>{d.count}</span>
                </div>
              ))}
            </div>
          </div>
        </Card>

        {/* revenue */}
        <Card pad={18} style={{ marginBottom: 12 }}>
          <SectionHeader title="Revenue" actionLabel="This month" actionIcon="expand_more" onAction={() => toast('Period picker', 'calendar_month')} />
          <div style={{ display: 'flex', gap: 20, marginBottom: 16 }}>
            <div>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: 12.5, fontWeight: 600, color: COLORS.muted, marginBottom: 4 }}>Finalized</div>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: 26, fontWeight: 700, color: COLORS.teal, lineHeight: 1, fontVariantNumeric: 'tabular-nums' }}>{fmtMoney(m.revenue.finalized)}</div>
            </div>
            <div>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: 12.5, fontWeight: 600, color: COLORS.muted, marginBottom: 4 }}>Estimated</div>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: 26, fontWeight: 700, color: COLORS.ink, lineHeight: 1, fontVariantNumeric: 'tabular-nums', opacity: 0.55 }}>{fmtMoney(m.revenue.estimated)}</div>
            </div>
          </div>
          {/* target progress */}
          <div style={{ display: 'flex', justifyContent: 'space-between', fontFamily: 'Space Grotesk', fontSize: 12, fontWeight: 600, color: COLORS.faint, marginBottom: 6 }}>
            <span>Toward {fmtMoney(m.revenue.target)} target</span>
            <span>{finalizedPct}%</span>
          </div>
          <div style={{ height: 12, borderRadius: 100, background: COLORS.cream, overflow: 'hidden', position: 'relative' }}>
            <div style={{ position: 'absolute', inset: 0, width: `${estPct}%`, background: 'rgba(42,157,143,0.3)', borderRadius: 100 }} />
            <div style={{ position: 'absolute', inset: 0, width: `${finalizedPct}%`, background: COLORS.teal, borderRadius: 100 }} />
          </div>
          <div style={{ display: 'flex', gap: 16, marginTop: 10 }}>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontFamily: 'Space Grotesk', fontSize: 11.5, color: COLORS.muted }}><span style={{ width: 9, height: 9, borderRadius: 3, background: COLORS.teal }} /> Finalized</span>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontFamily: 'Space Grotesk', fontSize: 11.5, color: COLORS.muted }}><span style={{ width: 9, height: 9, borderRadius: 3, background: 'rgba(42,157,143,0.3)' }} /> Projected</span>
          </div>
        </Card>
      </div>
    );
  };

  return (
    <ScreenScaffold title="Overview" subtitle={ORG.name} avatarColor={COLORS.coral} avatarName={USERS.owner.name}
      headerExtra={<IconBtn icon="person_add" title="Add staff" bg="rgba(242,107,74,0.12)" color={COLORS.coral} onClick={() => setShowAdd(true)} />}>
      {body()}
      {showAdd && <AddStaffDialog onClose={() => setShowAdd(false)} onAdd={(s) => { setStaff(st => [...st, { ...s, role: 'Technician', open: 0, color: COLORS.teal }]); setShowAdd(false); toast('Technician added', 'person_add'); }} />}
    </ScreenScaffold>
  );
}

Object.assign(window, { ManagerScreen });
