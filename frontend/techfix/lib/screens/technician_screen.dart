import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/job_card.dart';
import 'package:techfix/models/inventory_usage.dart';
import 'package:techfix/widgets/section_header.dart';

class TechnicianScreen extends StatefulWidget {
  const TechnicianScreen({super.key});

  @override
  State<TechnicianScreen> createState() => _TechnicianScreenState();
}

class _TechnicianScreenState extends State<TechnicianScreen> {
  late Future<List<RepairJob>> _jobsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  static const int _displayLimit = 5;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  /// Fetch inventory usage grouped by job id for the provided jobs.
  Future<Map<int, List<InventoryUsage>>> _fetchUsagesForJobs(
    List<RepairJob> jobs,
  ) async {
    final session = AppSessionScope.of(context);
    final api = TechFixApi(
      baseUrl: session.baseUrl,
      email: session.email,
      password: session.password,
    );

    final Map<int, List<InventoryUsage>> map = {};
    final customerIds = jobs.map((j) => j.customerId).toSet();

    for (final cid in customerIds) {
      try {
        final detail = await api.getCustomerDetail(cid);
        final List<dynamic> usages =
            (detail['inventory_usage'] ?? []) as List<dynamic>;
        for (final u in usages) {
          final inv = InventoryUsage.fromApi(u as Map<String, dynamic>);
          map.putIfAbsent(inv.jobId, () => []).add(inv);
        }
      } catch (_) {
        // ignore failures for individual customers
      }
    }

    return map;
  }

  void _refresh() {
    setState(() {
      _jobsFuture = _loadJobs();
    });
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
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

  /// Show dialog to edit the job description
  void _showEditDescriptionDialog(RepairJob job) {
    String description = job.description;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit description - Job #${job.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: description,
                maxLines: 4,
                onChanged: (v) => setState(() => description = v),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
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

                  await api.updateJobDescription(
                    jobId: job.id,
                    description: description.trim(),
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                  _refresh();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Description updated')),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to create a new repair job
  void _showCreateJobDialog() {
    final descriptionController = TextEditingController();
    final estimatedCostController = TextEditingController();
    final customerEmailController = TextEditingController();
    final customerNameController = TextEditingController();
    final customerPhoneController = TextEditingController();
    final deviceBrandController = TextEditingController();
    final deviceModelController = TextEditingController();
    final deviceSerialController = TextEditingController();
    String? deviceTypeValue;
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
                  // (Device ID field removed — device will be created automatically)
                  // Customer contact - will create customer if not exist
                  TextFormField(
                    controller: customerEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Customer email *',
                      hintText: 'customer@example.com',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Customer email required';
                      }
                      if (!RegExp(
                        r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
                      ).hasMatch(value)) {
                        return 'Must be a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer name *',
                      hintText: 'Full name (required)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Name required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: customerPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Customer phone *',
                      hintText: 'e.g., 03001234567',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Phone required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Device fields - will be created automatically
                  DropdownButtonFormField<String>(
                    value: deviceTypeValue,
                    items: ['Laptop', 'Mobile', 'Console', 'Tablet', 'Other']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => deviceTypeValue = v),
                    decoration: const InputDecoration(
                      labelText: 'Device type *',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Type required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: deviceBrandController,
                    decoration: const InputDecoration(
                      labelText: 'Brand *',
                      hintText: 'e.g., Samsung',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Brand required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: deviceModelController,
                    decoration: const InputDecoration(
                      labelText: 'Model *',
                      hintText: 'e.g., Galaxy S20',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Model required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: deviceSerialController,
                    decoration: const InputDecoration(
                      labelText: 'Serial number *',
                      hintText: 'Device serial number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Serial required';
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

                        final email = customerEmailController.text.trim();
                        final name = customerNameController.text.trim();
                        final phone = customerPhoneController.text.trim();
                        final deviceType = deviceTypeValue ?? 'Other';
                        final brand = deviceBrandController.text.trim();
                        final model = deviceModelController.text.trim();
                        final serial = deviceSerialController.text.trim();
                        final description = descriptionController.text;
                        final estimatedCost = double.parse(
                          estimatedCostController.text,
                        );

                        // Create customer
                        final customerId = await api.createCustomer(
                          name: name.isEmpty ? email.split('@').first : name,
                          phone: phone.isEmpty ? '0000000000' : phone,
                          email: email,
                        );

                        // Create device for customer
                        final deviceId = await api.createDevice(
                          customerId: customerId,
                          type: deviceType,
                          brand: brand,
                          model: model,
                          serialNumber: serial,
                        );

                        // Create repair job
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
          SectionHeader(
            title: 'Open jobs',
            actionLabel: 'Refresh',
            onAction: _refresh,
          ),
          const SizedBox(height: 12),
          // Search field for jobs (executes only when search button clicked)
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search jobs by device, customer, id, or status',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _performSearch,
                  ),
                ],
              ),
            ),
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

              final session = AppSessionScope.of(context);
              final role = (session.employee?['role'] ?? '').toString();

              // Start from all jobs sorted by createdAt desc
              final allJobs = snapshot.data!.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

              // Owners and managers should see all jobs; technicians see active queue
              final filteredByRole = (role == 'Owner' || role == 'Manager')
                  ? allJobs
                  : allJobs
                        .where(
                          (job) =>
                              job.status.toLowerCase() == 'pending' ||
                              job.status.toLowerCase() == 'repairing',
                        )
                        .toList();

              // Apply search filter if present. Run only when user hits search.
              final queryRaw = _searchQuery.trim();
              final q = queryRaw.toLowerCase();
              late final List<RepairJob> searched;

              if (q.isEmpty) {
                searched = filteredByRole;
              } else {
                // If the user entered a numeric id, prefer exact id match
                int? id;
                try {
                  id = int.parse(q);
                } catch (_) {
                  id = null;
                }

                if (id != null) {
                  searched = filteredByRole
                      .where((job) => job.id == id)
                      .toList();
                } else {
                  // Try exact field matches first (device label, customer name, status)
                  final exact = filteredByRole.where((job) {
                    return job.deviceLabel.toLowerCase() == q ||
                        job.customerName.toLowerCase() == q ||
                        job.status.toLowerCase() == q;
                  }).toList();

                  if (exact.isNotEmpty) {
                    searched = exact;
                  } else {
                    // Fallback to substring contains matching
                    searched = filteredByRole.where((job) {
                      final combined =
                          ('${job.deviceLabel} ${job.customerName} ${job.id} ${job.status}')
                              .toLowerCase();
                      return combined.contains(q);
                    }).toList();
                  }
                }
              }

              final totalCount = searched.length;
              final displayedJobs = searched.take(_displayLimit).toList();

              if (totalCount == 0) {
                return Text(
                  'No open jobs right now.',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }

              final usagesFuture = _fetchUsagesForJobs(displayedJobs);

              return FutureBuilder<Map<int, List<InventoryUsage>>>(
                future: usagesFuture,
                builder: (context, usagesSnap) {
                  final usagesMap = usagesSnap.data ?? {};
                  return Column(
                    children: [
                      ...displayedJobs.map((job) {
                        final usages = usagesMap[job.id] ?? [];
                        return JobCard(
                          job: job,
                          onTap: () => _showUpdateStatusDialog(job),
                          onEdit: () => _showEditDescriptionDialog(job),
                          usages: usages,
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      Text(
                        'Showing ${displayedJobs.length} of $totalCount jobs',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
