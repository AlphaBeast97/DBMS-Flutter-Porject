import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/field.dart';
import 'package:techfix/widgets/techfix_dialog.dart';

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
    return TechFixDialog(
      icon: Icons.edit,
      iconColor: AppTheme.ink,
      title: 'Edit job',
      onClose: widget.onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            keyboardType: TextInputType.number,
            suffix: const Text('USD', style: TextStyle(fontSize: 14, color: AppTheme.faint)),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onClose, child: const Text('Cancel')),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => widget.onSave({
            'description': _desc,
            'cost': double.tryParse(_cost) ?? 0,
          }),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
