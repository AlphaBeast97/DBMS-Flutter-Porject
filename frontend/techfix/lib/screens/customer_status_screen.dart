import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/job_card.dart';
import 'package:techfix/widgets/section_header.dart';
import 'package:techfix/widgets/stat_card.dart';

class CustomerStatusScreen extends StatefulWidget {
  const CustomerStatusScreen({super.key});

  @override
  State<CustomerStatusScreen> createState() => _CustomerStatusScreenState();
}

class _CustomerStatusScreenState extends State<CustomerStatusScreen> {
  final _customerIdController = TextEditingController();
  Future<Map<String, dynamic>>? _customerFuture;
  String? _errorMessage;
  bool _isCustomerRole = false;

  @override
  void initState() {
    super.initState();
    // Check if logged-in user is a customer; if so, auto-load their data
    _checkAndLoadCustomerData();
  }

  /// Check if user is a customer and auto-load their data
  void _checkAndLoadCustomerData() {
    final session = AppSessionScope.of(context);
    final employee = session.employee;

    if (employee == null) return;

    final role = (employee['role'] as String?)?.trim() ?? '';
    if (role.toLowerCase() == 'customer') {
      setState(() {
        _isCustomerRole = true;
        _customerFuture = Future.value(employee);
      });
    }
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    super.dispose();
  }

  void _loadCustomer() {
    final session = AppSessionScope.of(context);
    final id = int.tryParse(_customerIdController.text.trim());

    if (id == null || id <= 0) {
      setState(() {
        _errorMessage = 'Enter a valid customer ID.';
        _customerFuture = null;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _customerFuture = TechFixApi(
        baseUrl: session.baseUrl,
        email: session.email,
        password: session.password,
      ).getCustomerDetail(id);
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
                'Track your repair',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(onPressed: _signOut, child: const Text('Sign out')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isCustomerRole
                ? 'Here is your current repair status.'
                : 'Search by customer ID to see live status updates.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Only show search if user is NOT a customer
          if (!_isCustomerRole) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customerIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Customer ID',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loadCustomer,
                  child: const Text('Load'),
                ),
              ],
            ),
          ],

          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: 24),
          if (_customerFuture == null && !_isCustomerRole)
            Text(
              'Load a customer to view their repair jobs.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else if (_customerFuture != null)
            FutureBuilder<Map<String, dynamic>>(
              future: _customerFuture,
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
                        'Unable to load customer data',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.redAccent,
                        ),
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

                final data = snapshot.data!;
                final jobs =
                    (data['repair_jobs'] as List<dynamic>?)
                        ?.cast<Map<String, dynamic>>()
                        .map(RepairJob.fromApi)
                        .toList() ??
                    [];
                final activeJobs = jobs
                    .where(
                      (job) =>
                          job.status.toLowerCase() != 'cancelled' &&
                          job.status.toLowerCase() != 'delivered',
                    )
                    .length;
                final readyJobs = jobs
                    .where((job) => job.status.toLowerCase() == 'ready')
                    .length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Snapshot'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        StatCard(
                          label: 'Active jobs',
                          value: activeJobs.toString(),
                        ),
                        StatCard(
                          label: 'Ready today',
                          value: readyJobs.toString(),
                        ),
                        const StatCard(label: 'Average ETA', value: '—'),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const SectionHeader(title: 'Latest updates'),
                    const SizedBox(height: 12),
                    if (jobs.isEmpty)
                      Text(
                        'No repair jobs found for this customer.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      ...jobs.map((job) => JobCard(job: job)),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
