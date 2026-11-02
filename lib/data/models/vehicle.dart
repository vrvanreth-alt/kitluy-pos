class Vehicle {
  final String plateNumber; // ភ្នំពេញ 2BC-1234
  final String model; // Toyota Prius 2010 / Lexus RX350
  final int currentMileage; // 124,500 km
  final String customerName;
  final String customerPhone;
  final String? note;

  const Vehicle({
    required this.plateNumber,
    required this.model,
    required this.currentMileage,
    this.customerName = 'អតិថិជនទូទៅ (Walk-in)',
    this.customerPhone = '',
    this.note,
  });

  Vehicle copyWith({
    String? plateNumber,
    String? model,
    int? currentMileage,
    String? customerName,
    String? customerPhone,
    String? note,
  }) {
    return Vehicle(
      plateNumber: plateNumber ?? this.plateNumber,
      model: model ?? this.model,
      currentMileage: currentMileage ?? this.currentMileage,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      note: note ?? this.note,
    );
  }
}

