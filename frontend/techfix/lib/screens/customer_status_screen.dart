import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/shared/utils.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/avatar.dart';
import 'package:techfix/widgets/empty_state.dart';
import 'package:techfix/widgets/error_state.dart';
import 'package:techfix/widgets/loading_state.dart';
import 'package:techfix/widgets/pill.dart';
import 'package:techfix/widgets/toast.dart';
import 'package:techfix/widgets/section_header.dart';
import 'package:techfix/widgets/stat_card.dart';
import 'package:techfix/widgets/status_badge.dart';

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
  void dispose() {
    _customerIdController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedSessionData) return;
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

  Future<void> _cancelJob(int jobId) async {
    final session = AppSessionScope.of(context);
    try {
      await TechFixApi(
        baseUrl: session.baseUrl,
        email: session.email,
        password: session.password,
      ).cancelRepairJob(jobId);

      if (!mounted) return;
      showToast(context, 'Job cancelled successfully.');

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
      showToast(context, 'Cancel failed: $error', type: ToastType.error);
    }
  }

  String _asText(dynamic value, {String fallback = '\u2014'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _shortDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final y = dt.year.toString().substring(2);
    return '${months[dt.month - 1]} \'$y';
  }

  String _deviceLabel(Map<String, dynamic> device) {
    final brand = _asText(device['brand'], fallback: '');
    final model = _asText(device['model'], fallback: '');
    final type = _asText(device['type'], fallback: 'Device');
    final parts = [brand, model].where((part) => part.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' ') : type;
  }

  String _deviceIcon(Map<String, dynamic> device) {
    final type = _asText(device['type'], fallback: '').toLowerCase();
    if (type.contains('phone') || type.contains('mobile')) return 'smartphone';
    if (type.contains('laptop')) return 'laptop_mac';
    if (type.contains('tablet')) return 'tablet_mac';
    if (type.contains('watch')) return 'watch';
    if (type.contains('audio') || type.contains('headphone')) return 'headphones';
    if (type.contains('console')) return 'sports_esports';
    return 'devices_other';
  }

  IconData _deviceIconData(Map<String, dynamic> device) {
    final icon = _deviceIcon(device);
    switch (icon) {
      case 'smartphone': return Icons.smartphone;
      case 'laptop_mac': return Icons.laptop_mac;
      case 'tablet_mac': return Icons.tablet_mac;
      case 'watch': return Icons.watch;
      case 'headphones': return Icons.headphones;
      case 'sports_esports': return Icons.sports_esports;
      default: return Icons.devices_other;
    }
  }

  void _showDeviceJobsDialog(Map<String, dynamic> device, List<RepairJob> allJobs) {
    final deviceId = device['device_id'] as int;
    final deviceJobs = allJobs.where((job) => job.deviceId == deviceId).toList();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: const Color(0x6B141414),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, a1, a2) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 340, maxHeight: 500),
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
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppTheme.sky.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(_deviceIconData(device), size: 24, color: AppTheme.sky),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _deviceLabel(device),
                                    style: const TextStyle(
                                      
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.ink,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    '${deviceJobs.length} repair${deviceJobs.length != 1 ? 's' : ''} on record',
                                    style: const TextStyle(
                                      
                                      fontSize: 12.5,
                                      color: AppTheme.faint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: AppTheme.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            children: deviceJobs.map((job) {
                              final canCancel = job.status.toLowerCase() == 'pending';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 11),
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.line),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '#${job.id}',
                                          style: const TextStyle(
                                            
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.faint,
                                          ),
                                        ),
                                        StatusBadge(status: job.status, sm: true),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      job.description,
                                      style: const TextStyle(
                                        
                                        fontSize: 13.5,
                                        color: AppTheme.muted,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 11),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${(job.finalCost ?? job.estimatedCost).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.ink,
                                          ),
                                        ),
                                        if (canCancel)
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _cancelJob(job.id);
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppTheme.coral,
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.cancel, size: 16),
                                                SizedBox(width: 4),
                                                Text('Cancel', style: TextStyle(fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        if (job.status.toLowerCase() == 'ready')
                                          const Pill(
                                            color: AppTheme.teal,
                                            icon: Icons.storefront,
                                            child: Text('Ready for pickup'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
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

  void _signOut() => signOut(context);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          if (!_isCustomerRole) _buildSearchBar(),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My repairs',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Track your devices',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
        TextButton(onPressed: _signOut, child: const Text('Sign out')),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.line2),
                ),
                child: TextField(
                  controller: _customerIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Customer ID',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _loadCustomer,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.sky,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text('Load'),
            ),
          ],
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 12, color: AppTheme.coral),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (_customerFuture == null && !_isCustomerRole) {
      return const Text(
        'Load a customer to view their repair jobs.',
        style: TextStyle(fontSize: 14, color: AppTheme.faint),
      );
    }
    if (_customerFuture == null) return const SizedBox.shrink();

    return FutureBuilder<Map<String, dynamic>>(
      future: _customerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState(count: 3);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return ErrorState(
            title: 'Unable to load customer data',
            body: snapshot.error?.toString() ?? 'Unknown error',
            onRetry: () => setState(() {
              final session = AppSessionScope.of(context);
              if (_isCustomerRole) {
                _customerFuture = TechFixApi(
                  baseUrl: session.baseUrl,
                  email: session.email,
                  password: session.password,
                ).getCustomerMe();
              }
            }),
          );
        }

        final data = snapshot.data!;
        final customer = (data['customer'] as Map<String, dynamic>?) ?? data;
        final devices = (data['devices'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        final allJobs = (data['repair_jobs'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(RepairJob.fromApi)
                .toList() ??
            [];
        final customerName = _asText(customer['name'], fallback: 'Customer');
        final customerPhone = _asText(customer['phone']);
        final memberSince = _asText(customer['since'] ?? customer['created_at']);

        final activeJobs = allJobs
            .where((j) => j.status.toLowerCase() != 'cancelled' && j.status.toLowerCase() != 'delivered')
            .length;
        final readyCount = allJobs
            .where((j) => j.status.toLowerCase() == 'ready')
            .length;

        if (!_isCustomerRole && devices.isEmpty && allJobs.isEmpty) {
          return const EmptyState(
            icon: Icons.devices_other,
            title: 'No devices yet',
            body: 'When you drop off a device for repair, it\'ll show up here so you can track its progress.',
            color: AppTheme.sky,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(customerName, customerPhone, memberSince),
            const SizedBox(height: 16),
            _buildStats(activeJobs, readyCount),
            const SizedBox(height: 20),
            _buildDeviceSection(devices, allJobs),
          ],
        );
      },
    );
  }

  Widget _buildProfileCard(String name, String phone, String memberSince) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Avatar(name: name, size: 54, color: AppTheme.sky),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.call, size: 14, color: AppTheme.faint),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        phone,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Pill(
                color: AppTheme.teal,
                icon: Icons.verified,
                child: Text('Member'),
              ),
              if (memberSince.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    _shortDate(memberSince),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int activeJobs, int readyCount) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Active repairs',
            value: activeJobs.toString(),
            icon: Icons.build,
            accent: AppTheme.sky,
            sub: 'in the shop now',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Ready today',
            value: readyCount.toString(),
            icon: Icons.check_circle,
            accent: AppTheme.teal,
            sub: 'for pickup',
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSection(List<Map<String, dynamic>> devices, List<RepairJob> allJobs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Your devices',
          count: devices.length,
        ),
        const SizedBox(height: 12),
        if (devices.isEmpty)
          const EmptyState(
            icon: Icons.devices_other,
            title: 'No devices yet',
            body: 'When you drop off a device for repair, it\'ll show up here so you can track its progress.',
            color: AppTheme.sky,
          )
        else
          ...devices.map((device) {
            final deviceJobsForCard = allJobs.where((j) => j.deviceId == (device['device_id'] as int)).toList();
            final act = deviceJobsForCard.where((j) => j.status.toLowerCase() == 'pending' || j.status.toLowerCase() == 'repairing').firstOrNull;
            final rdy = deviceJobsForCard.where((j) => j.status.toLowerCase() == 'ready').firstOrNull;
            final lead = rdy ?? act ?? deviceJobsForCard.firstOrNull;

            return Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: GestureDetector(
                onTap: () => _showDeviceJobsDialog(device, allJobs),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppTheme.cream,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_deviceIconData(device), size: 24, color: AppTheme.ink),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _deviceLabel(device),
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ink,
                              ),
                            ),
                            Text(
                              '${deviceJobsForCard.length} repair${deviceJobsForCard.length != 1 ? 's' : ''} \u00b7 tap to view',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppTheme.faint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (lead != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: StatusBadge(status: lead.status, sm: true),
                        ),
                      const Icon(Icons.chevron_right, size: 22, color: AppTheme.faint),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
