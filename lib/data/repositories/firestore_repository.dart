import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import '../../core/services/firebase_service.dart';
import '../dummy_data.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/product_attributes.dart';
import '../models/vehicle.dart';

class FirestoreRepository {
  static final FirestoreRepository _instance = FirestoreRepository._internal();
  factory FirestoreRepository() => _instance;
  FirestoreRepository._internal();

  FirebaseFirestore get _db => FirebaseService.firestore;

  /// Fetch products from Firestore with auto-seeding if empty
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _db.collection('products').get();

      if (snapshot.docs.isEmpty) {
        debugPrint('🌱 Firestore products empty. Auto-seeding initial automotive catalog...');
        await seedInitialProducts();
        return DummyData.initialProducts;
      }

      return snapshot.docs.map((doc) => _mapDocToProduct(doc.id, doc.data())).toList();
    } catch (e) {
      debugPrint('⚠️ Error fetching products from Firestore: $e');
      return DummyData.initialProducts;
    }
  }

  /// Real-time stream of products for instant stock updates
  Stream<List<Product>> streamProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return DummyData.initialProducts;
      return snapshot.docs.map((doc) => _mapDocToProduct(doc.id, doc.data())).toList();
    });
  }

  /// Seed initial automotive catalog to Firestore
  Future<void> seedInitialProducts() async {
    try {
      final batch = _db.batch();
      for (final p in DummyData.initialProducts) {
        final docRef = _db.collection('products').doc(p.id);
        batch.set(docRef, _mapProductToMap(p));
      }
      await batch.commit();
      debugPrint('✅ Initial catalog seeded to Firestore successfully!');
    } catch (e) {
      debugPrint('⚠️ Error seeding products: $e');
    }
  }

  /// Create and save a new order with atomic stock deduction
  Future<bool> createOrder(Order order) async {
    try {
      final batch = _db.batch();

      // 1. Order document
      final orderRef = _db.collection('orders').doc(order.id);
      batch.set(orderRef, {
        'id': order.id,
        'invoiceNo': order.invoiceNo,
        'createdAt': Timestamp.fromDate(order.createdAt),
        'mechanicName': order.mechanicName,
        'exchangeRate': order.exchangeRate,
        'subtotalUSD': order.subtotalUSD,
        'discountUSD': order.discountUSD,
        'tradeInUSD': order.batteryTradeInTotalUSD,
        'totalUSD': order.totalUSD,
        'totalKHR': order.totalKHR,
        'status': order.status,
        'nextServiceMileage': order.nextServiceMileage,
        'nextServiceDate': order.nextServiceDate != null
            ? Timestamp.fromDate(order.nextServiceDate!)
            : null,
        'vehicle': order.vehicle != null
            ? {
                'plateNumber': order.vehicle!.plateNumber,
                'model': order.vehicle!.model,
                'currentMileage': order.vehicle!.currentMileage,
                'customerName': order.vehicle!.customerName,
                'customerPhone': order.vehicle!.customerPhone,
              }
            : null,
        'items': order.items.map((item) => {
          'productId': item.product.id,
          'productNameKh': item.product.nameKh,
          'productNameEn': item.product.nameEn,
          'quantity': item.quantity,
          'unitPriceUSD': item.customUnitPriceUSD,
          'discountUSD': item.discountUSD,
          'tradeInRebateUSD': item.tradeInRebateUSD,
          'lineTotalUSD': item.lineTotalUSD,
          'note': item.note,
        }).toList(),
        'payment': order.payment != null
            ? {
                'method': order.payment!.method.name,
                'paidUSD': order.payment!.paidUSD,
                'paidKHR': order.payment!.paidKHR,
                'changeUSD': order.payment!.changeUSD,
                'changeKHR': order.payment!.changeKHR,
                'khqrReference': order.payment!.khqrReference,
              }
            : null,
      });

      // 2. Atomic stock deduction for physical items
      for (final item in order.items) {
        if (item.product.category != ProductCategory.services) {
          final prodRef = _db.collection('products').doc(item.product.id);
          batch.update(prodRef, {
            'stockQuantity': FieldValue.increment(-item.quantity),
          });
        }
      }

      // 3. Save / Update vehicle if present
      if (order.vehicle != null) {
        final vehicleRef = _db.collection('vehicles').doc(order.vehicle!.plateNumber);
        batch.set(vehicleRef, {
          'plateNumber': order.vehicle!.plateNumber,
          'model': order.vehicle!.model,
          'currentMileage': order.vehicle!.currentMileage,
          'customerName': order.vehicle!.customerName,
          'customerPhone': order.vehicle!.customerPhone,
          'lastServiceDate': Timestamp.fromDate(order.createdAt),
          'note': order.vehicle!.note,
        }, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('✅ Order ${order.invoiceNo} saved to Firestore & stock deducted!');
      return true;
    } catch (e) {
      debugPrint('⚠️ Error saving order to Firestore: $e');
      return false;
    }
  }

  /// Save or update vehicle details in Firestore
  Future<void> saveVehicle(Vehicle vehicle) async {
    try {
      await _db.collection('vehicles').doc(vehicle.plateNumber).set({
        'plateNumber': vehicle.plateNumber,
        'model': vehicle.model,
        'currentMileage': vehicle.currentMileage,
        'customerName': vehicle.customerName,
        'customerPhone': vehicle.customerPhone,
        'note': vehicle.note,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ Vehicle ${vehicle.plateNumber} saved to Firestore');
    } catch (e) {
      debugPrint('⚠️ Error saving vehicle to Firestore: $e');
    }
  }

  /// Search vehicle by plate number
  Future<Vehicle?> searchVehicle(String plateNumber) async {
    try {
      final doc = await _db.collection('vehicles').doc(plateNumber).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      return Vehicle(
        plateNumber: data['plateNumber'] ?? plateNumber,
        model: data['model'] ?? '',
        currentMileage: data['currentMileage'] ?? 0,
        customerName: data['customerName'] ?? '',
        customerPhone: data['customerPhone'] ?? '',
        note: data['note'],
      );
    } catch (e) {
      debugPrint('⚠️ Error searching vehicle: $e');
      return null;
    }
  }

  /// Helper to convert Product object to Firestore Map
  Map<String, dynamic> _mapProductToMap(Product p) {
    return {
      'code': p.code,
      'nameKh': p.nameKh,
      'nameEn': p.nameEn,
      'category': p.category.name,
      'unitPriceUSD': p.unitPriceUSD,
      'costPriceUSD': p.costPriceUSD,
      'stockQuantity': p.stockQuantity,
      'minStockAlert': p.minStockAlert,
      'unit': p.unit,
      'image': p.image,
      'tire': p.tire?.toMap(),
      'battery': p.battery?.toMap(),
      'engineOil': p.engineOil?.toMap(),
      'sparePart': p.sparePart?.toMap(),
    };
  }

  /// Helper to convert Firestore Map to Product object
  Product _mapDocToProduct(String docId, Map<String, dynamic> data) {
    final catName = data['category'] as String? ?? 'spareParts';
    final category = ProductCategory.values.firstWhere(
      (c) => c.name == catName,
      orElse: () => ProductCategory.spareParts,
    );

    TireAttributes? tire;
    if (data['tire'] != null) {
      final t = data['tire'] as Map<String, dynamic>;
      tire = TireAttributes(
        size: t['size'] ?? '',
        brand: t['brand'] ?? '',
        pattern: t['pattern'],
        dotWeekYear: t['dotWeekYear'],
        warrantyMonths: t['warrantyMonths'] ?? 24,
        loadSpeedRating: t['loadSpeedRating'],
      );
    }

    BatteryAttributes? battery;
    if (data['battery'] != null) {
      final b = data['battery'] as Map<String, dynamic>;
      battery = BatteryAttributes(
        brand: b['brand'] ?? '',
        capacityAh: b['capacityAh'] ?? 70,
        voltage: b['voltage'] ?? '12V',
        terminalType: b['terminalType'] ?? 'JIS',
        defaultRebateUSD: (b['defaultRebateUSD'] as num?)?.toDouble() ?? 10.0,
        warrantyMonths: b['warrantyMonths'] ?? 12,
      );
    }

    EngineOilAttributes? oil;
    if (data['engineOil'] != null) {
      final o = data['engineOil'] as Map<String, dynamic>;
      oil = EngineOilAttributes(
        brand: o['brand'] ?? '',
        viscosity: o['viscosity'] ?? '5W-30',
        oilType: o['oilType'] ?? 'Fully Synthetic',
        volumeLiters: (o['volumeLiters'] as num?)?.toDouble() ?? 4.0,
        serviceIntervalKm: o['serviceIntervalKm'] ?? 8000,
      );
    }

    SparePartAttributes? part;
    if (data['sparePart'] != null) {
      final s = data['sparePart'] as Map<String, dynamic>;
      part = SparePartAttributes(
        oemPartNumber: s['oemPartNumber'] ?? '',
        compatibility: s['compatibility'] ?? '',
        shelfLocation: s['shelfLocation'] ?? 'Main Rack',
      );
    }

    return Product(
      id: docId,
      code: data['code'] ?? '',
      nameKh: data['nameKh'] ?? '',
      nameEn: data['nameEn'] ?? '',
      category: category,
      unitPriceUSD: (data['unitPriceUSD'] as num?)?.toDouble() ?? 0.0,
      costPriceUSD: (data['costPriceUSD'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: data['stockQuantity'] as int? ?? 0,
      minStockAlert: data['minStockAlert'] as int? ?? 5,
      unit: data['unit'] ?? 'សំបក',
      image: data['image'],
      tire: tire,
      battery: battery,
      engineOil: oil,
      sparePart: part,
    );
  }
}
