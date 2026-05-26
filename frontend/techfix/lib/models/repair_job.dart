class RepairJob {
  final int id;
  final String deviceLabel;
  final String customerName;
  final String status;
  final DateTime createdAt;
  final double estimatedCost;
  final double? finalCost;

  const RepairJob({
    required this.id,
    required this.deviceLabel,
    required this.customerName,
    required this.status,
    required this.createdAt,
    required this.estimatedCost,
    this.finalCost,
  });
}
