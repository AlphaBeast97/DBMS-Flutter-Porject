import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/models/inventory_usage.dart';
import 'package:techfix/widgets/status_badge.dart';

class JobCard extends StatefulWidget {
  final RepairJob job;
  final VoidCallback? onTap;
  final String? customerNameOverride;
  final String? deviceLabelOverride;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;
  final VoidCallback? onStatusTap;
  final List<InventoryUsage>? usages;
  final bool defaultOpen;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.customerNameOverride,
    this.deviceLabelOverride,
    this.onCancel,
    this.onEdit,
    this.onStatusTap,
    this.usages,
    this.defaultOpen = false,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.defaultOpen;
  }

  String fmtMoney(double n) {
    return '\$${n.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final statusColor = AppTheme.statusColor(job.status);
    final deviceLabel = widget.deviceLabelOverride ?? job.deviceLabel;
    final customerName = widget.customerNameOverride ?? job.customerName;
    final usages = widget.usages ?? [];
    final partsTotal = usages.fold<double>(0, (sum, u) => sum + u.partCost);
    final canCancel = job.status.toLowerCase() == 'pending';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.devices, size: 18, color: AppTheme.ink),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        deviceLabel,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.ink,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '#${job.id} · $customerName',
                                  style: const TextStyle(
                                    
                                    fontSize: 12.5,
                                    color: AppTheme.faint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onStatusTap,
                            child: AbsorbPointer(
                              child: StatusBadge(status: job.status),
                            ),
                          ),
                        ],
                      ),
                      if (job.description.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          job.description,
                          style: const TextStyle(
                            
                            fontSize: 14,
                            color: AppTheme.muted,
                            height: 1.45,
                          ),
                        ),
                      ],
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Text(
                            fmtMoney(job.finalCost ?? job.estimatedCost),
                            style: const TextStyle(
                              
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            job.finalCost != null ? 'final' : 'est.',
                            style: const TextStyle(
                              
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.faint,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _expanded = !_expanded),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  usages.isNotEmpty ? '${usages.length} part${usages.length > 1 ? 's' : ''}' : 'Details',
                                  style: const TextStyle(
                                    
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.muted,
                                  ),
                                ),
                                Icon(
                                  _expanded ? Icons.expand_less : Icons.expand_more,
                                  size: 20,
                                  color: AppTheme.muted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: _expanded
                            ? Padding(
                                padding: const EdgeInsets.only(top: 13),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(height: 1, color: AppTheme.line),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'PARTS USED',
                                      style: TextStyle(
                                        
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.faint,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    if (usages.isNotEmpty)
                                      ...usages.map((u) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: AppTheme.cream,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.memory, size: 16, color: AppTheme.clay),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    u.partName,
                                                    style: const TextStyle(
                                                      
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppTheme.ink,
                                                    ),
                                                  ),
                                                  Text(
                                                    'by ${u.loggedBy.isNotEmpty ? u.loggedBy : 'Unknown'}',
                                                    style: const TextStyle(
                                                      
                                                      fontSize: 11.5,
                                                      color: AppTheme.faint,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              fmtMoney(u.partCost),
                                              style: const TextStyle(
                                                
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.ink,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                    else
                                      const Text(
                                        'No parts logged yet.',
                                        style: TextStyle(
                                          
                                          fontSize: 13,
                                          color: AppTheme.faint,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    if (usages.length > 1)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2, bottom: 8),
                                        child: Row(
                                          children: [
                                            const Spacer(),
                                            const Text(
                                              'Parts subtotal',
                                              style: TextStyle(
                                                
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.muted,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              fmtMoney(partsTotal),
                                              style: TextStyle(
                                                
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.clay,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (widget.onStatusTap != null || widget.onEdit != null || (widget.onCancel != null && canCancel))
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14),
                                        child: Row(
                                          children: [
                                            if (widget.onStatusTap != null)
                                              _ActionButton(
                                                icon: Icons.cached,
                                                label: 'Status',
                                                onTap: () => widget.onStatusTap!(),
                                                color: AppTheme.sky,
                                                tonal: true,
                                              ),
                                            if (widget.onEdit != null) ...[
                                              const SizedBox(width: 8),
                                              _ActionButton(
                                                icon: Icons.edit,
                                                label: 'Edit',
                                                onTap: () => widget.onEdit!(),
                                                color: AppTheme.ink,
                                                outlined: true,
                                              ),
                                            ],
                                            if (widget.onCancel != null && canCancel) ...[
                                              const SizedBox(width: 8),
                                              _ActionButton(
                                                icon: Icons.cancel,
                                                label: 'Cancel',
                                                onTap: () => widget.onCancel!(),
                                                color: AppTheme.coral,
                                                text: true,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool tonal;
  final bool outlined;
  final bool text;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.tonal = false,
    this.outlined = false,
    this.text = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      backgroundColor: tonal ? color.withOpacity(0.14) : (outlined ? Colors.transparent : null),
      foregroundColor: tonal ? color : (outlined ? AppTheme.ink : null),
      side: outlined ? BorderSide(color: AppTheme.ink) : null,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    );

    if (text) {
      return TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    final btn = tonal ? FilledButton.tonalIcon : (outlined ? OutlinedButton.icon : FilledButton.icon);

    return btn(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: style,
    );
  }
}
