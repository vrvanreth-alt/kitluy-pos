import 'cart_item.dart';
import 'payment.dart';
import 'vehicle.dart';

class Order {
  final String id;
  final String invoiceNo;
  final DateTime createdAt;
  final Vehicle? vehicle;
  final List<CartItem> items;
  final double exchangeRate;
  final double subtotalUSD;
  final double discountUSD;
  final double batteryTradeInTotalUSD;
  final double totalUSD;
  final int totalKHR;
  final PaymentRecord? payment;
  final String? mechanicName;
  final int? nextServiceMileage;
  final DateTime? nextServiceDate;
  final String status; // 'completed', 'pending', 'cancelled'

  Order({
    required this.id,
    required this.invoiceNo,
    required this.createdAt,
    this.vehicle,
    required this.items,
    required this.exchangeRate,
    required this.subtotalUSD,
    this.discountUSD = 0.0,
    this.batteryTradeInTotalUSD = 0.0,
    required this.totalUSD,
    required this.totalKHR,
    this.payment,
    this.mechanicName,
    this.nextServiceMileage,
    this.nextServiceDate,
    this.status = 'completed',
  });
}

