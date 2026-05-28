import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/section_header.dart';
import 'package:techfix/widgets/stat_card.dart';

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
          SectionHeader(
            title: 'Live stats',
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
                return Text(
                  'Unable to load dashboard data.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                );
              }

              final jobs = snapshot.data!;
              final ready = jobs
                  .where((job) => job.status.toLowerCase() == 'ready')
                  .length;
              final active = jobs
                  .where(
                    (job) =>
                        job.status.toLowerCase() == 'pending' ||
                        job.status.toLowerCase() == 'repairing',
                  )
                  .length;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  StatCard(label: 'Active jobs', value: active.toString()),
                  StatCard(label: 'Ready for pickup', value: ready.toString()),
                  StatCard(label: 'Total jobs', value: jobs.length.toString()),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Inventory usage'),
          const SizedBox(height: 12),
          Text(
            'Inventory usage feeds are not available yet.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
