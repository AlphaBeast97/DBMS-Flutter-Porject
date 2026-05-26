import 'package:techfix/models/inventory_usage.dart';
import 'package:techfix/models/repair_job.dart';

class MockData {
  static final List<RepairJob> customerJobs = [
    RepairJob(
      id: 1204,
      deviceLabel: 'Apple iPhone 12',
      customerName: 'Ayesha Khan',
      status: 'In Progress',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      estimatedCost: 120.0,
    ),
    RepairJob(
      id: 1201,
      deviceLabel: 'Dell XPS 13',
      customerName: 'Ayesha Khan',
      status: 'Ready',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      estimatedCost: 220.0,
      finalCost: 210.0,
    ),
  ];

  static final List<RepairJob> openJobs = [
    RepairJob(
      id: 1204,
      deviceLabel: 'Apple iPhone 12',
      customerName: 'Ayesha Khan',
      status: 'In Progress',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      estimatedCost: 120.0,
    ),
    RepairJob(
      id: 1199,
      deviceLabel: 'Samsung Galaxy S21',
      customerName: 'Hassan Ali',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      estimatedCost: 95.0,
    ),
    RepairJob(
      id: 1192,
      deviceLabel: 'HP Envy 15',
      customerName: 'Sara Iqbal',
      status: 'In Progress',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      estimatedCost: 180.0,
    ),
  ];

  static final List<InventoryUsage> recentUsage = [
    InventoryUsage(
      jobId: 1204,
      partName: 'Battery pack',
      partCost: 32.0,
      loggedBy: 'Imran J.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    InventoryUsage(
      jobId: 1192,
      partName: 'SSD 512GB',
      partCost: 54.0,
      loggedBy: 'Nadia R.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InventoryUsage(
      jobId: 1199,
      partName: 'Screen protector',
      partCost: 8.0,
      loggedBy: 'Imran J.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
