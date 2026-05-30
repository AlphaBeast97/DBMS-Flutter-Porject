// ds-cards.jsx — TechFix composite components
// Exports: SectionHeader, StatCard, StatusBadge, JobCard, InventoryCard,
// Dialog, Sheet, EmptyState, LoadingState, ErrorState, SkeletonCard

// ─────────────────────────────────────────────────────────────
// SectionHeader — title + optional action
// ─────────────────────────────────────────────────────────────
function SectionHeader({ title, count, actionLabel, actionIcon, onAction, style }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12, ...style }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 9 }}>
        <span style={{ fontFamily: 'Space Grotesk', fontSize: 18, fontWeight: 700, color: COLORS.ink, letterSpacing: -0.2 }}>{title}</span>
        {count != null && (
          <span style={{ fontFamily: 'Space Grotesk', fontSize: 13, fontWeight: 600, color: COLORS.faint }}>{count}</span>
        )}
      </div>
      {actionLabel && (
        <button onClick={onAction} style={{
          display: 'inline-flex', alignItems: 'center', gap: 5, background: 'none', border: 'none',
          color: COLORS.coral, fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: 600, cursor: 'pointer', padding: 4,
        }}>
          {actionIcon && <Icon name={actionIcon} size={18} weight={600} />}
          {actionLabel}
        </button>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// StatCard — label + value (+ optional icon, accent, delta)
// ─────────────────────────────────────────────────────────────
function StatCard({ label, value, icon, accent = COLORS.teal, sub, style }) {
  return (
    <Card pad={15} style={{ minWidth: 150, flex: 1, ...style }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 14 }}>
        <span style={{ fontFamily: 'Space Grotesk', fontSize: 13, fontWeight: 600, color: COLORS.muted }}>{label}</span>
        {icon && (
          <div style={{
            width: 30, height: 30, borderRadius: 9, display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: `color-mix(in srgb, ${accent} 14%, #fff)`,
          }}>
            <Icon name={icon} size={18} color={accent} fill={1} />
          </div>
        )}
      </div>
      <div style={{ fontFamily: 'Space Grotesk', fontSize: 30, fontWeight: 700, color: COLORS.ink, lineHeight: 1, letterSpacing: -0.5 }}>{value}</div>
      {sub && <div style={{ fontFamily: 'Space Grotesk', fontSize: 12.5, fontWeight: 500, color: COLORS.faint, marginTop: 7 }}>{sub}</div>}
    </Card>
  );
}

// ─────────────────────────────────────────────────────────────
// StatusBadge
// ─────────────────────────────────────────────────────────────
function StatusBadge({ status, size = 'md' }) {
  const s = STATUS[status] || STATUS.pending;
  const sm = size === 'sm';
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      background: s.bg, color: s.color, borderRadius: 100,
      padding: sm ? '3px 9px' : '5px 11px', fontSize: sm ? 11.5 : 12.5, fontWeight: 600,
      fontFamily: 'Space Grotesk', whiteSpace: 'nowrap',
    }}>
      <Icon name={s.icon} size={sm ? 13 : 15} weight={600} fill={1} />
      {s.label}
    </span>
  );
}

