import 'package:flutter/material.dart';
import 'package:techfix/data/mock_data.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/job_card.dart';
import 'package:techfix/widgets/section_header.dart';
import 'package:techfix/widgets/stat_card.dart';

class CustomerStatusScreen extends StatelessWidget {
  const CustomerStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Track your repair',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your phone or job ID to see live status updates.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by phone or job ID',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Snapshot'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              StatCard(label: 'Active jobs', value: '2'),
              StatCard(label: 'Ready today', value: '1'),
              StatCard(label: 'Average ETA', value: '3 days'),
            ],
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Latest updates'),
          const SizedBox(height: 12),
          ...MockData.customerJobs.map((job) => JobCard(job: job)),
        ],
      ),
    );
  }
}
