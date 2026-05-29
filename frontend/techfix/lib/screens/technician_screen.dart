import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/job_card.dart';
import 'package:techfix/widgets/section_header.dart';
import 'package:techfix/widgets/stat_card.dart';

class TechnicianScreen extends StatefulWidget {
  const TechnicianScreen({super.key});

  @override
  State<TechnicianScreen> createState() => _TechnicianScreenState();
}

class _TechnicianScreenState extends State<TechnicianScreen> {
  late Future<List<RepairJob>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _loadJobs();
  }

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

  void _refresh() {
    setState(() {
      _jobsFuture = _loadJobs();
    });
  }

  void _signOut() {
    final session = AppSessionScope.of(context);
    session.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  /// Format text to readable display format
  String _asText(dynamic value, {String fallback = '—'}) {
    if (value == null) return fallback;
    final str = value.toString().trim();
    return str.isNotEmpty ? str : fallback;
  }

  /// Show employee profile dialog
  void _showProfileDialog(Map<String, dynamic> employee) {
    final name = _asText(employee['name'], fallback: 'Employee');
    final employeeId = _asText(employee['employee_id']);
    final email = _asText(employee['email']);
    final role = _asText(employee['role']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue[200],
                      child: Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _profileField('Employee ID', employeeId),
              const SizedBox(height: 16),
              _profileField('Email', email),
              const SizedBox(height: 16),
              _profileField('Role', role),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build a profile field with label and value
  Widget _profileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  /// Show statistics dialog
  void _showStatisticsDialog(List<RepairJob> jobs) {
    final total = jobs.length;
    final pending = jobs
        .where((j) => j.status.toLowerCase() == 'pending')
        .length;
    final repairing = jobs
        .where((j) => j.status.toLowerCase() == 'repairing')
        .length;
    final ready = jobs.where((j) => j.status.toLowerCase() == 'ready').length;
    final delivered = jobs
        .where((j) => j.status.toLowerCase() == 'delivered')
        .length;
    final cancelled = jobs
        .where((j) => j.status.toLowerCase() == 'cancelled')
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Statistics'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              StatCard(label: 'Total jobs', value: total.toString()),
              StatCard(label: 'Pending', value: pending.toString()),
              StatCard(label: 'Repairing', value: repairing.toString()),
              StatCard(label: 'Ready', value: ready.toString()),
              StatCard(label: 'Delivered', value: delivered.toString()),
              StatCard(label: 'Cancelled', value: cancelled.toString()),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to update repair job status
  void _showUpdateStatusDialog(RepairJob job) {
    final statuses = [
      'Pending',
      'Repairing',
      'Ready',
      'Delivered',
      'Cancelled',
    ];
    String selectedStatus = job.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Job Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Job #${job.id}: ${job.deviceLabel}'),
              const SizedBox(height: 20),
              const Text('New Status:'),
              const SizedBox(height: 8),
              ...statuses.map(
                (status) => RadioListTile<String>(
                  title: Text(status),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedStatus = value);
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final session = AppSessionScope.of(context);
                  final api = TechFixApi(
                    baseUrl: session.baseUrl,
                    email: session.email,
                    password: session.password,
                  );

                  await api.updateRepairJobStatus(
                    jobId: job.id,
                    status: selectedStatus,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                  _refresh();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Job updated to $selectedStatus!')),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to create a new repair job
  void _showCreateJobDialog() {
    final deviceIdController = TextEditingController();
    final descriptionController = TextEditingController();
    final estimatedCostController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Repair Job'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: deviceIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Device ID',
                      hintText: 'Enter device ID',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Device ID required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Must be a number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'What needs to be repaired?',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Description required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: estimatedCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Cost',
                      hintText: 'e.g., 500',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cost required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Must be a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setState(() => isSubmitting = true);

                      try {
                        final session = AppSessionScope.of(context);
                        final api = TechFixApi(
                          baseUrl: session.baseUrl,
                          email: session.email,
                          password: session.password,
                        );

                        final deviceId = int.parse(deviceIdController.text);
                        final description = descriptionController.text;
                        final estimatedCost = double.parse(
                          estimatedCostController.text,
                        );

                        await api.createRepairJob(
                          deviceId: deviceId,
                          description: description,
                          estimatedCost: estimatedCost,
                        );

                        if (!mounted) return;
                        Navigator.pop(context);
                        _refresh();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Job created!')),
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => isSubmitting = false);
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to log parts used on a repair job
  void _showLogPartDialog() {
    final jobIdController = TextEditingController();
    final partNameController = TextEditingController();
    final partCostController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Part Usage'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: jobIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Job ID',
                      hintText: 'Enter job ID',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Job ID required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Must be a number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: partNameController,
                    decoration: const InputDecoration(
                      labelText: 'Part Name',
                      hintText: 'e.g., RAM Stick 8GB',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Part name required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: partCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cost',
                      hintText: 'e.g., 2500',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cost required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Must be a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setState(() => isSubmitting = true);

                      try {
                        final session = AppSessionScope.of(context);
                        final api = TechFixApi(
                          baseUrl: session.baseUrl,
                          email: session.email,
                          password: session.password,
                        );

                        final jobId = int.parse(jobIdController.text);
                        final partName = partNameController.text;
                        final partCost = double.parse(partCostController.text);

                        await api.logPartUsage(
                          jobId: jobId,
                          partName: partName,
                          partCost: partCost,
                        );

                        if (!mounted) return;
                        Navigator.pop(context);
                        _refresh();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Part logged!')),
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => isSubmitting = false);
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Technician console',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(onPressed: _signOut, child: const Text('Sign out')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Prioritize the queue and log parts as you go.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(title: 'My Account'),
              Builder(
                builder: (context) {
                  final session = AppSessionScope.of(context);
                  final employee = session.employee ?? {};
                  return ElevatedButton.icon(
                    onPressed: () => _showProfileDialog(employee),
                    icon: const Icon(Icons.person_outline),
                    label: const Text('View Profile'),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showCreateJobDialog,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Create job'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showLogPartDialog,
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Log part'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(title: 'Your Statistics'),
              FutureBuilder<List<RepairJob>>(
                future: _jobsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ElevatedButton.icon(
                      onPressed: () => _showStatisticsDialog(snapshot.data!),
                      icon: const Icon(Icons.bar_chart_outlined),
                      label: const Text('View'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Open jobs',
            actionLabel: 'Refresh',
            onAction: _refresh,
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<RepairJob>>(
            future: _jobsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                final error = snapshot.error?.toString() ?? 'Unknown error';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unable to load jobs',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }

              final jobs = snapshot.data!
                  .where(
                    (job) =>
                        job.status.toLowerCase() == 'pending' ||
                        job.status.toLowerCase() == 'repairing',
                  )
                  .toList();

              if (jobs.isEmpty) {
                return Text(
                  'No open jobs right now.',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }

              return Column(
                children: jobs
                    .map(
                      (job) => JobCard(
                        job: job,
                        onTap: () => _showUpdateStatusDialog(job),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