// ─────────────────────────────────────────────────────────────
// JobCard — expandable: status, device, customer, desc, cost, actions, parts
// ─────────────────────────────────────────────────────────────
function JobCard({ job, onStatusTap, onEdit, onCancel, defaultOpen = false }) {
  const [open, setOpen] = React.useState(defaultOpen);
  const s = STATUS[job.status] || STATUS.pending;
  const parts = job.parts || [];
  const partsTotal = parts.reduce((a, p) => a + Number(p.cost || 0), 0);
  const canCancel = job.status === 'pending';
  return (
    <Card pad={0} style={{ overflow: 'hidden' }}>
      {/* accent rail */}
      <div style={{ display: 'flex' }}>
        <div style={{ width: 4, background: s.color, flexShrink: 0 }} />
        <div style={{ flex: 1, minWidth: 0, padding: '15px 15px 13px' }}>
          {/* row 1: device + status */}
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 10 }}>
            <div style={{ minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
                <Icon name={job.deviceIcon || 'devices'} size={18} color={COLORS.ink} />
                <span style={{ fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: 700, color: COLORS.ink, letterSpacing: -0.2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{job.device}</span>
              </div>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: 12.5, color: COLORS.faint, marginTop: 3, fontVariantNumeric: 'tabular-nums' }}>
                #{job.id} · {job.customer}
              </div>
            </div>
            <button onClick={() => onStatusTap && onStatusTap(job)} style={{ border: 'none', background: 'none', padding: 0, cursor: onStatusTap ? 'pointer' : 'default' }}>
              <StatusBadge status={job.status} />
            </button>
          </div>

          {/* description */}
          <div style={{ fontFamily: 'Space Grotesk', fontSize: 14, color: COLORS.muted, marginTop: 10, lineHeight: 1.45, textWrap: 'pretty' }}>{job.description}</div>

          {/* row 2: cost + expand */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 13 }}>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 7 }}>
              <span style={{ fontFamily: 'Space Grotesk', fontSize: 19, fontWeight: 700, color: COLORS.ink, fontVariantNumeric: 'tabular-nums' }}>{fmtMoney(job.cost)}</span>
              <span style={{ fontFamily: 'Space Grotesk', fontSize: 12, fontWeight: 500, color: COLORS.faint }}>{job.status === 'ready' || job.status === 'delivered' ? 'final' : 'est.'}</span>
            </div>
            <button
              onClick={() => setOpen(o => !o)}
              style={{
                display: 'inline-flex', alignItems: 'center', gap: 4, background: 'none', border: 'none',
                color: COLORS.muted, fontFamily: 'Space Grotesk', fontSize: 13, fontWeight: 600, cursor: 'pointer', padding: 4,
              }}
            >
              {parts.length ? `${parts.length} part${parts.length > 1 ? 's' : ''}` : 'Details'}
              <Icon name="expand_more" size={20} style={{ transform: open ? 'rotate(180deg)' : 'none', transition: 'transform .2s' }} />
            </button>
          </div>

          {/* expandable: parts usage + actions */}
          <div style={{ maxHeight: open ? 600 : 0, overflow: 'hidden', transition: 'max-height .28s ease' }}>
            <div style={{ paddingTop: 13 }}>
              <Divider style={{ marginBottom: 12 }} />
              <div style={{ fontFamily: 'Space Grotesk', fontSize: 12, fontWeight: 700, color: COLORS.faint, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 9 }}>Parts used</div>
              {parts.length ? (
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  {parts.map((p, i) => (
                    <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <div style={{ width: 30, height: 30, borderRadius: 8, background: COLORS.cream, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon name="memory" size={16} color={COLORS.clay} />
                      </div>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ fontFamily: 'Space Grotesk', fontSize: 13.5, fontWeight: 600, color: COLORS.ink }}>{p.name}</div>
                        <div style={{ fontFamily: 'Space Grotesk', fontSize: 11.5, color: COLORS.faint }}>by {p.loggedBy}</div>
                      </div>
                      <span style={{ fontFamily: 'Space Grotesk', fontSize: 13.5, fontWeight: 600, color: COLORS.ink, fontVariantNumeric: 'tabular-nums' }}>{fmtMoney(p.cost)}</span>
                    </div>
                  ))}
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 2, paddingTop: 8, borderTop: `1px dashed ${COLORS.line2}` }}>
                    <span style={{ fontFamily: 'Space Grotesk', fontSize: 12.5, fontWeight: 600, color: COLORS.muted }}>Parts subtotal</span>
                    <span style={{ fontFamily: 'Space Grotesk', fontSize: 13.5, fontWeight: 700, color: COLORS.clay, fontVariantNumeric: 'tabular-nums' }}>{fmtMoney(partsTotal)}</span>
                  </div>
                </div>
              ) : (
                <div style={{ fontFamily: 'Space Grotesk', fontSize: 13, color: COLORS.faint, fontStyle: 'italic' }}>No parts logged yet.</div>
              )}

              {(onEdit || onCancel || onStatusTap) && (
                <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>
                  {onStatusTap && <Btn variant="tonal" color={COLORS.sky} size="sm" icon="cached" onClick={() => onStatusTap(job)}>Status</Btn>}
                  {onEdit && <Btn variant="outlined" color={COLORS.ink} size="sm" icon="edit" onClick={() => onEdit(job)}>Edit</Btn>}
                  {onCancel && canCancel && <Btn variant="text" color={COLORS.coral} size="sm" icon="cancel" onClick={() => onCancel(job)}>Cancel</Btn>}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </Card>
  );
}

