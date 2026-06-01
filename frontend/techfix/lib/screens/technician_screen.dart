/// Technician screen — the main workspace for repair staff.
///
/// Shows a searchable, filterable list of active (Pending/Repairing) jobs.
/// Each job card has action buttons for:
/// - Updating status (via [StatusRadioDialog])
/// - Editing description (via [EditDescDialog])
/// - Cancelling the job
///
/// Floating action button opens [CreateJobSheet] (3-step wizard).
/// AppBar action opens [LogPartSheet] to log parts against any job.
///
/// All dialogs/sheets are rendered as overlay widgets in a [Stack],
/// managed by state variables ([_dialogType], [_dialogJob]).
import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/models/inventory_usage.dart';
import 'package:techfix/screens/technician/create_job_sheet.dart';
import 'package:techfix/screens/technician/edit_desc_dialog.dart';
import 'package:techfix/screens/technician/log_part_sheet.dart';
import 'package:techfix/screens/technician/status_radio_dialog.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/shared/utils.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/empty_state.dart';
import 'package:techfix/widgets/error_state.dart';
import 'package:techfix/widgets/fade_in.dart';
import 'package:techfix/widgets/filter_chip.dart';
import 'package:techfix/widgets/job_card.dart';
import 'package:techfix/widgets/loading_state.dart';
import 'package:techfix/widgets/toast.dart';

class TechnicianScreen extends StatefulWidget {
  const TechnicianScreen({super.key});

  @override
  State<TechnicianScreen> createState() => _TechnicianScreenState();
}

class _TechnicianScreenState extends State<TechnicianScreen> {
  late Future<List<RepairJob>> _jobsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filter = 'all';

  // Dialog/sheet orchestration: _dialogType determines which overlay is shown,
  // _dialogJob is the job being acted upon (null for create/logpart).
  String? _dialogType;
  RepairJob? _dialogJob;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _jobsFuture = _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches all repair jobs for the authenticated employee.
  Future<List<RepairJob>> _loadJobs() async {
    final session = AppSessionScope.of(context);
    final api = TechFixApi(
      baseUrl: session.baseUrl,
      email: session.email,
      password: session.password,
    );
    final rows = await api.getRepairJobs();
    return rows.map(RepairJob.fromApi).toList();
  }

  /// Fetches inventory usage data for a list of jobs, grouped by job ID.
  Future<Map<int, List<InventoryUsage>>> _fetchUsagesForJobs(List<RepairJob> jobs) async {
    final s = AppSessionScope.of(context);
    final api = TechFixApi(
      baseUrl: s.baseUrl,
      email: s.email,
      password: s.password,
    );
    return TechFixApi.fetchUsagesForJobs(api, jobs);
  }

  void _refresh() {
    _jobsFuture = _loadJobs();
    setState(() {});
  }

