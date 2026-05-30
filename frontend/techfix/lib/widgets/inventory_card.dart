import 'package:flutter/material.dart';
import 'package:techfix/models/inventory_usage.dart';
import 'package:techfix/theme/app_theme.dart';

class InventoryCard extends StatelessWidget {
  final InventoryUsage usage;

  const InventoryCard({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.clay.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.memory, size: 20, color: AppTheme.clay),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usage.partName,
                  style: const TextStyle(
                    
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Job #${usage.jobId} · ${usage.loggedBy.isNotEmpty ? usage.loggedBy : 'Unknown'}',
                  style: const TextStyle(
                    
                    fontSize: 12,
                    color: AppTheme.faint,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${usage.partCost.toStringAsFixed(2)}',
            style: const TextStyle(
              
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}
