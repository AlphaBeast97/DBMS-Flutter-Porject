// ds-core.jsx — TechFix design tokens + primitive components
// Exact tokens from the existing Flutter design system.
// Exports to window: COLORS, STATUS, fmtMoney, Icon, AppBackground, Card,
// Btn, IconBtn, Field, SegBtn, Pill, Chip, Avatar, Divider

const COLORS = {
  coral:  '#F26B4A',
  teal:   '#2A9D8F',
  sky:    '#2D7BD1',
  clay:   '#B86B4B',
  ink:    '#141414',
  cream:  '#F7F3ED',
  // derived warm neutrals (kept within the cream family)
  beige:  '#EFE7DA',
  line:   'rgba(20,20,20,0.08)',
  line2:  'rgba(20,20,20,0.14)',
  muted:  'rgba(20,20,20,0.55)',
  faint:  'rgba(20,20,20,0.38)',
  grey:   '#9A958C',
  white:  '#FFFFFF',
};

// status -> { label, color, soft bg, icon }
const STATUS = {
  pending:   { label: 'Pending',   color: COLORS.clay, bg: 'rgba(184,107,75,0.12)',  icon: 'schedule' },
  repairing: { label: 'Repairing', color: COLORS.sky,  bg: 'rgba(45,123,209,0.12)',  icon: 'build' },
  ready:     { label: 'Ready',     color: COLORS.teal, bg: 'rgba(42,157,143,0.14)',  icon: 'check_circle' },
  cancelled: { label: 'Cancelled', color: COLORS.grey, bg: 'rgba(154,149,140,0.16)', icon: 'cancel' },
  delivered: { label: 'Delivered', color: COLORS.teal, bg: 'rgba(42,157,143,0.14)',  icon: 'local_shipping' },
};

