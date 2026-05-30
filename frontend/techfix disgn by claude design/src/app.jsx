// app.jsx — TechFix prototype shell
// ScreenScaffold, role-based HomeShell (NavigationBar + IndexedStack),
// toast system, login flow, and out-of-device prototype controls.

// ─────────────────────────────────────────────────────────────
// ScreenScaffold — per-screen header + scroll body + optional FAB
// ─────────────────────────────────────────────────────────────
function ScreenScaffold({ title, subtitle, avatarColor = COLORS.teal, avatarName, headerExtra, fab, children }) {
  return (
    <div style={{ position: 'relative', height: '100%', display: 'flex', flexDirection: 'column', minHeight: 0 }}>
      {/* header */}
      <div style={{ padding: '14px 18px 12px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <Avatar name={avatarName || title} size={42} color={avatarColor} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: 'Space Grotesk', fontSize: 21, fontWeight: 700, color: COLORS.ink, letterSpacing: -0.4, lineHeight: 1.1 }}>{title}</div>
          {subtitle && <div style={{ fontFamily: 'Space Grotesk', fontSize: 13, color: COLORS.muted, marginTop: 1 }}>{subtitle}</div>}
        </div>
        {headerExtra}
      </div>
      {/* scroll body */}
      <div style={{ flex: 1, overflowY: 'auto', minHeight: 0 }}>{children}</div>
      {/* FAB */}
      {fab && (
        <button onClick={fab.onClick} style={{
          position: 'absolute', right: 18, bottom: 18, height: 54, borderRadius: 18,
          background: COLORS.coral, color: '#fff', border: 'none', cursor: 'pointer',
          display: 'inline-flex', alignItems: 'center', gap: 9, padding: '0 20px',
          fontFamily: 'Space Grotesk', fontSize: 15, fontWeight: 600,
          boxShadow: '0 10px 26px rgba(242,107,74,0.4)', transition: 'transform .15s',
        }}
        onMouseDown={(e) => e.currentTarget.style.transform = 'scale(0.96)'}
        onMouseUp={(e) => e.currentTarget.style.transform = 'scale(1)'}
        onMouseLeave={(e) => e.currentTarget.style.transform = 'scale(1)'}>
          <Icon name={fab.icon} size={22} weight={600} />{fab.label}
        </button>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// NavigationBar — Material 3, role-based tabs
// ─────────────────────────────────────────────────────────────
function NavBar({ tabs, active, onChange }) {
  return (
    <div style={{
      display: 'flex', background: 'rgba(247,243,237,0.92)', backdropFilter: 'blur(12px)',
      borderTop: `1px solid ${COLORS.line}`, padding: '8px 6px 10px', flexShrink: 0,
    }}>
      {tabs.map(t => {
        const on = t.key === active;
        return (
          <button key={t.key} onClick={() => onChange(t.key)} style={{
            flex: 1, border: 'none', background: 'none', cursor: 'pointer',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, padding: '4px 0',
          }}>
            <div style={{
              width: 58, height: 32, borderRadius: 100, display: 'flex', alignItems: 'center', justifyContent: 'center',
              background: on ? `color-mix(in srgb, ${t.color} 18%, ${COLORS.cream})` : 'transparent', transition: 'background .18s',
            }}>
              <Icon name={t.icon} size={23} color={on ? t.color : COLORS.muted} fill={on ? 1 : 0} weight={on ? 600 : 400} />
            </div>
            <span style={{ fontFamily: 'Space Grotesk', fontSize: 11.5, fontWeight: on ? 700 : 500, color: on ? COLORS.ink : COLORS.muted }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Toast
// ─────────────────────────────────────────────────────────────
function Toast({ toast }) {
  if (!toast) return null;
  return (
    <div style={{
      position: 'absolute', left: '50%', bottom: 92, transform: 'translateX(-50%)', zIndex: 80,
      display: 'flex', alignItems: 'center', gap: 9, background: COLORS.ink, color: '#fff',
      padding: '11px 18px', borderRadius: 100, fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: 600,
      boxShadow: '0 10px 30px rgba(0,0,0,0.3)', animation: 'toastIn .25s cubic-bezier(.2,.8,.2,1)', whiteSpace: 'nowrap',
    }}>
      <Icon name={toast.icon || 'check_circle'} size={19} color={COLORS.teal} fill={1} />
      {toast.msg}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// HomeShell — role-based nav + IndexedStack
// ─────────────────────────────────────────────────────────────
const TAB_DEFS = {
  customer:   { key: 'customer',   label: 'My Repairs', icon: 'devices',     color: COLORS.sky },
  technician: { key: 'technician', label: 'Technician', icon: 'engineering', color: COLORS.teal },
  manager:    { key: 'manager',    label: 'Overview',   icon: 'insights',    color: COLORS.coral },
};

function tabsForRole(role) {
  if (role === 'customer') return [TAB_DEFS.customer];
  if (role === 'employee') return [TAB_DEFS.technician];
  return [TAB_DEFS.manager]; // owner / manager — stats screen only
}

function HomeShell({ role, screenState, onLogout, initialTab }) {
  const tabs = tabsForRole(role);
  const [active, setActive] = React.useState(initialTab && tabs.find(t => t.key === initialTab) ? initialTab : tabs[tabs.length - 1].key);
  const [toast, setToastState] = React.useState(null);
  const toastTimer = React.useRef(null);

  // keep active tab valid when role changes
  React.useEffect(() => {
    if (!tabs.find(t => t.key === active)) setActive(tabs[tabs.length - 1].key);
  }, [role]);

  const pushToast = (msg, icon) => {
    setToastState({ msg, icon });
    clearTimeout(toastTimer.current);
    toastTimer.current = setTimeout(() => setToastState(null), 2200);
  };

  const screenProps = { screenState, toast: pushToast };

  return (
    <AppBackground>
      <div style={{ position: 'relative', height: '100%', display: 'flex', flexDirection: 'column', minHeight: 0 }}>
        {/* IndexedStack — keep all mounted, show active */}
        <div style={{ flex: 1, minHeight: 0, position: 'relative' }}>
          {tabs.map(t => (
            <div key={t.key} style={{ position: 'absolute', inset: 0, visibility: t.key === active ? 'visible' : 'hidden' }}>
              {t.key === 'customer' && <CustomerScreen {...screenProps} />}
              {t.key === 'technician' && <TechnicianScreen {...screenProps} />}
              {t.key === 'manager' && <ManagerScreen {...screenProps} />}
            </div>
          ))}
        </div>
        <Toast toast={toast} />
        {tabs.length > 1 && <NavBar tabs={tabs} active={active} onChange={setActive} />}
      </div>
    </AppBackground>
  );
}

Object.assign(window, { ScreenScaffold, NavBar, HomeShell, Toast, tabsForRole });
