// screens-login.jsx — TechFix login (3 roles, owner sign in/up toggle)
// Exports: LoginScreen

function Brandmark({ size = 56 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: 18, flexShrink: 0,
      background: `linear-gradient(145deg, ${COLORS.coral}, #E0553A)`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: '0 8px 22px rgba(242,107,74,0.32)',
    }}>
      <Icon name="handyman" size={size * 0.5} color="#fff" fill={1} />
    </div>
  );
}

function LoginScreen({ onSignIn }) {
  const [role, setRole] = React.useState('owner');     // owner | employee | customer
  const [mode, setMode] = React.useState('signin');    // signin | signup (owner only)
  const [email, setEmail] = React.useState('');
  const [pw, setPw] = React.useState('');
  const [org, setOrg] = React.useState('');
  const [name, setName] = React.useState('');
  const [busy, setBusy] = React.useState(false);

  const isSignup = role === 'owner' && mode === 'signup';

  const roleMeta = {
    owner:    { icon: 'shield_person', tint: COLORS.coral, blurb: 'Full org access — manage staff, revenue & all jobs.' },
    employee: { icon: 'engineering',   tint: COLORS.teal,  blurb: 'Technician console — your jobs and parts logging.' },
    customer: { icon: 'person',        tint: COLORS.sky,   blurb: 'Track your repairs and pick-up status.' },
  }[role];

  const submit = () => {
    setBusy(true);
    setTimeout(() => { setBusy(false); onSignIn(role); }, 900);
  };

  const cta = isSignup ? 'Create workshop' : 'Sign in';

  return (
    <AppBackground>
      <div style={{ height: '100%', overflowY: 'auto', display: 'flex', flexDirection: 'column', padding: '0 22px' }}>
        {/* brand header */}
        <div style={{ paddingTop: 46, paddingBottom: 26, display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
          <Brandmark />
          <div style={{ fontFamily: 'Space Grotesk', fontSize: 30, fontWeight: 700, color: COLORS.ink, marginTop: 16, letterSpacing: -0.6 }}>TechFix</div>
          <div style={{ fontFamily: 'Space Grotesk', fontSize: 14.5, color: COLORS.muted, marginTop: 4 }}>Repair workflow, handled.</div>
        </div>

        {/* role segmented control */}
        <SegBtn
          options={[
            { value: 'owner', label: 'Owner', icon: 'shield_person' },
            { value: 'employee', label: 'Employee', icon: 'engineering' },
            { value: 'customer', label: 'Customer', icon: 'person' },
          ]}
          value={role}
          onChange={(v) => { setRole(v); setMode('signin'); }}
        />

        {/* card */}
        <Card pad={20} style={{ marginTop: 18 }}>
          {/* role blurb */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 11, marginBottom: 18 }}>
            <div style={{ width: 42, height: 42, borderRadius: 13, background: `color-mix(in srgb, ${roleMeta.tint} 14%, #fff)`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <Icon name={roleMeta.icon} size={23} color={roleMeta.tint} fill={1} />
            </div>
            <div style={{ fontFamily: 'Space Grotesk', fontSize: 13, color: COLORS.muted, lineHeight: 1.4, textWrap: 'pretty' }}>{roleMeta.blurb}</div>
          </div>

          {/* owner sign in / sign up toggle */}
          {role === 'owner' && (
            <div style={{ display: 'flex', background: COLORS.cream, borderRadius: 12, padding: 4, marginBottom: 16 }}>
              {['signin', 'signup'].map(m => (
                <button key={m} onClick={() => setMode(m)} style={{
                  flex: 1, height: 36, border: 'none', borderRadius: 9, cursor: 'pointer',
                  background: mode === m ? '#fff' : 'transparent',
                  boxShadow: mode === m ? '0 1px 4px rgba(0,0,0,0.06)' : 'none',
                  color: mode === m ? COLORS.ink : COLORS.muted,
                  fontFamily: 'Space Grotesk', fontSize: 13.5, fontWeight: 600, transition: 'all .15s',
                }}>{m === 'signin' ? 'Sign in' : 'Sign up'}</button>
              ))}
            </div>
          )}

          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {isSignup && <Field label="Workshop name" icon="storefront" value={org} onChange={setOrg} placeholder="Workshop name" />}
            {isSignup && <Field label="Your name" icon="badge" value={name} onChange={setName} placeholder="Your name" />}
            <Field label="Email" icon="mail" value={email} onChange={setEmail} placeholder={role === 'customer' ? 'Email on your ticket' : 'Email'} type="email" />
            {role !== 'customer' && <Field label="Password" icon="lock" value={pw} onChange={setPw} placeholder="Password" type="password" />}
          </div>

          {role === 'customer' && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'rgba(45,123,209,0.08)', borderRadius: 12, padding: '10px 12px', marginTop: 14 }}>
              <Icon name="info" size={17} color={COLORS.sky} />
              <span style={{ fontFamily: 'Space Grotesk', fontSize: 12, color: COLORS.muted, lineHeight: 1.4 }}>Enter the email on your repair ticket to see your devices.</span>
            </div>
          )}

          <div style={{ marginTop: 18 }}>
            <Btn full size="lg" color={roleMeta.tint} icon={busy ? undefined : (isSignup ? 'rocket_launch' : 'login')} onClick={submit} disabled={busy}>
              {busy ? 'Just a moment…' : cta}
            </Btn>
          </div>

          {isSignup && (
            <div style={{ fontFamily: 'Space Grotesk', fontSize: 11.5, color: COLORS.faint, textAlign: 'center', marginTop: 12, lineHeight: 1.5 }}>
              Creating your workshop sets up the org and signs you in automatically.
            </div>
          )}
        </Card>

        <div style={{ flex: 1 }} />
        <div style={{ textAlign: 'center', padding: '22px 0 26px', fontFamily: 'Space Grotesk', fontSize: 12, color: COLORS.faint }}>
          {role === 'customer' ? 'No account needed — just your email.' : 'Northgate Repair Co. · v2.4'}
        </div>
      </div>
    </AppBackground>
  );
}

Object.assign(window, { LoginScreen, Brandmark });
