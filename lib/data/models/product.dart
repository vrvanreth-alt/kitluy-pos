import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'product_attributes.dart';

enum ProductCategory {
  all('ទាំងអស់', 'All', Icons.grid_view),
  tires('សំបកកង់', 'Tires', Icons.trip_origin),
  batteries('អាគុយ', 'Batteries', Icons.battery_charging_full),
  engineOil('ប្រេងម៉ាស៊ីន', 'Engine Oil', Icons.opacity),
  spareParts('គ្រឿងបន្លាស់', 'Spare Parts', Icons.build),
  services('សេវាកម្ម', 'Services', Icons.handyman);

  final String titleKh;
  final String titleEn;
  final IconData icon;

  const ProductCategory(this.titleKh, this.titleEn, this.icon);

  Color get tagColor {
    switch (this) {
      case ProductCategory.tires:
        return AppColors.tireColor;
      case ProductCategory.batteries:
        return AppColors.batteryColor;
      case ProductCategory.engineOil:
        return AppColors.oilColor;
      case ProductCategory.spareParts:
        return AppColors.partsColor;
      case ProductCategory.services:
        return AppColors.serviceColor;
      case ProductCategory.all:
        return AppColors.primary;
    }
  }
}

class Product {
  final String id;
  final String code; // Barcode or internal SKU
  final String nameKh;
  final String nameEn;
  final ProductCategory category;
  final double unitPriceUSD;
  final double costPriceUSD;
  final int stockQuantity;
  final int minStockAlert;
  final String unit; // គ្រាប់, ធុង, កំប៉ុង, សំបក, ឈុត, ដង
  final String? image;

  // Specific Auto Attributes
  final TireAttributes? tire;
  final BatteryAttributes? battery;
  final EngineOilAttributes? engineOil;
  final SparePartAttributes? sparePart;

  const Product({
    required this.id,
    required this.code,
    required this.nameKh,
    required this.nameEn,
    required this.category,
    required this.unitPriceUSD,
    this.costPriceUSD = 0.0,
    required this.stockQuantity,
    this.minStockAlert = 5,
    required this.unit,
    this.image,
    this.tire,
    this.battery,
    this.engineOil,
    this.sparePart,
  });

  bool get isLowStock => category != ProductCategory.services && stockQuantity <= minStockAlert;
  bool get isOutOfStock => category != ProductCategory.services && stockQuantity <= 0;

  /// Helper to get a quick summary attribute badge text
  String get attributeSummary {
    if (tire != null) {
      return '${tire!.size} • DOT ${tire!.dotWeekYear ?? "2024"}';
    } else if (battery != null) {
      return '${battery!.capacityAh}Ah (${battery!.terminalType})';
    } else if (engineOil != null) {
      return '${engineOil!.viscosity} • ${engineOil!.volumeLiters}L';
    } else if (sparePart != null) {
      return 'OEM: ${sparePart!.oemPartNumber}';
    }
    return unit;
  }
}

