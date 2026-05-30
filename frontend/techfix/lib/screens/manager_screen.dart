import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/empty_state.dart';
import 'package:techfix/widgets/error_state.dart';
import 'package:techfix/widgets/field.dart';
import 'package:techfix/widgets/loading_state.dart';
import 'package:techfix/widgets/job_card.dart';
import 'package:techfix/widgets/section_header.dart';

// ─────────────────────────────────────────────────────────────
// Donut chart — CustomPainter
// ─────────────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<({Color color, double count})> segments;

  _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    const thickness = 22.0;
    final total = segments.fold<double>(0, (s, seg) => s + seg.count);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background circle
    final bgPaint = Paint()
      ..color = AppTheme.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -1.5708; // -90 degrees
    for (final seg in segments) {
      final sweepAngle = (seg.count / total) * 6.28319; // full circle
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle.clamp(0.001, 6.28319), false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => segments != old.segments;
}

// ─────────────────────────────────────────────────────────────
// AddStaffDialog
// ─────────────────────────────────────────────────────────────
class AddStaffDialog extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<Map<String, String>> onAdd;

  const AddStaffDialog({
    super.key,
    required this.onClose,
    required this.onAdd,
  });

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _pwCtl = TextEditingController();

  bool get _valid => _nameCtl.text.isNotEmpty && _emailCtl.text.isNotEmpty && _pwCtl.text.isNotEmpty;

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _pwCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: const Color(0x6B141414),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 340, maxHeight: 460),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.coral.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.person_add, size: 26, color: AppTheme.coral),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Add technician',
                          style: TextStyle(
                            
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Field(
                          label: 'Full name',
                          icon: Icons.badge,
                          value: _nameCtl.text,
                          onChanged: (v) { _nameCtl.text = v; setState(() {}); },
                          autoFocus: true,
                        ),
                        const SizedBox(height: 12),
                        Field(
                          label: 'Work email',
                          icon: Icons.mail,
                          value: _emailCtl.text,
                          onChanged: (v) { _emailCtl.text = v; setState(() {}); },
                        ),
                        const SizedBox(height: 12),
                        Field(
                          label: 'Password',
                          icon: Icons.lock,
                          value: _pwCtl.text,
                          onChanged: (v) { _pwCtl.text = v; setState(() {}); },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.teal.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.engineering, size: 17, color: AppTheme.teal),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Added as a Technician with their own job console.',
                                  style: TextStyle(
                                    
                                    fontSize: 12,
                                    color: AppTheme.muted,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: widget.onClose,
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _valid
                                  ? () => widget.onAdd({
                                        'name': _nameCtl.text,
                                        'email': _emailCtl.text,
                                        'password': _pwCtl.text,
                                      })
                                  : null,
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ManagerScreen
// ─────────────────────────────────────────────────────────────
class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  late Future<List<RepairJob>> _jobsFuture;
  bool _showAddStaff = false;
  int _jobLimit = 5;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _jobsFuture = _loadJobs();
  }

  Future<List<RepairJob>> _loadJobs() async {
    final session = AppSessionScope.of(context);
    final api = TechFixApi(
      baseUrl: session.baseUrl,
      email: session.email,
      password: session.password,
    );
    final orgId = session.employee?['organization_id'] as int?;
    final rows = await api.getRepairJobs(organizationId: orgId);
    return rows.map(RepairJob.fromApi).toList();
  }

  void _refresh() => setState(() => _jobsFuture = _loadJobs());

  void _signOut() {
    final session = AppSessionScope.of(context);
    session.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String fmtMoney(double n) => '\$${n.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text(
                'Overview',
                style: TextStyle(
                  
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => setState(() => _showAddStaff = true),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.coral.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(Icons.person_add, size: 20, color: AppTheme.coral),
                  ),
                ),
                TextButton(onPressed: _signOut, child: const Text('Sign out')),
              ],
            ),
            body: FutureBuilder<List<RepairJob>>(
              future: _jobsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(18, 4, 18, 0),
                    child: LoadingState(count: 4),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                    child: ErrorState(
                      body: snapshot.error?.toString() ?? 'Failed to load dashboard data.',
                      onRetry: _refresh,
                    ),
                  );
                }

                final jobs = snapshot.data!;
                if (jobs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.insights,
                    title: 'No data yet',
                    body: 'Once your team logs repair jobs, you\'ll see status distribution, revenue and team load here.',
                    color: AppTheme.coral,
                  );
                }

                // Compute stats
                final pending = jobs.where((j) => j.status.toLowerCase() == 'pending').length;
                final repairing = jobs.where((j) => j.status.toLowerCase() == 'repairing' || j.status.toLowerCase() == 'in progress').length;
                final ready = jobs.where((j) => j.status.toLowerCase() == 'ready').length;
                final delivered = jobs.where((j) => j.status.toLowerCase() == 'delivered' || j.status.toLowerCase() == 'completed').length;
                final cancelled = jobs.where((j) => j.status.toLowerCase() == 'cancelled').length;

                final totalEstimated = jobs.fold<double>(0, (s, j) => s + j.estimatedCost);
                final totalFinal = jobs.fold<double>(0, (s, j) => s + (j.finalCost ?? 0));
                final revenueTarget = 9000.0;
                final finalizedPct = revenueTarget > 0 ? ((totalFinal / revenueTarget) * 100).round() : 0;
                final estPct = revenueTarget > 0 ? ((totalEstimated / revenueTarget) * 100).round() : 0;

                final distribution = [
                  if (pending > 0) (status: 'pending', count: pending),
                  if (repairing > 0) (status: 'repairing', count: repairing),
                  if (ready > 0) (status: 'ready', count: ready),
                  if (delivered > 0) (status: 'delivered', count: delivered),
                  if (cancelled > 0) (status: 'cancelled', count: cancelled),
                ];

                final totalJobs = jobs.length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                  children: [
                    // Status distribution card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Job status'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CustomPaint(
                                  painter: _DonutPainter(
                                    segments: distribution.map((d) => (
                                      color: AppTheme.statusColor(d.status),
                                      count: d.count.toDouble(),
                                    )).toList(),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$totalJobs',
                                          style: const TextStyle(
                                            
                                            fontSize: 30,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.ink,
                                            height: 1,
                                          ),
                                        ),
                                        const Text(
                                          'total jobs',
                                          style: TextStyle(
                                            
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.faint,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  children: distribution.map((d) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 9),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: AppTheme.statusColor(d.status),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                          const SizedBox(width: 9),
                                          Expanded(
                                            child: Text(
                                              AppTheme.statusLabel(d.status),
                                              style: const TextStyle(
                                                
                                                fontSize: 13.5,
                                                color: AppTheme.muted,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${d.count}',
                                            style: const TextStyle(
                                              
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Revenue card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            title: 'Revenue',
                            actionLabel: 'This month',
                            actionIcon: Icons.expand_more,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Finalized',
                                      style: TextStyle(
                                        
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      fmtMoney(totalFinal),
                                      style: const TextStyle(
                                        
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.teal,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Estimated',
                                      style: TextStyle(
                                        
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      fmtMoney(totalEstimated),
                                      style: const TextStyle(
                                        
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.ink,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Toward ${fmtMoney(revenueTarget)} target',
                                style: const TextStyle(
                                  
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.faint,
                                ),
                              ),
                              Text(
                                '$finalizedPct%',
                                style: const TextStyle(
                                  
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.faint,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: SizedBox(
                              height: 12,
                              child: Stack(
                                children: [
                                  Container(color: AppTheme.cream),
                                  FractionallySizedBox(
                                    widthFactor: (estPct / 100).clamp(0, 1),
                                    child: Container(color: AppTheme.teal.withOpacity(0.3)),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: (finalizedPct / 100).clamp(0, 1),
                                    child: Container(color: AppTheme.teal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _LegendDot(color: AppTheme.teal, label: 'Finalized'),
                              const SizedBox(width: 16),
                              _LegendDot(color: AppTheme.teal.withOpacity(0.3), label: 'Projected'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SectionHeader(title: 'All repairs', count: jobs.length),
                    const SizedBox(height: 12),
                    ...(jobs.toList()..sort((a, b) => b.id.compareTo(a.id))).take(_jobLimit).map((job) => JobCard(job: job)),
                    if (_jobLimit < jobs.length) ...[
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => _jobLimit += 10),
                          child: Text(
                            'Show ${(jobs.length - _jobLimit).clamp(0, 10)} more  \u2193',
                            style: const TextStyle(
                              
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.muted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),

        if (_showAddStaff)
          AddStaffDialog(
            onClose: () => setState(() => _showAddStaff = false),
            onAdd: (data) {
              final session = AppSessionScope.of(context);
              final api = TechFixApi(
                baseUrl: session.baseUrl,
                email: session.email,
                password: session.password,
              );
              api.createEmployee(
                name: data['name']!,
                email: data['email']!,
                password: data['password']!,
              ).then((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Technician added!')),
                  );
                }
              }).catchError((e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.coral),
                  );
                }
              });
              setState(() => _showAddStaff = false);
            },
          ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            
            fontSize: 11.5,
            color: AppTheme.muted,
          ),
        ),
      ],
    );
  }
}
