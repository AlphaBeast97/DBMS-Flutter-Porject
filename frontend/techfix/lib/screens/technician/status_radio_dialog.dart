/// Dialog for a technician to update a job's status.
///
/// Shows all available statuses (Pending, Repairing, Ready, Delivered)
/// as radio-style tappable rows with icons. Uses [TechFixDialog] shell.
import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/techfix_dialog.dart';

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
    _val = widget.job.status;
  }

  @override
  Widget build(BuildContext context) {
    const statuses = ['Pending', 'Repairing', 'Ready', 'Delivered'];
    return TechFixDialog(
      icon: AppTheme.statusIcon(widget.job.status),
      iconColor: AppTheme.statusColor(widget.job.status),
      title: 'Update status',
      onClose: widget.onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: statuses.map((st) {
          final active = _val.toLowerCase() == st.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _val = st),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: active ? AppTheme.statusColor(st).withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? AppTheme.statusColor(st) : AppTheme.line,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppTheme.statusIcon(st),
                      size: 22,
                      color: active ? AppTheme.statusColor(st) : AppTheme.faint,
                    ),
                    const SizedBox(width: 11),
                    Text(
                      st,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: active ? AppTheme.statusColor(st) : AppTheme.ink,
                      ),
                    ),
                    const Spacer(),
                    if (active)
                      Icon(Icons.check_circle, size: 22, color: AppTheme.statusColor(st)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(onPressed: widget.onClose, child: const Text('Cancel')),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () {
            widget.onSave(_val);
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.statusColor(_val),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
