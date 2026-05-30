import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/section_header.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  late Future<List<RepairJob>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    // Don't load data here - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to access AppSessionScope here, after InheritedWidget is built
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

  /// Show dialog to add a new employee
  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Employee'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'e.g., John Doe',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'john@example.com',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Temporary password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password required';
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

                        await api.createEmployee(
                          name: nameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        if (!mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Employee added!')),
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
              child: const Text('Add'),
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
                'Manager overview',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(onPressed: _signOut, child: const Text('Sign out')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Track throughput, margins, and parts usage in one place.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Employee Management
          ElevatedButton.icon(
            onPressed: _showAddEmployeeDialog,
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Add staff'),
          ),
          const SizedBox(height: 24),

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
                      'Unable to load dashboard data',
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

              final jobs = snapshot.data!;
              final pending = jobs
                  .where((job) => job.status.toLowerCase() == 'pending')
                  .length;
              final repairing = jobs
                  .where((job) => job.status.toLowerCase() == 'repairing')
                  .length;
              final ready = jobs
                  .where((job) => job.status.toLowerCase() == 'ready')
                  .length;
              final delivered = jobs
                  .where((job) => job.status.toLowerCase() == 'delivered')
                  .length;
              final cancelled = jobs
                  .where((job) => job.status.toLowerCase() == 'cancelled')
                  .length;

              final totalEstimated = jobs.fold<double>(
                0,
                (sum, job) => sum + job.estimatedCost,
              );
              final totalFinal = jobs.fold<double>(
                0,
                (sum, job) => sum + (job.finalCost ?? 0),
              );

              return Column(
                children: [
                  // Cost Overview
                  SectionHeader(
                    title: 'Revenue overview',
                    actionLabel: 'Refresh',
                    onAction: _refresh,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Estimated',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '\$${totalEstimated.toStringAsFixed(0)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total Finalized',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '\$${totalFinal.toStringAsFixed(0)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[700],
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  if (pending > 0)
                                    PieChartSectionData(
                                      value: pending.toDouble(),
                                      title: 'Pending\n$pending',
                                      color: Colors.orange,
                                      radius: 60,
                                    ),
                                  if (repairing > 0)
                                    PieChartSectionData(
                                      value: repairing.toDouble(),
                                      title: 'Repairing\n$repairing',
                                      color: Colors.blue,
                                      radius: 60,
                                    ),
                                  if (ready > 0)
                                    PieChartSectionData(
                                      value: ready.toDouble(),
                                      title: 'Ready\n$ready',
                                      color: Colors.green,
                                      radius: 60,
                                    ),
                                  if (delivered > 0)
                                    PieChartSectionData(
                                      value: delivered.toDouble(),
                                      title: 'Done\n$delivered',
                                      color: Colors.grey,
                                      radius: 60,
                                    ),
                                  if (cancelled > 0)
                                    PieChartSectionData(
                                      value: cancelled.toDouble(),
                                      title: 'Cancelled\n$cancelled',
                                      color: Colors.red,
                                      radius: 60,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
