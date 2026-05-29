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
  bool _initializedSessionData = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initializedSessionData) {
      return;
    }
    _initializedSessionData = true;

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

  /// Show repairs for a specific device
  void _showDeviceRepairs(
    Map<String, dynamic> device,
    List<RepairJob> jobs,
    Map<int, String> deviceLabelById,
    String customerName,
  ) {
    final deviceId = device['device_id'] as int;
    final deviceLabel = _deviceLabel(device);
    final deviceJobs = jobs.where((job) => job.deviceId == deviceId).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Device Repairs'),
            const SizedBox(height: 4),
            Text(
              deviceLabel,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (deviceJobs.isEmpty)
                Text(
                  'No repairs for this device.',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                ...deviceJobs.map(
                  (job) => JobCard(
                    job: job,
                    customerNameOverride: customerName,
                    deviceLabelOverride: deviceLabel,
                    onCancel: job.status.toLowerCase() == 'pending'
                        ? () {
                            Navigator.pop(context);
                            _cancelJob(job.id);
                          }
                        : null,
                  ),
                ),
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

  Future<void> _cancelJob(int jobId) async {
    final session = AppSessionScope.of(context);

    try {
      await TechFixApi(
        baseUrl: session.baseUrl,
        email: session.email,
        password: session.password,
      ).cancelRepairJob(jobId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job cancelled successfully.')),
      );

      setState(() {
        if (_isCustomerRole) {
          _customerFuture = TechFixApi(
            baseUrl: session.baseUrl,
            email: session.email,
            password: session.password,
          ).getCustomerMe();
        } else if (_customerIdController.text.trim().isNotEmpty) {
          _customerFuture = TechFixApi(
            baseUrl: session.baseUrl,
            email: session.email,
            password: session.password,
          ).getCustomerDetail(int.parse(_customerIdController.text.trim()));
        }
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cancel failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _asText(dynamic value, {String fallback = '—'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _deviceLabel(Map<String, dynamic> device) {
    final brand = _asText(device['brand'], fallback: '');
    final model = _asText(device['model'], fallback: '');
    final type = _asText(device['type'], fallback: 'Device');
    final parts = [brand, model].where((part) => part.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' ') : type;
  }

  /// Format date to user-friendly format (e.g., "May 15, 2026")
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '—';
    try {
      final datetime = DateTime.parse(dateValue.toString());
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[datetime.month - 1]} ${datetime.day}, ${datetime.year}';
    } catch (_) {
      return dateValue.toString();
    }
  }

  /// Show profile dialog
  void _showProfileDialog(Map<String, dynamic> customer) {
    final customerName = _asText(customer['name'], fallback: 'Customer');
    final customerPhone = _asText(customer['phone']);
    final customerEmail = _asText(customer['email']);
    final joined = _formatDate(customer['created_at']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer name header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue[200],
                      child: Text(
                        customerName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      customerName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Contact info
              _profileField('Email', customerEmail),
              const SizedBox(height: 16),
              _profileField('Phone', customerPhone),
              const SizedBox(height: 16),
              _profileField('Customer ID', _asText(customer['customer_id'])),
              const SizedBox(height: 16),
              _profileField('Member Since', joined),
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
                final customer =
                    (data['customer'] as Map<String, dynamic>?) ?? data;
                final devices =
                    (data['devices'] as List<dynamic>?)
                        ?.cast<Map<String, dynamic>>() ??
                    [];
                final jobs =
                    (data['repair_jobs'] as List<dynamic>?)
                        ?.cast<Map<String, dynamic>>()
                        .map(RepairJob.fromApi)
                        .toList() ??
                    [];
                final deviceLabelById = {
                  for (final device in devices)
                    (device['device_id'] as int): _deviceLabel(device),
                };
                final customerName = _asText(
                  customer['name'],
                  fallback: 'Customer',
                );
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
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionHeader(title: 'My Account'),
                        ElevatedButton.icon(
                          onPressed: () => _showProfileDialog(customer),
                          icon: const Icon(Icons.person_outline),
                          label: const Text('View Profile'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'My Devices'),
                    const SizedBox(height: 12),
                    if (devices.isEmpty)
                      Text(
                        'No devices found for this customer.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: devices
                            .map(
                              (device) => ActionChip(
                                label: Text(_deviceLabel(device)),
                                avatar: const Icon(Icons.devices_outlined),
                                onPressed: () => _showDeviceRepairs(
                                  device,
                                  jobs,
                                  deviceLabelById,
                                  customerName,
                                ),
                              ),
                            )
                            .toList(),
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
                      ...jobs.map(
                        (job) => JobCard(
                          job: job,
                          customerNameOverride: customerName,
                          deviceLabelOverride:
                              deviceLabelById[job.deviceId] ?? job.deviceLabel,
                          onCancel: job.status.toLowerCase() == 'pending'
                              ? () => _cancelJob(job.id)
                              : null,
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