// ─────────────────────────────────────────────────────────────
// InventoryCard — part name, cost, job id, logged by
// ─────────────────────────────────────────────────────────────
function InventoryCard({ part }) {
  return (
    <Card pad={13}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 38, height: 38, borderRadius: 11, background: 'rgba(184,107,75,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <Icon name="memory" size={20} color={COLORS.clay} fill={1} />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: 'Space Grotesk', fontSize: 14.5, fontWeight: 700, color: COLORS.ink }}>{part.name}</div>
          <div style={{ fontFamily: 'Space Grotesk', fontSize: 12, color: COLORS.faint, fontVariantNumeric: 'tabular-nums' }}>Job #{part.jobId} · {part.loggedBy}</div>
        </div>
        <span style={{ fontFamily: 'Space Grotesk', fontSize: 15, fontWeight: 700, color: COLORS.ink, fontVariantNumeric: 'tabular-nums' }}>{fmtMoney(part.cost)}</span>
      </div>
    </Card>
  );
}

// ─────────────────────────────────────────────────────────────
// Dialog (centered modal) + Sheet (bottom sheet)
// ─────────────────────────────────────────────────────────────
function Scrim({ children, onClose, align = 'center' }) {
  return (
    <div
      onClick={onClose}
      style={{
        position: 'absolute', inset: 0, zIndex: 50, background: 'rgba(20,20,20,0.42)',
        display: 'flex', alignItems: align === 'bottom' ? 'flex-end' : 'center', justifyContent: 'center',
        padding: align === 'bottom' ? 0 : 22, animation: 'fadeIn .18s ease',
      }}
    >
      {children}
    </div>
  );
}

function Dialog({ title, icon, iconColor = COLORS.coral, children, onClose, actions }) {
  return (
    <Scrim onClose={onClose}>
      <div onClick={(e) => e.stopPropagation()} style={{
        background: '#fff', borderRadius: 26, width: '100%', maxWidth: 340, padding: 22,
        maxHeight: '80%', overflowY: 'auto', animation: 'popIn .2s cubic-bezier(.2,.8,.2,1)',
      }}>
        {icon && (
          <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 12 }}>
            <div style={{ width: 50, height: 50, borderRadius: 15, background: `color-mix(in srgb, ${iconColor} 14%, #fff)`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name={icon} size={26} color={iconColor} fill={1} />
            </div>
          </div>
        )}
        {title && <div style={{ fontFamily: 'Space Grotesk', fontSize: 20, fontWeight: 700, color: COLORS.ink, textAlign: icon ? 'center' : 'left', marginBottom: 14, letterSpacing: -0.3 }}>{title}</div>}
        {children}
        {actions && <div style={{ display: 'flex', gap: 10, marginTop: 20, justifyContent: 'flex-end' }}>{actions}</div>}
      </div>
    </Scrim>
  );
}