  void _performSearch() => setState(() => _searchQuery = _searchController.text.trim());

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
                'Technician',
                style: TextStyle(
                  
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                // Log part button (accessible from AppBar)
                IconButton(
                  onPressed: () => setState(() {
                    _dialogType = 'logpart';
                    _dialogJob = null;
                  }),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.clay.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(Icons.inventory_2, size: 20, color: AppTheme.clay),
                  ),
                ),
                TextButton(onPressed: _signOut, child: const Text('Sign out')),
              ],
            ),
            body: _buildBody(),
            // FAB to create a new job
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => setState(() {
                _dialogType = 'create';
                _dialogJob = null;
              }),
              backgroundColor: AppTheme.coral,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Create job',
                style: TextStyle( fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),

        // --- Dialog/Sheet overlays ---
        if (_dialogType == 'status' && _dialogJob != null)
          StatusRadioDialog(
            job: _dialogJob!,
            onClose: () => setState(() { _dialogType = null; _dialogJob = null; }),
            onSave: (st) {
              _updateJobStatus(_dialogJob!.id, st);
              setState(() { _dialogType = null; _dialogJob = null; });
            },
          ),
        if (_dialogType == 'edit' && _dialogJob != null)
          EditDescDialog(
            job: _dialogJob!,
            onClose: () => setState(() { _dialogType = null; _dialogJob = null; }),
            onSave: (patch) {
              _updateJobDesc(_dialogJob!.id, patch);
              setState(() { _dialogType = null; _dialogJob = null; });
            },
          ),
        if (_dialogType == 'create')
          CreateJobSheet(
            onClose: () => setState(() { _dialogType = null; _dialogJob = null; }),
            onCreate: (f) => _createJob(f),
          ),
        if (_dialogType == 'logpart')
          FutureBuilder<List<RepairJob>>(
            future: _jobsFuture,
            builder: (context, snap) {
              final jobs = snap.data ?? [];
              return LogPartSheet(
                jobs: jobs,
                onClose: () => setState(() { _dialogType = null; _dialogJob = null; }),
                onLog: (p) => _logPart(p),
              );
            },
          ),
      ],
    );
  }

  /// Builds the main body: search bar, filter chips, and job list.
  Widget _buildBody() {
    return FutureBuilder<List<RepairJob>>(
      future: _jobsFuture,
      builder: (context, snapshot) {
        // --- Loading state ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(18, 4, 18, 0),
            child: LoadingState(count: 3),
          );
        }

        // --- Error state ---
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
            child: ErrorState(
              body: snapshot.error?.toString() ?? 'Failed to load jobs.',
              onRetry: _refresh,
            ),
          );
        }

        final allJobs = snapshot.data!;
        // Technicians only see Pending and Repairing jobs
        final activeJobs = allJobs
            .where((j) => j.status.toLowerCase() == 'pending' || j.status.toLowerCase() == 'repairing')
            .toList();

        // --- Empty state ---
        if (activeJobs.isEmpty) {
          return EmptyState(
            icon: Icons.construction,
            title: 'No active jobs',
            body: 'You have no pending or in-progress repairs. Create a job to get started.',
            actionLabel: 'Create job',
            onAction: () => setState(() { _dialogType = 'create'; _dialogJob = null; }),
            color: AppTheme.coral,
          );
        }

        // --- Apply filter ---
        var filtered = activeJobs;
        if (_filter == 'pending') {
          filtered = filtered.where((j) => j.status.toLowerCase() == 'pending').toList();
        } else if (_filter == 'repairing') {
          filtered = filtered.where((j) => j.status.toLowerCase() == 'repairing').toList();
        }

        // --- Apply search ---
        final q = _searchQuery.toLowerCase();
        if (q.isNotEmpty) {
          filtered = filtered.where((j) {
            return j.deviceLabel.toLowerCase().contains(q) ||
                j.customerName.toLowerCase().contains(q) ||
                j.id.toString().contains(q) ||
                j.status.toLowerCase().contains(q);
          }).toList();
        }

        // Sort newest first
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final pendingCount = activeJobs.where((j) => j.status.toLowerCase() == 'pending').length;
        final repairingCount = activeJobs.where((j) => j.status.toLowerCase() == 'repairing').length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
          children: [
            // --- Search bar ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.line2),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search device, customer, #id, status',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, size: 18),
                        onPressed: _performSearch,
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (_) => _performSearch(),
              ),
            ),
            const SizedBox(height: 12),

            // --- Filter chips ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChipWidget(
                    label: 'All',
                    count: activeJobs.length,
                    active: _filter == 'all',
                    color: AppTheme.ink,
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: 'Pending',
                    count: pendingCount,
                    active: _filter == 'pending',
                    color: AppTheme.clay,
                    onTap: () => setState(() => _filter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: 'Repairing',
                    count: repairingCount,
                    active: _filter == 'repairing',
                    color: AppTheme.sky,
                    onTap: () => setState(() => _filter = 'repairing'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Job list or "no results" state ---
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 34, color: AppTheme.faint),
                    const SizedBox(height: 10),
                    Text(
                      'No jobs match "${_searchQuery}"',
                      style: const TextStyle(
                        
                        fontSize: 14,
                        color: AppTheme.faint,
                      ),
                    ),
                  ],
                ),
              )
            else
              // Fetch usages and render JobCards
              FutureBuilder<Map<int, List<InventoryUsage>>>(
                future: _fetchUsagesForJobs(filtered),
                builder: (context, usagesSnap) {
                  final usagesMap = usagesSnap.data ?? {};
                  return Column(
                    children: filtered.asMap().entries.map((e) {
                      final i = e.key;
                      final job = e.value;
                      final usages = usagesMap[job.id] ?? [];
                      return FadeIn(
                        delayMs: i * 60,
                        child: JobCard(
                          job: job,
                          key: ValueKey(job.id),
                          usages: usages,
                          onStatusTap: () => setState(() {
                            _dialogType = 'status';
                            _dialogJob = job;
                          }),
                          onEdit: () => setState(() {
                            _dialogType = 'edit';
                            _dialogJob = job;
                          }),
                          onCancel: () {
                            _updateJobStatus(job.id, 'cancelled');
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  /// Calls API to update job status, then refreshes the list.
  void _updateJobStatus(int jobId, String status) {
    final session = AppSessionScope.of(context);
    TechFixApi(
      baseUrl: session.baseUrl,
      email: session.email,
      password: session.password,
    ).updateRepairJobStatus(jobId: jobId, status: status).then((_) {
      _refresh();
      if (mounted) {
        showToast(context, 'Marked ${AppTheme.statusLabel(status)}');
      }
    }).catchError((e) {
      if (mounted) {
        showToast(context, 'Error: $e', type: ToastType.error);
      }
    });
  }

  /// Calls API to update job description, then refreshes.
  void _updateJobDesc(int jobId, Map<String, dynamic> patch) {
    final session = AppSessionScope.of(context);
    final api = TechFixApi(
      baseUrl: session.baseUrl,
      email: session.email,
      password: session.password,
    );
    api.updateJobDescription(jobId: jobId, description: patch['description'] as String).then((_) {
      _refresh();
      if (mounted) {
        showToast(context, 'Job updated');
      }
    }).catchError((e) {
      if (mounted) {
        showToast(context, 'Error: $e', type: ToastType.error);
      }
    });
  }

  /// Multi-step job creation: customer → device → repair job.
  /// Each step calls the corresponding API endpoint sequentially.
  void _createJob(Map<String, String> f) {
    final session = AppSessionScope.of(context);
    final api = TechFixApi(
      baseUrl: session.baseUrl,
      email: session.email,
      password: session.password,
    );

    (() async {
      // Step 1: Create customer
      final email = f['cEmail']!;
      final name = f['cName']!;
      final phone = f['cPhone']!.isNotEmpty ? f['cPhone']! : '0000000000';
      final customerId = await api.createCustomer(name: name, phone: phone, email: email);

      // Step 2: Create device under customer
      final deviceId = await api.createDevice(
        customerId: customerId,
        type: f['dType']!,
        brand: f['brand']!,
        model: f['model']!,
        serialNumber: f['serial']!.isNotEmpty ? f['serial']! : 'N/A',
      );

      // Step 3: Create repair job for device
      await api.createRepairJob(
        deviceId: deviceId,
        description: f['desc']!,
        estimatedCost: double.tryParse(f['cost']!) ?? 0,
      );

      if (mounted) {
        setState(() { _dialogType = null; _dialogJob = null; });
        _refresh();
        showToast(context, 'Job created!');
      }
    })().catchError((e) {
      if (mounted) {
        showToast(context, 'Error: $e', type: ToastType.error);
      }
    });
  }

  /// Calls API to log a part against a job, then refreshes.
  void _logPart(Map<String, dynamic> p) {
    final session = AppSessionScope.of(context);
    final api = TechFixApi(
      baseUrl: session.baseUrl,
      email: session.email,
      password: session.password,
    );

    api.logPartUsage(
      jobId: p['jobId'] as int,
      partName: p['name'] as String,
      partCost: p['cost'] as double,
    ).then((_) {
      if (mounted) {
        setState(() { _dialogType = null; _dialogJob = null; });
        _refresh();
        showToast(context, 'Part logged!');
      }
    }).catchError((e) {
      if (mounted) {
        showToast(context, 'Error: $e', type: ToastType.error);
      }
    });
  }
}
