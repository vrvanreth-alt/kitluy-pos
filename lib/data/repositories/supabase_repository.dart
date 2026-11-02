import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';
import '../dummy_data.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/product_attributes.dart';
import '../models/vehicle.dart';

class SupabaseRepository {
  static final SupabaseRepository _instance = SupabaseRepository._internal();
  factory SupabaseRepository() => _instance;
  SupabaseRepository._internal();

  /// Fetch products from Supabase with fallback to local dummy data
  Future<List<Product>> getProducts() async {
    final client = SupabaseService.client;
    if (client == null) {
      return DummyData.initialProducts;
    }

    try {
      final response = await client.from('products').select().order('name_kh');
      if (response.isEmpty) {
        return DummyData.initialProducts;
      }

      return (response as List).map((row) {
        final categoryStr = row['category'] as String? ?? 'spareParts';
        final category = ProductCategory.values.firstWhere(
          (c) => c.name == categoryStr,
          orElse: () => ProductCategory.spareParts,
        );

        final attrs = row['attributes'] as Map<String, dynamic>? ?? {};

        TireAttributes? tire;
        BatteryAttributes? battery;
        EngineOilAttributes? oil;
        SparePartAttributes? part;

        if (category == ProductCategory.tires && attrs.isNotEmpty) {
          tire = TireAttributes(
            size: attrs['size'] ?? '',
            brand: attrs['brand'] ?? '',
            pattern: attrs['pattern'],
            dotWeekYear: attrs['dot'],
            warrantyMonths: attrs['warranty'] ?? 24,
          );
        } else if (category == ProductCategory.batteries && attrs.isNotEmpty) {
          battery = BatteryAttributes(
            brand: attrs['brand'] ?? row['name_en'] ?? '',
            capacityAh: attrs['capacityAh'] ?? 70,
            terminalType: attrs['terminal'] ?? 'JIS',
            defaultRebateUSD: (attrs['rebate'] as num?)?.toDouble() ?? 10.0,
          );
        } else if (category == ProductCategory.engineOil && attrs.isNotEmpty) {
          oil = EngineOilAttributes(
            brand: attrs['brand'] ?? '',
            viscosity: attrs['viscosity'] ?? '5W-30',
            oilType: attrs['type'] ?? 'Synthetic',
            volumeLiters: (attrs['volume'] as num?)?.toDouble() ?? 4.0,
          );
        } else if (category == ProductCategory.spareParts && attrs.isNotEmpty) {
          part = SparePartAttributes(
            oemPartNumber: attrs['oem'] ?? '',
            compatibility: attrs['compatibility'] ?? '',
          );
        }

        return Product(
          id: row['id'].toString(),
          code: row['code'] ?? '',
          nameKh: row['name_kh'] ?? '',
          nameEn: row['name_en'] ?? '',
          category: category,
          unitPriceUSD: (row['unit_price_usd'] as num).toDouble(),
          costPriceUSD: (row['cost_price_usd'] as num?)?.toDouble() ?? 0.0,
          stockQuantity: row['stock_quantity'] as int? ?? 0,
          minStockAlert: row['min_stock_alert'] as int? ?? 5,
          unit: row['unit'] ?? 'សំបក',
          tire: tire,
          battery: battery,
          engineOil: oil,
          sparePart: part,
        );
      }).toList();
    } catch (e) {
      debugPrint('Supabase fetch products error: $e');
      return DummyData.initialProducts;
    }
  }

  /// Save completed order to Supabase
  Future<bool> createOrder(Order order) async {
    final client = SupabaseService.client;
    if (client == null) return false;

    try {
      // 1. Insert order
      final orderRes = await client.from('orders').insert({
        'invoice_no': order.invoiceNo,
        'mechanic_name': order.mechanicName,
        'exchange_rate': order.exchangeRate,
        'subtotal_usd': order.subtotalUSD,
        'discount_usd': order.discountUSD,
        'trade_in_usd': order.batteryTradeInTotalUSD,
        'total_usd': order.totalUSD,
        'total_khr': order.totalKHR,
        'status': order.status,
        'next_service_mileage': order.nextServiceMileage,
        'next_service_date': order.nextServiceDate?.toIso8601String().split('T').first,
      }).select().single();

      final orderId = orderRes['id'];

      // 2. Insert items
      final itemsData = order.items.map((item) => {
        'order_id': orderId,
        'product_id': item.product.id,
        'quantity': item.quantity,
        'unit_price_usd': item.customUnitPriceUSD,
        'discount_usd': item.discountUSD,
        'trade_in_usd': item.tradeInRebateUSD,
        'line_total_usd': item.lineTotalUSD,
        'note': item.note,
      }).toList();

      await client.from('order_items').insert(itemsData);

      // 3. Insert payment
      if (order.payment != null) {
        await client.from('payments').insert({
          'order_id': orderId,
          'payment_method': order.payment!.method.name,
          'paid_usd': order.payment!.paidUSD,
          'paid_khr': order.payment!.paidKHR,
          'change_usd': order.payment!.changeUSD,
          'change_khr': order.payment!.changeKHR,
          'khqr_reference': order.payment!.khqrReference,
        });
      }

      return true;
    } catch (e) {
      debugPrint('Supabase save order error: $e');
      return false;
    }
  }

  /// Save or sync vehicle to Supabase
  Future<void> saveVehicle(Vehicle vehicle) async {
    final client = SupabaseService.client;
    if (client == null) return;

    try {
      await client.from('vehicles').upsert({
        'plate_number': vehicle.plateNumber,
        'model': vehicle.model,
        'current_mileage': vehicle.currentMileage,
        'customer_name': vehicle.customerName,
        'customer_phone': vehicle.customerPhone,
        'note': vehicle.note,
      }, onConflict: 'plate_number');
    } catch (e) {
      debugPrint('Supabase save vehicle error: $e');
    }
  }
}
