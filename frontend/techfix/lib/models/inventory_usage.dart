/// Data model for an inventory usage record (part logged against a repair job).
///
/// Each instance represents one part used during a repair, with its
/// name, cost, and the employee who logged it.
class InventoryUsage {
  final int jobId;
  final String partName;
  final double partCost;
  final String loggedBy;
  final DateTime createdAt;

  const InventoryUsage({
    required this.jobId,
    required this.partName,
    required this.partCost,
    required this.loggedBy,
    required this.createdAt,
  });

  /// Parses a JSON map from the API into an [InventoryUsage].
  factory InventoryUsage.fromApi(Map<String, dynamic> json) {
    double parseAmount(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return InventoryUsage(
      jobId: (json['job_id'] ?? 0) as int,
      partName: (json['part_name'] ?? '').toString(),
      partCost: parseAmount(json['part_cost']),
      loggedBy: (json['logged_by'] ?? json['employee_name'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
