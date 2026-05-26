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
}
