/// Data model for a repair job record from the backend.
///
/// Parses the API JSON response (field names like `job_id`, `estimated_cost`)
/// and constructs a combined [deviceLabel] from brand + model fields.
class RepairJob {
  final int id;
  final int deviceId;
  final int customerId;
  final int? createdByEmployeeId;
  final String deviceLabel;
  final String customerName;
  final String status;
  final String description;
  final DateTime createdAt;
  final double estimatedCost;
  final double? finalCost;

  const RepairJob({
    required this.id,
    required this.deviceId,
    required this.customerId,
    this.createdByEmployeeId,
    required this.deviceLabel,
    required this.customerName,
    required this.status,
    required this.description,
    required this.createdAt,
    required this.estimatedCost,
    this.finalCost,
  });

  /// Parses a JSON map from the API into a [RepairJob].
  /// Handles snake_case and camelCase key variations for resilience.
  factory RepairJob.fromApi(Map<String, dynamic> json) {
    final deviceBrand = (json['brand'] ?? json['device_brand'] ?? '')
        .toString();
    final deviceModel = (json['model'] ?? json['device_model'] ?? '')
        .toString();
    final deviceType = (json['type'] ?? json['device_type'] ?? '').toString();
    final customerName = (json['customer_name'] ?? '').toString();
    final labelParts = [
      deviceBrand,
      deviceModel,
    ].where((part) => part.trim().isNotEmpty).toList();
    final label = labelParts.isNotEmpty
        ? labelParts.join(' ')
        : (deviceType.isNotEmpty ? deviceType : 'Device');

    double parseAmount(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return RepairJob(
      id: (json['job_id'] ?? json['id'] ?? 0) as int,
      deviceId: (json['device_id'] ?? 0) as int,
      customerId: (json['customer_id'] ?? 0) as int,
      createdByEmployeeId: json['created_by_employee_id'] as int?,
      deviceLabel: label,
      customerName: customerName.isNotEmpty ? customerName : 'Customer',
      status: (json['status'] ?? 'Pending').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      estimatedCost: parseAmount(
        json['estimated_cost'] ?? json['estimatedCost'] ?? 0,
      ),
      finalCost: json['final_cost'] == null
          ? null
          : parseAmount(json['final_cost']),
    );
  }
}
