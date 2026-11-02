import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  double customUnitPriceUSD;
  double discountUSD;
  double tradeInRebateUSD; // Old battery return credit
  String? note;

  CartItem({
    required this.product,
    this.quantity = 1,
    double? customUnitPriceUSD,
    this.discountUSD = 0.0,
    this.tradeInRebateUSD = 0.0,
    this.note,
  }) : customUnitPriceUSD = customUnitPriceUSD ?? product.unitPriceUSD;

  double get unitPrice => customUnitPriceUSD;

  /// Total for this item line after item discount and trade-in rebate
  double get lineTotalUSD {
    final sub = (customUnitPriceUSD * quantity) - discountUSD - tradeInRebateUSD;
    return sub > 0 ? sub : 0.0;
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? customUnitPriceUSD,
    double? discountUSD,
    double? tradeInRebateUSD,
    String? note,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customUnitPriceUSD: customUnitPriceUSD ?? this.customUnitPriceUSD,
      discountUSD: discountUSD ?? this.discountUSD,
      tradeInRebateUSD: tradeInRebateUSD ?? this.tradeInRebateUSD,
      note: note ?? this.note,
    );
  }
}

