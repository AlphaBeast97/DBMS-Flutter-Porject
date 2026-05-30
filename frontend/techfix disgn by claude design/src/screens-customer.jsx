// screens-customer.jsx — Customer status screen
// Profile, snapshot stats, device chips, device-jobs dialog, cancel pending.
// Exports: CustomerScreen

function DeviceJobsDialog({ device, onClose, onCancel }) {
  return (
    <Dialog onClose={onClose}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
        <div style={{ width: 46, height: 46, borderRadius: 14, background: 'rgba(45,123,209,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name={device.icon} size={24} color={COLORS.sky} fill={1} />
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: 'Space Grotesk', fontSize: 18, fontWeight: 700, color: COLORS.ink, letterSpacing: -0.3 }}>{device.name}</div>
          <div style={{ fontFamily: 'Space Grotesk', fontSize: 12.5, color: COLORS.faint }}>{device.jobs.length} repair{device.jobs.length !== 1 ? 's' : ''} on record</div>
        </div>
        <IconBtn icon="close" onClick={onClose} color={COLORS.muted} />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
        {device.jobs.map(j => (
          <div key={j.id} style={{ border: `1px solid ${COLORS.line}`, borderRadius: 16, padding: 13 }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
              <span style={{ fontFamily: 'Space Grotesk', fontSize: 13, fontWeight: 600, color: COLORS.faint, fontVariantNumeric: 'tabular-nums' }}>#{j.id}</span>
              <StatusBadge status={j.status} size="sm" />
            </div>
            <div style={{ fontFamily: 'Space Grotesk', fontSize: 13.5, color: COLORS.muted, lineHeight: 1.4, textWrap: 'pretty' }}>{j.description}</div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 11 }}>
              <span style={{ fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: 700, color: COLORS.ink, fontVariantNumeric: 'tabular-nums' }}>{fmtMoney(j.cost)}</span>
              {j.status === 'pending' && (
                <Btn variant="text" size="sm" color={COLORS.coral} icon="cancel" onClick={() => onCancel(j)}>Cancel</Btn>
              )}
              {j.status === 'ready' && <Pill color={COLORS.teal} icon="storefront">Ready for pickup</Pill>}
            </div>
          </div>
        ))}
      </div>
    </Dialog>
  );
}

function CustomerScreen({ screenState, toast }) {
  const [devices, setDevices] = React.useState(() => SEED.customerDevices.map(d => ({ ...d, jobs: d.jobs.map(j => ({ ...j })) })));
  const [openDevice, setOpenDevice] = React.useState(null);
  const cust = USERS.customer;

  const allJobs = devices.flatMap(d => d.jobs);
  const active = allJobs.filter(j => j.status === 'pending' || j.status === 'repairing').length;
  const ready = allJobs.filter(j => j.status === 'ready').length;

  const cancelJob = (jobId) => {
    setDevices(ds => ds.map(d => ({ ...d, jobs: d.jobs.map(j => j.id === jobId ? { ...j, status: 'cancelled' } : j) })));
    setOpenDevice(od => od ? { ...od, jobs: od.jobs.map(j => j.id === jobId ? { ...j, status: 'cancelled' } : j) } : od);
    toast('Repair cancelled', 'cancel');
  };

  const body = () => {
    if (screenState === 'loading') return <div style={{ padding: '4px 18px' }}><LoadingState count={3} /></div>;
    if (screenState === 'error') return <ErrorState onRetry={() => toast('Retrying…', 'sync')} />;

    const isEmpty = screenState === 'empty';

    return (
      <div style={{ padding: '0 18px 24px' }}>
        {/* profile card */}
        <Card pad={18} style={{ marginBottom: 16 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <Avatar name={cust.name} size={54} color={COLORS.sky} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: 19, fontWeight: 700, color: COLORS.ink, letterSpacing: -0.3 }}>{cust.name}</div>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: 13, color: COLORS.muted, display: 'flex', alignItems: 'center', gap: 6, marginTop: 2 }}>
                <Icon name="call" size={14} color={COLORS.faint} /> {cust.phone}
              </div>
            </div>
            <Pill color={COLORS.teal} icon="verified">Member · {cust.since}</Pill>
          </div>
        </Card>

        {/* snapshot stats */}
        <div style={{ display: 'flex', gap: 12, marginBottom: 20 }}>
          <StatCard label="Active repairs" value={isEmpty ? 0 : active} icon="build" accent={COLORS.sky} sub="in the shop now" />
          <StatCard label="Ready today" value={isEmpty ? 0 : ready} icon="check_circle" accent={COLORS.teal} sub="for pickup" />
        </div>

        {/* devices */}
        <SectionHeader title="Your devices" count={isEmpty ? 0 : devices.length} />
        {isEmpty ? (
          <EmptyState icon="devices_other" title="No devices yet" body="When you drop off a device for repair, it'll show up here so you can track its progress." color={COLORS.sky} />
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
            {devices.map(d => {
              const act = d.jobs.find(j => j.status === 'pending' || j.status === 'repairing');
              const rdy = d.jobs.find(j => j.status === 'ready');
              const lead = rdy || act || d.jobs[0];
              return (
                <Card key={d.id} pad={14} interactive onClick={() => setOpenDevice(d)}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
                    <div style={{ width: 46, height: 46, borderRadius: 14, background: COLORS.cream, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                      <Icon name={d.icon} size={24} color={COLORS.ink} />
                    </div>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ fontFamily: 'Space Grotesk', fontSize: 15.5, fontWeight: 700, color: COLORS.ink }}>{d.name}</div>
                      <div style={{ fontFamily: 'Space Grotesk', fontSize: 12.5, color: COLORS.faint }}>{d.jobs.length} repair{d.jobs.length !== 1 ? 's' : ''} · tap to view</div>
                    </div>
                    <StatusBadge status={lead.status} size="sm" />
                    <Icon name="chevron_right" size={22} color={COLORS.faint} />
                  </div>
                </Card>
              );
            })}
          </div>
        )}
      </div>
    );
  };

  return (
    <ScreenScaffold title="My repairs" subtitle="Track your devices" avatarColor={COLORS.sky} avatarName={cust.name}>
      {body()}
      {openDevice && <DeviceJobsDialog device={openDevice} onClose={() => setOpenDevice(null)} onCancel={(j) => cancelJob(j.id)} />}
    </ScreenScaffold>
  );
}

Object.assign(window, { CustomerScreen });
