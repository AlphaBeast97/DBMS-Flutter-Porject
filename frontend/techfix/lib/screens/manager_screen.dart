import 'package:flutter/material.dart';
import 'package:techfix/data/mock_data.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/inventory_card.dart';
import 'package:techfix/widgets/section_header.dart';
import 'package:techfix/widgets/stat_card.dart';

class ManagerScreen extends StatelessWidget {
  const ManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Manager overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Track throughput, margins, and parts usage in one place.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              StatCard(label: 'Jobs this week', value: '18'),
              StatCard(label: 'Parts cost', value: '\$420'),
              StatCard(label: 'Avg. turnaround', value: '2.6 days'),
            ],
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Recent inventory usage'),
          const SizedBox(height: 12),
          ...MockData.recentUsage
              .map((usage) => InventoryCard(usage: usage)),
        ],
      ),
    );
  }
}
