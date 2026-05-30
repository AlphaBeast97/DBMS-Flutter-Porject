import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/models/inventory_usage.dart';
import 'package:techfix/widgets/inventory_card.dart';

class JobCard extends StatefulWidget {
  final RepairJob job;
  final VoidCallback? onTap;
  final String? customerNameOverride;
  final String? deviceLabelOverride;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;
  final List<InventoryUsage>? usages;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.customerNameOverride,
    this.deviceLabelOverride,
    this.onCancel,
    this.onEdit,
    this.usages,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final statusColor = AppTheme.statusColor(job.status);
    final deviceLabel = widget.deviceLabelOverride ?? job.deviceLabel;
    final customerName = widget.customerNameOverride ?? job.customerName;
    final usages = widget.usages ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        deviceLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            job.status,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (widget.onEdit != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: widget.onEdit,
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit description',
                          ),
                        ],
                        if (usages.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () =>
                                setState(() => _expanded = !_expanded),
                            icon: Icon(
                              _expanded ? Icons.expand_less : Icons.expand_more,
                            ),
                            tooltip: _expanded ? 'Hide parts' : 'Show parts',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer: $customerName',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (job.description.isNotEmpty)
                  Text(
                    job.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Job #${job.id}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      job.finalCost != null
                          ? 'Final: \$${job.finalCost!.toStringAsFixed(0)}'
                          : 'Estimate: \$${job.estimatedCost.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (widget.onTap != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Tap to update status',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (widget.onCancel != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel job'),
                    ),
                  ),
                ],

                // Inventory usage expanded area
                if (_expanded && usages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: usages
                          .map((u) => InventoryCard(usage: u))
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
