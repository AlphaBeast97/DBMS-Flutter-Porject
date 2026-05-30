import 'package:flutter/material.dart';
import 'package:techfix/models/repair_job.dart';
import 'package:techfix/theme/app_theme.dart';

class JobCard extends StatelessWidget {
  final RepairJob job;
  final VoidCallback? onTap;
  final String? customerNameOverride;
  final String? deviceLabelOverride;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.customerNameOverride,
    this.deviceLabelOverride,
    this.onCancel,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(job.status);
    final deviceLabel = deviceLabelOverride ?? job.deviceLabel;
    final customerName = customerNameOverride ?? job.customerName;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
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
                        if (onEdit != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit description',
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
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
                if (onTap != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Tap to update status',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (onCancel != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel job'),
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
