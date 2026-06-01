/// Multi-step bottom sheet wizard for creating a new repair job.
///
/// **Step 0** — Customer info (email, name, phone)
/// **Step 1** — Device info (type, brand, model, serial)
/// **Step 2** — Issue details (description, estimated cost)
///
/// On final step, calls [onCreate] with all collected form data.
/// Uses [Sheet] shell with a stepper progress indicator.
import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/field.dart';
import 'package:techfix/widgets/sheet.dart';

/// Device type options with icons for the type selector chips.
const _deviceTypes = [
  ('Laptop', Icons.laptop_mac),
  ('Mobile', Icons.smartphone),
  ('Console', Icons.videogame_asset),
  ('Tablet', Icons.tablet_mac),
  ('Other', Icons.devices_other),
];

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

  /// Form data map shared across all 3 steps.
  /// Keys: cEmail, cName, cPhone, dType, brand, model, serial, desc, cost
  final _f = <String, String>{
    'cEmail': '', 'cName': '', 'cPhone': '',
    'dType': 'Mobile',
    'brand': '', 'model': '', 'serial': '',
    'desc': '', 'cost': '',
  };

  void _set(String k, String v) => setState(() => _f[k] = v);

  /// Validation depends on current step.
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
          // --- Step progress indicator ---
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

          // --- Step 0: Customer info ---
          if (_step == 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer info',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Field(
                  label: 'Email',
                  icon: Icons.mail,
                  value: _f['cEmail']!,
                  onChanged: (v) => _set('cEmail', v),
                  keyboardType: TextInputType.emailAddress,
                  autoFocus: true,
                ),
                const SizedBox(height: 10),
                Field(
                  label: 'Full name',
                  icon: Icons.person,
                  value: _f['cName']!,
                  onChanged: (v) => _set('cName', v),
                ),
                const SizedBox(height: 10),
                Field(
                  label: 'Phone (optional)',
                  icon: Icons.phone,
                  value: _f['cPhone']!,
                  onChanged: (v) => _set('cPhone', v),
                  keyboardType: TextInputType.phone,
                ),
                // Info about duplicate email handling
                if (!_valid && _f['cEmail']!.isNotEmpty && _f['cName']!.isNotEmpty) ...[
                  const SizedBox(height: 8),
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
                            'Duplicate email will link to existing customer.',
                            style: TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

          // --- Step 1: Device info ---
          if (_step == 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Device info',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Type',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 6),
                // Device type chip selector
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _deviceTypes.map((t) {
                    final active = _f['dType'] == t.$1;
                    return GestureDetector(
                      onTap: () => _set('dType', t.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? AppTheme.coral.withOpacity(0.12) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active ? AppTheme.coral : AppTheme.line2,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(t.$2, size: 19, color: active ? AppTheme.coral : AppTheme.faint),
                            const SizedBox(width: 6),
                            Text(
                              t.$1,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: active ? AppTheme.coral : AppTheme.ink,
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
                  icon: Icons.badge,
                  value: _f['brand']!,
                  onChanged: (v) => _set('brand', v),
                ),
                const SizedBox(height: 10),
                Field(
                  label: 'Model',
                  icon: Icons.dns,
                  value: _f['model']!,
                  onChanged: (v) => _set('model', v),
                ),
                const SizedBox(height: 10),
                Field(
                  label: 'Serial number (optional)',
                  icon: Icons.qr_code,
                  value: _f['serial']!,
                  onChanged: (v) => _set('serial', v),
                ),
              ],
            ),

          // --- Step 2: Issue details ---
          if (_step == 2)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Issue details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Field(
                  label: 'Description',
                  value: _f['desc']!,
                  onChanged: (v) => _set('desc', v),
                  multiline: true,
                  rows: 4,
                ),
                const SizedBox(height: 10),
                Field(
                  label: 'Est. cost (\$)',
                  icon: Icons.payments,
                  value: _f['cost']!,
                  onChanged: (v) => _set('cost', v),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
