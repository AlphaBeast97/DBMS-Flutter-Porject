import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/models/inventory_usage.dart';
import 'package:techfix/screens/manager/add_staff_dialog.dart';
import 'package:techfix/screens/manager/donut_painter.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/shared/utils.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/empty_state.dart';
import 'package:techfix/widgets/error_state.dart';
import 'package:techfix/widgets/fade_in.dart';
import 'package:techfix/widgets/job_card.dart';
import 'package:techfix/widgets/loading_state.dart';
import 'package:techfix/widgets/section_header.dart';
import 'package:techfix/widgets/toast.dart';

// ─────────────────────────────────────────────────────────────
// ManagerScreen
// ─────────────────────────────────────────────────────────────
class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  late Future<({List<RepairJob> jobs, Map<int, List<InventoryUsage>> usages})> _jobsFuture;
  bool _showAddStaff = false;
  int _jobLimit = 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _jobsFuture = _loadData();
  }

  Future<({List<RepairJob> jobs, Map<int, List<InventoryUsage>> usages})> _loadData() async {
    final session = AppSessionScope.of(context);
    final api = TechFixApi(
      baseUrl: session.baseUrl,
      email: session.email,
      password: session.password,
    );
    final orgId = session.employee?['organization_id'] as int?;
    final rows = await api.getRepairJobs(organizationId: orgId);
    final jobs = rows.map(RepairJob.fromApi).toList();

    final usages = await TechFixApi.fetchUsagesForJobs(api, jobs);
    return (jobs: jobs, usages: usages);
  }

  void _refresh() => setState(() => _jobsFuture = _loadData());

  void _signOut() => signOut(context);

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
            body: FutureBuilder(
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

                final data = snapshot.data!;
                final jobs = data.jobs;
                final jobUsages = data.usages;
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
                                  painter: DonutPainter(
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
                              LegendDot(color: AppTheme.teal, label: 'Finalized'),
                              const SizedBox(width: 16),
                              LegendDot(color: AppTheme.teal.withOpacity(0.3), label: 'Projected'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SectionHeader(title: 'All repairs', count: jobs.length),
                    const SizedBox(height: 12),
                    ...(jobs.toList()..sort((a, b) => b.id.compareTo(a.id))).take(_jobLimit).toList().asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeIn(
                        delayMs: e.key * 60,
                        child: JobCard(job: e.value, usages: jobUsages[e.value.id]),
                      ),
                    )),
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
                if (mounted) showToast(context, 'Technician added!');
              }).catchError((e) {
                if (mounted) showToast(context, 'Error: $e', type: ToastType.error);
              });
              setState(() => _showAddStaff = false);
            },
          ),
      ],
    );
  }
}