const fmtMoney = (n) =>
  '$' + Number(n || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

// ─────────────────────────────────────────────────────────────
// Icon — Material Symbols Rounded
// ─────────────────────────────────────────────────────────────
function Icon({ name, size = 24, weight = 400, fill = 0, color, style, className }) {
  return (
    <span
      className={'msr' + (className ? ' ' + className : '')}
      style={{
        fontSize: size,
        color,
        lineHeight: 1,
        fontVariationSettings: `'FILL' ${fill}, 'wght' ${weight}, 'GRAD' 0, 'opsz' ${Math.min(48, Math.max(20, size))}`,
        ...style,
      }}
    >{name}</span>
  );
}

// ─────────────────────────────────────────────────────────────
// AppBackground — gradient cream→warm beige + 3 glow circles
// ─────────────────────────────────────────────────────────────
function AppBackground({ children, style }) {
  const glow = (top, left, size, color, op) => ({
    position: 'absolute', top, left, width: size, height: size,
    borderRadius: '50%', background: color, opacity: op,
    filter: 'blur(60px)', pointerEvents: 'none',
  });
  return (
    <div style={{
      position: 'relative', height: '100%', width: '100%', overflow: 'hidden',
      background: `linear-gradient(160deg, ${COLORS.cream} 0%, #F1E9DB 60%, ${COLORS.beige} 100%)`,
      ...style,
    }}>
      <div style={glow(-70, -60, 240, COLORS.coral, 0.16)} />
      <div style={glow(180, 260, 220, COLORS.teal, 0.13)} />
      <div style={glow(560, -80, 280, COLORS.sky, 0.10)} />
      <div style={{ position: 'relative', height: '100%', zIndex: 1 }}>{children}</div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Card — white, radius 20, no elevation (hairline for hierarchy)
// ─────────────────────────────────────────────────────────────
function Card({ children, style, onClick, pad = 16, tone = 'white', interactive }) {
  const bg = tone === 'white' ? COLORS.white
    : tone === 'cream' ? 'rgba(255,255,255,0.55)'
    : tone;
  return (
    <div
      onClick={onClick}
      style={{
        background: bg,
        borderRadius: 20,
        border: `1px solid ${COLORS.line}`,
        padding: pad,
        boxSizing: 'border-box',
        cursor: onClick || interactive ? 'pointer' : 'default',
        transition: 'border-color .15s, transform .15s, background .15s',
        ...style,
      }}
      onMouseDown={(e) => { if (onClick || interactive) e.currentTarget.style.transform = 'scale(0.992)'; }}
      onMouseUp={(e) => { if (onClick || interactive) e.currentTarget.style.transform = 'scale(1)'; }}
      onMouseLeave={(e) => { if (onClick || interactive) e.currentTarget.style.transform = 'scale(1)'; }}
    >
      {children}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Buttons — Material 3 filled / tonal / outlined / text
// ─────────────────────────────────────────────────────────────
function Btn({ children, onClick, variant = 'filled', color = COLORS.coral, icon, size = 'md', full, disabled, style }) {
  const h = size === 'sm' ? 38 : size === 'lg' ? 52 : 46;
  const fs = size === 'sm' ? 14 : 15;
  const base = {
    height: h, display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
    gap: 8, padding: size === 'sm' ? '0 16px' : '0 22px', borderRadius: 100,
    fontFamily: 'Space Grotesk, sans-serif', fontSize: fs, fontWeight: 600, letterSpacing: 0.1,
    border: 'none', cursor: disabled ? 'not-allowed' : 'pointer', width: full ? '100%' : 'auto',
    opacity: disabled ? 0.45 : 1, transition: 'filter .15s, background .15s, box-shadow .15s',
    whiteSpace: 'nowrap', boxSizing: 'border-box',
  };
  const variants = {
    filled:   { background: color, color: '#fff' },
    tonal:    { background: `color-mix(in srgb, ${color} 14%, #fff)`, color: color },
    outlined: { background: 'transparent', color: color, border: `1.5px solid ${color}` },
    text:     { background: 'transparent', color: color, padding: '0 12px' },
  };
  return (
    <button
      onClick={disabled ? undefined : onClick}
      style={{ ...base, ...variants[variant], ...style }}
      onMouseEnter={(e) => { if (!disabled) e.currentTarget.style.filter = 'brightness(0.96)'; }}
      onMouseLeave={(e) => { e.currentTarget.style.filter = 'none'; }}
    >
      {icon && <Icon name={icon} size={fs + 5} weight={600} />}
      {children}
    </button>
  );
}

function IconBtn({ icon, onClick, color = COLORS.ink, size = 40, iconSize, bg = 'transparent', fill = 0, title, style }) {
  return (
    <button
      title={title}
      onClick={onClick}
      style={{
        width: size, height: size, borderRadius: '50%', border: 'none', background: bg,
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer', color, flexShrink: 0, transition: 'background .15s', ...style,
      }}
      onMouseEnter={(e) => { e.currentTarget.style.background = 'rgba(20,20,20,0.06)'; }}
      onMouseLeave={(e) => { e.currentTarget.style.background = bg; }}
    >
      <Icon name={icon} size={iconSize || size * 0.55} color={color} fill={fill} />
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// Field — Material 3 outlined text field (with optional icon)
// ─────────────────────────────────────────────────────────────
function Field({ label, value, onChange, icon, type = 'text', placeholder, error, suffix, multiline, rows = 3, autoFocus, style }) {
  const [focus, setFocus] = React.useState(false);
  const border = error ? COLORS.coral : focus ? COLORS.teal : COLORS.line2;
  const Tag = multiline ? 'textarea' : 'input';
  return (
    <div style={{ ...style }}>
      <div style={{
        display: 'flex', alignItems: multiline ? 'flex-start' : 'center', gap: 10,
        background: '#fff', border: `1.5px solid ${border}`, borderRadius: 14,
        padding: multiline ? '12px 14px' : '0 14px', height: multiline ? 'auto' : 50,
        transition: 'border-color .15s',
      }}>
        {icon && <Icon name={icon} size={20} color={focus ? COLORS.teal : COLORS.faint} style={{ marginTop: multiline ? 2 : 0 }} />}
        <Tag
          value={value}
          autoFocus={autoFocus}
          onChange={(e) => onChange && onChange(e.target.value)}
          onFocus={() => setFocus(true)}
          onBlur={() => setFocus(false)}
          type={type}
          rows={multiline ? rows : undefined}
          placeholder={placeholder || label}
          style={{
            flex: 1, border: 'none', outline: 'none', background: 'transparent',
            fontFamily: 'Space Grotesk, sans-serif', fontSize: 15, color: COLORS.ink,
            resize: 'none', padding: multiline ? 0 : 0, lineHeight: 1.4,
          }}
        />
        {suffix && <span style={{ fontSize: 14, color: COLORS.faint, fontFamily: 'Space Grotesk' }}>{suffix}</span>}
      </div>
      {error && <div style={{ fontSize: 12, color: COLORS.coral, marginTop: 5, marginLeft: 4 }}>{error}</div>}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// SegBtn — Material 3 segmented button
// ─────────────────────────────────────────────────────────────
function SegBtn({ options, value, onChange, color = COLORS.teal, style }) {
  return (
    <div style={{
      display: 'flex', border: `1.5px solid ${COLORS.line2}`, borderRadius: 100,
      overflow: 'hidden', background: '#fff', ...style,
    }}>
      {options.map((opt, i) => {
        const v = opt.value ?? opt;
        const active = v === value;
        return (
          <button
            key={v}
            onClick={() => onChange(v)}
            style={{
              flex: 1, height: 44, border: 'none', cursor: 'pointer',
              background: active ? `color-mix(in srgb, ${color} 16%, #fff)` : 'transparent',
              color: active ? color : COLORS.muted,
              fontFamily: 'Space Grotesk, sans-serif', fontSize: 14, fontWeight: 600,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
              borderLeft: i ? `1.5px solid ${COLORS.line2}` : 'none', transition: 'all .15s',
            }}
          >
            {active && <Icon name="check" size={17} weight={600} />}
            {opt.icon && !active && <Icon name={opt.icon} size={17} />}
            {opt.label ?? opt}
          </button>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Pill / Chip / Avatar / Divider
// ─────────────────────────────────────────────────────────────
function Pill({ children, color = COLORS.ink, bg, icon, style }) {
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      background: bg || `color-mix(in srgb, ${color} 12%, #fff)`, color,
      borderRadius: 100, padding: '5px 11px', fontSize: 12.5, fontWeight: 600,
      fontFamily: 'Space Grotesk, sans-serif', whiteSpace: 'nowrap', ...style,
    }}>
      {icon && <Icon name={icon} size={14} weight={600} fill={1} />}
      {children}
    </span>
  );
}

function Chip({ children, icon, active, onClick, color = COLORS.ink, style }) {
  return (
    <button
      onClick={onClick}
      style={{
        display: 'inline-flex', alignItems: 'center', gap: 7,
        background: active ? `color-mix(in srgb, ${color} 14%, #fff)` : '#fff',
        border: `1.5px solid ${active ? color : COLORS.line2}`,
        color: active ? color : COLORS.ink,
        borderRadius: 12, padding: '9px 13px', fontSize: 13.5, fontWeight: 600,
        fontFamily: 'Space Grotesk, sans-serif', cursor: onClick ? 'pointer' : 'default',
        transition: 'all .15s', ...style,
      }}
    >
      {icon && <Icon name={icon} size={17} color={active ? color : COLORS.muted} />}
      {children}
    </button>
  );
}

function Avatar({ name, size = 40, color = COLORS.teal, icon }) {
  const initials = (name || '?').split(' ').map(w => w[0]).slice(0, 2).join('').toUpperCase();
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%', flexShrink: 0,
      background: `color-mix(in srgb, ${color} 18%, #fff)`, color,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontFamily: 'Space Grotesk, sans-serif', fontWeight: 700, fontSize: size * 0.36,
    }}>
      {icon ? <Icon name={icon} size={size * 0.5} color={color} /> : initials}
    </div>
  );
}

function Divider({ style }) {
  return <div style={{ height: 1, background: COLORS.line, ...style }} />;
}

Object.assign(window, {
  COLORS, STATUS, fmtMoney,
  Icon, AppBackground, Card, Btn, IconBtn, Field, SegBtn, Pill, Chip, Avatar, Divider,
});
