import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/field.dart';
import 'package:techfix/widgets/techfix_dialog.dart';

class AddStaffDialog extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<Map<String, String>> onAdd;

  const AddStaffDialog({
    super.key,
    required this.onClose,
    required this.onAdd,
  });

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _pwCtl = TextEditingController();

  bool get _valid => _nameCtl.text.isNotEmpty &&
      _emailCtl.text.isNotEmpty &&
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailCtl.text) &&
      _pwCtl.text.length >= 6;

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _pwCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TechFixDialog(
      icon: Icons.person_add,
      iconColor: AppTheme.coral,
      title: 'Add technician',
      onClose: widget.onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Field(
            label: 'Full name',
            icon: Icons.badge,
            value: _nameCtl.text,
            onChanged: (v) { _nameCtl.text = v; setState(() {}); },
            autoFocus: true,
          ),
          const SizedBox(height: 12),
          Field(
            label: 'Work email',
            icon: Icons.mail,
            value: _emailCtl.text,
            onChanged: (v) { _emailCtl.text = v; setState(() {}); },
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          Field(
            label: 'Password',
            icon: Icons.lock,
            value: _pwCtl.text,
            onChanged: (v) { _pwCtl.text = v; setState(() {}); },
            obscureText: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.teal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.engineering, size: 17, color: AppTheme.teal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Added as a Technician with their own job console.',
                    style: TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onClose, child: const Text('Cancel')),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _valid
              ? () => widget.onAdd({
                    'name': _nameCtl.text,
                    'email': _emailCtl.text,
                    'password': _pwCtl.text,
                  })
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
