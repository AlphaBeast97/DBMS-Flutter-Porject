class Device {
  final int id;
  final String customerName;
  final String type;
  final String brand;
  final String model;
  final String serialNumber;

  const Device({
    required this.id,
    required this.customerName,
    required this.type,
    required this.brand,
    required this.model,
    required this.serialNumber,
  });

  String get label => '$brand $model';
}
