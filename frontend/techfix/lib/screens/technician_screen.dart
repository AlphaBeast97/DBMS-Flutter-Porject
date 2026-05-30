import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/avatar.dart';
import 'package:techfix/widgets/empty_state.dart';
import 'package:techfix/widgets/error_state.dart';
import 'package:techfix/widgets/field.dart';
import 'package:techfix/widgets/job_card.dart';
import 'package:techfix/widgets/loading_state.dart';
import 'package:techfix/models/inventory_usage.dart';
import 'package:techfix/widgets/sheet.dart';
import 'package:techfix/widgets/toast.dart';

// ─────────────────────────────────────────────────────────────
// StatusRadioDialog — styled radio selection for status
// ─────────────────────────────────────────────────────────────
class StatusRadioDialog extends StatefulWidget {
  final RepairJob job;
  final VoidCallback onClose;
  final ValueChanged<String> onSave;

  const StatusRadioDialog({
    super.key,
    required this.job,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<StatusRadioDialog> createState() => _StatusRadioDialogState();
}

class _StatusRadioDialogState extends State<StatusRadioDialog> {
  late String _val;

  @override
  void initState() {
    super.initState();
    _val = widget.job.status.toLowerCase();
  }

  static const _order = ['pending', 'repairing', 'ready', 'delivered', 'cancelled'];

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
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.sky.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.cached, size: 26, color: AppTheme.sky),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Update status',
                          style: TextStyle(
                            
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '${widget.job.deviceLabel} \u00b7 #${widget.job.id}',
                          style: const TextStyle(
                            
                            fontSize: 13,
                            color: AppTheme.muted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ..._order.map((st) {
                          final active = _val == st;
                          final sColor = AppTheme.statusColor(st);
                          final sBg = AppTheme.statusBg(st);
                          final sIcon = AppTheme.statusIcon(st);
                          final sLabel = AppTheme.statusLabel(st);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _val = st),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                                decoration: BoxDecoration(
                                  color: active ? sBg : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: active ? sColor : AppTheme.line,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(sIcon, size: 20, color: sColor),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        sLabel,
                                        style: const TextStyle(
                                          
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.ink,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      active ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      size: 20,
                                      color: active ? sColor : AppTheme.faint,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: widget.onClose,
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () => widget.onSave(_val),
                              style: FilledButton.styleFrom(backgroundColor: AppTheme.sky),
                              child: const Text('Save'),
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
// EditDescDialog — edit description + cost
// ─────────────────────────────────────────────────────────────
class EditDescDialog extends StatefulWidget {
  final RepairJob job;
  final VoidCallback onClose;
  final ValueChanged<Map<String, dynamic>> onSave;

  const EditDescDialog({
    super.key,
    required this.job,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<EditDescDialog> createState() => _EditDescDialogState();
}

class _EditDescDialogState extends State<EditDescDialog> {
  late String _desc;
  late String _cost;

  @override
  void initState() {
    super.initState();
    _desc = widget.job.description;
    _cost = widget.job.estimatedCost.toStringAsFixed(2);
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
                constraints: const BoxConstraints(maxWidth: 340, maxHeight: 400),
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
                            color: AppTheme.ink.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.edit, size: 26, color: AppTheme.ink),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Edit job',
                          style: TextStyle(
                            
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Field(
                          label: 'Description',
                          value: _desc,
                          onChanged: (v) => setState(() => _desc = v),
                          multiline: true,
                          rows: 4,
                          autoFocus: true,
                        ),
                        const SizedBox(height: 12),
                        Field(
                          label: 'Estimated cost',
                          value: _cost,
                          onChanged: (v) => setState(() => _cost = v),
                          icon: Icons.payments,
                          suffix: const Text(
                            'USD',
                            style: TextStyle(
                              
                              fontSize: 14,
                              color: AppTheme.faint,
                            ),
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
                              onPressed: () => widget.onSave({
                                'description': _desc,
                                'cost': double.tryParse(_cost) ?? 0,
                              }),
                              child: const Text('Save'),
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
// Device type chips
// ─────────────────────────────────────────────────────────────
const _deviceTypes = [
  ('Phone', Icons.smartphone),
  ('Laptop', Icons.laptop_mac),
  ('Tablet', Icons.tablet_mac),
  ('Watch', Icons.watch),
  ('Audio', Icons.headphones),
  ('Other', Icons.devices_other),
];

// ─────────────────────────────────────────────────────────────
// CreateJobSheet — multi-step (Customer → Device → Issue)
// ─────────────────────────────────────────────────────────────
class CreateJobSheet extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<Map<String, String>> onCreate;

  const CreateJobSheet({
    super.key,
    required this.onClose,
    required this.onCreate,
  });

  @override
  State<CreateJobSheet> createState() => _CreateJobSheetState();
}

class _CreateJobSheetState extends State<CreateJobSheet> {
  int _step = 0;
  final _f = <String, String>{
    'cEmail': '', 'cName': '', 'cPhone': '',
    'dType': 'Phone', 'dIcon': 'smartphone',
    'brand': '', 'model': '', 'serial': '',
    'desc': '', 'cost': '',
  };

  void _set(String k, String v) => setState(() => _f[k] = v);

  bool get _valid {
    if (_step == 0) return _f['cEmail']!.isNotEmpty && _f['cName']!.isNotEmpty;
    if (_step == 1) return _f['brand']!.isNotEmpty && _f['model']!.isNotEmpty;
    return _f['desc']!.isNotEmpty && _f['cost']!.isNotEmpty && double.tryParse(_f['cost']!) != null;
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      widget.onCreate(_f);
    }
  }

  static const _steps = ['Customer', 'Device', 'Issue'];

  @override
  Widget build(BuildContext context) {
    return Sheet(
      title: 'New repair job',
      subtitle: 'Creates customer \u2192 device \u2192 job',
      onClose: widget.onClose,
      actions: [
        if (_step > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _step--),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.ink,
                side: const BorderSide(color: AppTheme.ink),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_step > 0) const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _valid ? _next : null,
            icon: Icon(_step == 2 ? Icons.check : Icons.arrow_forward),
            label: Text(_step == 2 ? 'Create job' : 'Continue'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.coral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stepper
          Row(
            children: List.generate(_steps.length, (i) {
              final active = i <= _step;
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 4,
                      decoration: BoxDecoration(
                        color: active ? AppTheme.coral : AppTheme.line2,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${i + 1}. ${_steps[i]}',
                      style: TextStyle(
                        
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: active ? AppTheme.ink : AppTheme.faint,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 18),

          // Step 0: Customer
          if (_step == 0)
            ..._buildCustomerStep(),

          // Step 1: Device
          if (_step == 1)
            ..._buildDeviceStep(),

          // Step 2: Issue
          if (_step == 2)
            ..._buildIssueStep(),
        ],
      ),
    );
  }

  List<Widget> _buildCustomerStep() => [
    Field(
      label: 'Customer email',
      icon: Icons.mail,
      value: _f['cEmail'],
      onChanged: (v) => _set('cEmail', v),
      keyboardType: TextInputType.emailAddress,
      autoFocus: true,
    ),
    const SizedBox(height: 12),
    Field(
      label: 'Customer name',
      icon: Icons.person,
      value: _f['cName'],
      onChanged: (v) => _set('cName', v),
    ),
    const SizedBox(height: 12),
    Field(
      label: 'Phone',
      icon: Icons.call,
      value: _f['cPhone'],
      onChanged: (v) => _set('cPhone', v),
      keyboardType: TextInputType.phone,
    ),
    const SizedBox(height: 12),
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.sky.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, size: 17, color: AppTheme.sky),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Existing customers are matched by email automatically.',
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
  ];

  List<Widget> _buildDeviceStep() => [
    const Text(
      'Device type',
      style: TextStyle(
        
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.muted,
      ),
    ),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _deviceTypes.map((d) {
        final active = _f['dType'] == d.$1;
        return GestureDetector(
          onTap: () => setState(() {
            _f['dType'] = d.$1;
            final iconMap = {'Phone': 'smartphone', 'Laptop': 'laptop_mac', 'Tablet': 'tablet_mac', 'Watch': 'watch', 'Audio': 'headphones', 'Other': 'devices_other'};
            _f['dIcon'] = iconMap[d.$1] ?? 'devices_other';
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: active ? AppTheme.teal.withOpacity(0.14) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppTheme.teal : AppTheme.line2,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(d.$2, size: 17, color: active ? AppTheme.teal : AppTheme.muted),
                const SizedBox(width: 7),
                Text(
                  d.$1,
                  style: TextStyle(
                    
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: active ? AppTheme.teal : AppTheme.ink,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
    const SizedBox(height: 14),
    Field(
      label: 'Brand',
      icon: Icons.sell,
      value: _f['brand'],
      onChanged: (v) => _set('brand', v),
    ),
    const SizedBox(height: 12),
    Field(
      label: 'Model',
      icon: Icons.devices,
      value: _f['model'],
      onChanged: (v) => _set('model', v),
    ),
    const SizedBox(height: 12),
    Field(
      label: 'Serial / IMEI',
      icon: Icons.qr_code_2,
      value: _f['serial'],
      onChanged: (v) => _set('serial', v),
    ),
  ];

  List<Widget> _buildIssueStep() => [
    Field(
      label: 'Issue description',
      value: _f['desc'],
      onChanged: (v) => _set('desc', v),
      multiline: true,
      rows: 4,
      autoFocus: true,
      placeholder: "What's wrong with the device?",
    ),
    const SizedBox(height: 12),
    Field(
      label: 'Estimated cost',
      icon: Icons.payments,
      value: _f['cost'],
      onChanged: (v) => _set('cost', v),
      keyboardType: TextInputType.number,
      suffix: const Text(
        'USD',
        style: TextStyle(
          
          fontSize: 14,
          color: AppTheme.faint,
        ),
      ),
    ),
    const SizedBox(height: 12),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUMMARY',
            style: TextStyle(
              
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.faint,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Avatar(
                name: _f['cName']!.isNotEmpty ? _f['cName']! : '?',
                size: 36,
                color: AppTheme.sky,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _f['cName']!.isNotEmpty ? _f['cName']! : 'New customer',
                      style: const TextStyle(
                        
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                    ),
                    Text(
                      '${_f['dType']} \u00b7 ${_f['brand']!.isNotEmpty ? _f['brand'] : '\u2014'} ${_f['model']}',
                      style: const TextStyle(
                        
                        fontSize: 12,
                        color: AppTheme.faint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────
// LogPartSheet — job radio selector + part fields
// ─────────────────────────────────────────────────────────────
class LogPartSheet extends StatefulWidget {
  final List<RepairJob> jobs;
  final VoidCallback onClose;
  final ValueChanged<Map<String, dynamic>> onLog;

  const LogPartSheet({
    super.key,
    required this.jobs,
    required this.onClose,
    required this.onLog,
  });

  @override
  State<LogPartSheet> createState() => _LogPartSheetState();
}

class _LogPartSheetState extends State<LogPartSheet> {
  int? _jobId;
  final _nameCtl = TextEditingController();
  final _costCtl = TextEditingController();

  bool get _valid => _jobId != null && _nameCtl.text.isNotEmpty && double.tryParse(_costCtl.text) != null;

  @override
  void initState() {
    super.initState();
    if (widget.jobs.isNotEmpty) _jobId = widget.jobs.first.id;
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _costCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sheet(
      title: 'Log a part',
      subtitle: 'Record inventory used on a job',
      onClose: widget.onClose,
      actions: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _valid
                ? () => widget.onLog({
                      'jobId': _jobId!,
                      'name': _nameCtl.text,
                      'cost': double.tryParse(_costCtl.text) ?? 0,
                    })
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Log part'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.clay,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assign to job',
            style: TextStyle(
              
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.jobs.map((j) {
            final active = _jobId == j.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _jobId = j.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.clay.withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: active ? AppTheme.clay : AppTheme.line,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.smartphone, size: 20, color: AppTheme.ink),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              j.deviceLabel,
                              style: const TextStyle(
                                
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.ink,
                              ),
                            ),
                            Text(
                              '#${j.id} \u00b7 ${j.customerName}',
                              style: const TextStyle(
                                
                                fontSize: 12,
                                color: AppTheme.faint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        active ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        size: 20,
                        color: active ? AppTheme.clay : AppTheme.faint,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          Field(
            label: 'Part name',
            icon: Icons.memory,
            value: _nameCtl.text,
            onChanged: (v) { _nameCtl.text = v; setState(() {}); },
            placeholder: 'e.g. AMOLED display assembly',
          ),
          const SizedBox(height: 12),
          Field(
            label: 'Part cost',
            icon: Icons.payments,
            value: _costCtl.text,
            onChanged: (v) { _costCtl.text = v; setState(() {}); },
            keyboardType: TextInputType.number,
            suffix: const Text(
              'USD',
              style: TextStyle(
                
                fontSize: 14,
                color: AppTheme.faint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TechnicianScreen — main screen
// ─────────────────────────────────────────────────────────────
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

  // Stores which dialog/sheet is open: type + optional job
  String? _dialogType;
  RepairJob? _dialogJob;

  @override
  void initState() {
    super.initState();
  }

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

  Future<Map<int, List<InventoryUsage>>> _fetchUsagesForJobs(List<RepairJob> jobs) async {
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
        final usages = (detail['inventory_usage'] ?? []) as List<dynamic>;
        for (final u in usages) {
          final inv = InventoryUsage.fromApi(u as Map<String, dynamic>);
          map.putIfAbsent(inv.jobId, () => []).add(inv);
        }
      } catch (_) {}
    }
    return map;
  }

  void _refresh() {
    _jobsFuture = _loadJobs();
    setState(() {});
  }

  void _performSearch() => setState(() => _searchQuery = _searchController.text.trim());

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

        // Dialogs & Sheets
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

  Widget _buildBody() {
    return FutureBuilder<List<RepairJob>>(
      future: _jobsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(18, 4, 18, 0),
            child: LoadingState(count: 3),
          );
        }

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
        // Technicians see only pending/repairing
        final activeJobs = allJobs
            .where((j) => j.status.toLowerCase() == 'pending' || j.status.toLowerCase() == 'repairing')
            .toList();

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

        // Apply filter
        var filtered = activeJobs;
        if (_filter == 'pending') {
          filtered = filtered.where((j) => j.status.toLowerCase() == 'pending').toList();
        } else if (_filter == 'repairing') {
          filtered = filtered.where((j) => j.status.toLowerCase() == 'repairing').toList();
        }

        // Apply search
        final q = _searchQuery.toLowerCase();
        if (q.isNotEmpty) {
          filtered = filtered.where((j) {
            return j.deviceLabel.toLowerCase().contains(q) ||
                j.customerName.toLowerCase().contains(q) ||
                j.id.toString().contains(q) ||
                j.status.toLowerCase().contains(q);
          }).toList();
        }

        // Sort by newest first
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final pendingCount = activeJobs.where((j) => j.status.toLowerCase() == 'pending').length;
        final repairingCount = activeJobs.where((j) => j.status.toLowerCase() == 'repairing').length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
          children: [
            // Search
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

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    count: activeJobs.length,
                    active: _filter == 'all',
                    color: AppTheme.ink,
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pending',
                    count: pendingCount,
                    active: _filter == 'pending',
                    color: AppTheme.clay,
                    onTap: () => setState(() => _filter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
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
              // Fetch usages and render job cards
              FutureBuilder<Map<int, List<InventoryUsage>>>(
                future: _fetchUsagesForJobs(filtered),
                builder: (context, usagesSnap) {
                  final usagesMap = usagesSnap.data ?? {};
                  return Column(
                    children: filtered.map((job) {
                      final usages = usagesMap[job.id] ?? [];
                      return JobCard(
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

  void _createJob(Map<String, String> f) {
    final session = AppSessionScope.of(context);
    final api = TechFixApi(
      baseUrl: session.baseUrl,
      email: session.email,
      password: session.password,
    );

    (() async {
      final email = f['cEmail']!;
      final name = f['cName']!;
      final phone = f['cPhone']!.isNotEmpty ? f['cPhone']! : '0000000000';
      final customerId = await api.createCustomer(name: name, phone: phone, email: email);

      final deviceId = await api.createDevice(
        customerId: customerId,
        type: f['dType']!,
        brand: f['brand']!,
        model: f['model']!,
        serialNumber: f['serial']!.isNotEmpty ? f['serial']! : 'N/A',
      );

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

// ─────────────────────────────────────────────────────────────
// _FilterChip
// ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.14) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color : AppTheme.line2,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: active ? color : AppTheme.ink,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: active ? color : AppTheme.muted.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