function Sheet({ title, subtitle, children, onClose, actions }) {
  return (
    <Scrim onClose={onClose} align="bottom">
      <div onClick={(e) => e.stopPropagation()} style={{
        background: COLORS.cream, borderTopLeftRadius: 28, borderTopRightRadius: 28, width: '100%',
        maxHeight: '92%', display: 'flex', flexDirection: 'column', animation: 'slideUp .26s cubic-bezier(.2,.8,.2,1)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'center', paddingTop: 10 }}>
          <div style={{ width: 36, height: 4, borderRadius: 2, background: COLORS.line2 }} />
        </div>
        <div style={{ padding: '14px 20px 6px', display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
          <div>
            <div style={{ fontFamily: 'Space Grotesk', fontSize: 21, fontWeight: 700, color: COLORS.ink, letterSpacing: -0.3 }}>{title}</div>
            {subtitle && <div style={{ fontFamily: 'Space Grotesk', fontSize: 13.5, color: COLORS.muted, marginTop: 3 }}>{subtitle}</div>}
          </div>
          <IconBtn icon="close" onClick={onClose} color={COLORS.muted} />
        </div>
        <div style={{ padding: '6px 20px 16px', overflowY: 'auto', flex: 1 }}>{children}</div>
        {actions && (
          <div style={{ padding: '14px 20px', borderTop: `1px solid ${COLORS.line}`, background: 'rgba(255,255,255,0.5)', display: 'flex', gap: 12 }}>
            {actions}
          </div>
        )}
      </div>
    </Scrim>
  );
}

// ─────────────────────────────────────────────────────────────
// State components: Empty / Loading / Error
// ─────────────────────────────────────────────────────────────
function EmptyState({ icon = 'inbox', title, body, actionLabel, onAction, color = COLORS.teal }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', padding: '54px 30px' }}>
      <div style={{ width: 78, height: 78, borderRadius: 24, background: `color-mix(in srgb, ${color} 12%, #fff)`, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 18 }}>
        <Icon name={icon} size={38} color={color} />
      </div>
      <div style={{ fontFamily: 'Space Grotesk', fontSize: 18, fontWeight: 700, color: COLORS.ink, marginBottom: 7 }}>{title}</div>
      <div style={{ fontFamily: 'Space Grotesk', fontSize: 14, color: COLORS.muted, lineHeight: 1.5, maxWidth: 260, textWrap: 'pretty' }}>{body}</div>
      {actionLabel && <div style={{ marginTop: 20 }}><Btn icon="add" onClick={onAction}>{actionLabel}</Btn></div>}
    </div>
  );
}

function SkeletonCard({ lines = 2 }) {
  return (
    <Card pad={15}>
      <div className="shimmer" style={{ height: 16, width: '55%', borderRadius: 6, marginBottom: 12 }} />
      {Array.from({ length: lines }).map((_, i) => (
        <div key={i} className="shimmer" style={{ height: 11, width: i === lines - 1 ? '70%' : '100%', borderRadius: 5, marginBottom: 9 }} />
      ))}
      <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6 }}>
        <div className="shimmer" style={{ height: 18, width: 70, borderRadius: 6 }} />
        <div className="shimmer" style={{ height: 18, width: 50, borderRadius: 100 }} />
      </div>
    </Card>
  );
}

function LoadingState({ count = 3 }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      {Array.from({ length: count }).map((_, i) => <SkeletonCard key={i} lines={2} />)}
    </div>
  );
}

function ErrorState({ title = 'Something went wrong', body = "We couldn't reach the server. Check your connection and try again.", onRetry }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', padding: '50px 30px' }}>
      <div style={{ width: 78, height: 78, borderRadius: 24, background: 'rgba(242,107,74,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 18 }}>
        <Icon name="cloud_off" size={38} color={COLORS.coral} />
      </div>
      <div style={{ fontFamily: 'Space Grotesk', fontSize: 18, fontWeight: 700, color: COLORS.ink, marginBottom: 7 }}>{title}</div>
      <div style={{ fontFamily: 'Space Grotesk', fontSize: 14, color: COLORS.muted, lineHeight: 1.5, maxWidth: 270, textWrap: 'pretty' }}>{body}</div>
      {onRetry && <div style={{ marginTop: 20 }}><Btn variant="outlined" color={COLORS.coral} icon="refresh" onClick={onRetry}>Try again</Btn></div>}
    </div>
  );
}

Object.assign(window, {
  SectionHeader, StatCard, StatusBadge, JobCard, InventoryCard,
  Dialog, Sheet, Scrim, EmptyState, LoadingState, ErrorState, SkeletonCard,
});
