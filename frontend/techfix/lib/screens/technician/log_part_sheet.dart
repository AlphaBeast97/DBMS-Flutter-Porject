import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/field.dart';
import 'package:techfix/widgets/sheet.dart';

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
                              j.customerName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.faint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (active)
                        const Icon(Icons.check_circle, size: 20, color: AppTheme.clay),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Field(
            label: 'Part name',
            icon: Icons.build,
            value: _nameCtl.text,
            onChanged: (v) => setState(() => _nameCtl.text = v),
            autoFocus: true,
          ),
          const SizedBox(height: 10),
          Field(
            label: 'Part cost (\$)',
            icon: Icons.payments,
            value: _costCtl.text,
            onChanged: (v) => setState(() => _costCtl.text = v),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
