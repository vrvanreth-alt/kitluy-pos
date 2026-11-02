class TireAttributes {
  final String size; // e.g. 215/55R17
  final String brand; // e.g. Michelin
  final String? pattern; // e.g. Primacy 4
  final String? dotWeekYear; // e.g. 2424 (Week 24, 2024)
  final int warrantyMonths;
  final String? loadSpeedRating; // e.g. 94W

  const TireAttributes({
    required this.size,
    required this.brand,
    this.pattern,
    this.dotWeekYear,
    this.warrantyMonths = 24,
    this.loadSpeedRating,
  });

  Map<String, dynamic> toMap() => {
    'size': size,
    'brand': brand,
    'pattern': pattern,
    'dotWeekYear': dotWeekYear,
    'warrantyMonths': warrantyMonths,
    'loadSpeedRating': loadSpeedRating,
  };
}

class BatteryAttributes {
  final String brand; // e.g. GS, Amaron, Varta
  final int capacityAh; // e.g. 70
  final String voltage; // e.g. 12V
  final String terminalType; // e.g. JIS 80D26L, DIN75, etc.
  final double defaultRebateUSD; // Trade-in credit for old battery
  final int warrantyMonths;

  const BatteryAttributes({
    required this.brand,
    required this.capacityAh,
    this.voltage = '12V',
    required this.terminalType,
    this.defaultRebateUSD = 10.0,
    this.warrantyMonths = 12,
  });

  Map<String, dynamic> toMap() => {
    'brand': brand,
    'capacityAh': capacityAh,
    'voltage': voltage,
    'terminalType': terminalType,
    'defaultRebateUSD': defaultRebateUSD,
    'warrantyMonths': warrantyMonths,
  };
}

class EngineOilAttributes {
  final String brand; // e.g. Motul, Castrol, Mobil
  final String viscosity; // e.g. 0W-20, 5W-30, 10W-40
  final String oilType; // Fully Synthetic, Semi-Synthetic, Mineral
  final double volumeLiters; // 1.0, 4.0, 5.0
  final int serviceIntervalKm; // e.g. 10,000 km or 5,000 km

  const EngineOilAttributes({
    required this.brand,
    required this.viscosity,
    required this.oilType,
    required this.volumeLiters,
    this.serviceIntervalKm = 8000,
  });

  Map<String, dynamic> toMap() => {
    'brand': brand,
    'viscosity': viscosity,
    'oilType': oilType,
    'volumeLiters': volumeLiters,
    'serviceIntervalKm': serviceIntervalKm,
  };
}

class SparePartAttributes {
  final String oemPartNumber; // e.g. 04152-YZZA1
  final String compatibility; // e.g. Toyota Camry 2012-2022 / Lexus ES350
  final String shelfLocation; // e.g. A-02-3

  const SparePartAttributes({
    required this.oemPartNumber,
    required this.compatibility,
    this.shelfLocation = 'Main Rack',
  });

  Map<String, dynamic> toMap() => {
    'oemPartNumber': oemPartNumber,
    'compatibility': compatibility,
    'shelfLocation': shelfLocation,
  };
}

