// data.jsx — believable seed data for TechFix.
// Swap these arrays for your real sample data; shapes match TechFixApi responses.
// Exports: SEED, ORG, USERS

const ORG = { id: 1, name: 'Northgate Repair Co.', plan: 'Workshop', since: '2021' };

const USERS = {
  owner:    { role: 'owner',    name: 'Dana Whitfield', email: 'dana@northgaterepair.com' },
  employee: { role: 'employee', name: 'Marcus Lee',     email: 'marcus@northgaterepair.com' },
  customer: { role: 'customer', name: 'Priya Anand',    email: 'priya.anand@gmail.com', phone: '(415) 555-0182', since: 'Mar 2024' },
};

// Jobs for the Technician console (self-created, pending/repairing) + broader org set for Manager.
const SEED = {
  // Technician's own active jobs
  techJobs: [
    {
      id: '4821', device: 'iPhone 13 Pro', deviceIcon: 'smartphone', brand: 'Apple', model: '13 Pro', serial: 'F2LX…9KQ',
      customer: 'Priya Anand', status: 'repairing', cost: 189.0,
      description: 'Cracked rear glass + intermittent charging. Replacing back housing and Lightning flex.',
      parts: [
        { name: 'Rear glass housing', cost: 64.0, jobId: '4821', loggedBy: 'Marcus L.' },
        { name: 'Charging flex cable', cost: 28.5, jobId: '4821', loggedBy: 'Marcus L.' },
      ],
    },
    {
      id: '4830', device: 'MacBook Air M2', deviceIcon: 'laptop_mac', brand: 'Apple', model: 'Air M2', serial: 'C02…GH7',
      customer: 'Tomas Berg', status: 'pending', cost: 240.0,
      description: 'Liquid damage — keyboard unresponsive, trackpad intermittent. Awaiting diagnostic teardown.',
      parts: [],
    },
    {
      id: '4834', device: 'Galaxy S23', deviceIcon: 'smartphone', brand: 'Samsung', model: 'S23', serial: 'R5C…X12',
      customer: 'Lena Ortiz', status: 'repairing', cost: 132.5,
      description: 'Screen replacement — green vertical line after drop. OEM panel swap.',
      parts: [{ name: 'AMOLED display assembly', cost: 89.0, jobId: '4834', loggedBy: 'Marcus L.' }],
    },
    {
      id: '4841', device: 'iPad Air (5th gen)', deviceIcon: 'tablet_mac', brand: 'Apple', model: 'Air 5', serial: 'DMP…44L',
      customer: 'Priya Anand', status: 'pending', cost: 95.0,
      description: 'Battery drains overnight. Battery health 71% — quoting replacement.',
      parts: [],
    },
  ],

  // Customer (Priya) devices + their jobs
  customerDevices: [
    { id: 'd1', name: 'iPhone 13 Pro', icon: 'smartphone', jobs: [
      { id: '4821', device: 'iPhone 13 Pro', deviceIcon: 'smartphone', customer: 'Priya Anand', status: 'repairing', cost: 189.0, description: 'Cracked rear glass + intermittent charging.', parts: [{ name: 'Rear glass housing', cost: 64.0, jobId: '4821', loggedBy: 'Marcus L.' }] },
    ]},
    { id: 'd2', name: 'iPad Air (5th gen)', icon: 'tablet_mac', jobs: [
      { id: '4841', device: 'iPad Air (5th gen)', deviceIcon: 'tablet_mac', customer: 'Priya Anand', status: 'pending', cost: 95.0, description: 'Battery drains overnight. Quoting replacement.', parts: [] },
    ]},
    { id: 'd3', name: 'AirPods Pro', icon: 'headphones', jobs: [
      { id: '4690', device: 'AirPods Pro', deviceIcon: 'headphones', customer: 'Priya Anand', status: 'ready', cost: 49.0, description: 'Right bud no audio — driver replaced.', parts: [{ name: 'Right earbud driver', cost: 22.0, jobId: '4690', loggedBy: 'Marcus L.' }] },
    ]},
    { id: 'd4', name: 'Apple Watch S7', icon: 'watch', jobs: [
      { id: '4512', device: 'Apple Watch S7', deviceIcon: 'watch', customer: 'Priya Anand', status: 'delivered', cost: 79.0, description: 'Screen replacement.', parts: [] },
    ]},
  ],

  // Manager: org-wide job status distribution + revenue + staff
  managerStats: {
    distribution: [
      { status: 'pending',   count: 8 },
      { status: 'repairing', count: 11 },
      { status: 'ready',     count: 5 },
      { status: 'delivered', count: 21 },
      { status: 'cancelled', count: 3 },
    ],
    revenue: { estimated: 6840, finalized: 4915, target: 9000 },
    activeStaff: 4,
    avgTurnaround: '2.4d',
  },

  staff: [
    { name: 'Marcus Lee',   role: 'Technician', email: 'marcus@northgaterepair.com', open: 4, color: '#2A9D8F' },
    { name: 'Dana Whitfield', role: 'Owner · Manager', email: 'dana@northgaterepair.com', open: 0, color: '#F26B4A' },
    { name: 'Sofia Reyes',  role: 'Technician', email: 'sofia@northgaterepair.com', open: 6, color: '#2D7BD1' },
    { name: 'Jamal Carter', role: 'Technician', email: 'jamal@northgaterepair.com', open: 3, color: '#B86B4B' },
  ],

  recentInventory: [
    { name: 'AMOLED display assembly', cost: 89.0, jobId: '4834', loggedBy: 'Marcus L.' },
    { name: 'Rear glass housing', cost: 64.0, jobId: '4821', loggedBy: 'Marcus L.' },
    { name: 'Logic board (refurb)', cost: 210.0, jobId: '4799', loggedBy: 'Sofia R.' },
  ],
};

Object.assign(window, { SEED, ORG, USERS });
