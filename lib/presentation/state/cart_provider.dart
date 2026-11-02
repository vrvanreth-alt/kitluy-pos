import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';

class CartState {
  final List<CartItem> items;
  final double overallDiscountUSD;
  final String mechanicName;
  final int nextServiceIntervalKm;

  const CartState({
    this.items = const [],
    this.overallDiscountUSD = 0.0,
    this.mechanicName = 'ជាង សាក់ (Sak)',
    this.nextServiceIntervalKm = 8000,
  });

  CartState copyWith({
    List<CartItem>? items,
    double? overallDiscountUSD,
    String? mechanicName,
    int? nextServiceIntervalKm,
  }) {
    return CartState(
      items: items ?? this.items,
      overallDiscountUSD: overallDiscountUSD ?? this.overallDiscountUSD,
      mechanicName: mechanicName ?? this.mechanicName,
      nextServiceIntervalKm: nextServiceIntervalKm ?? this.nextServiceIntervalKm,
    );
  }

  /// Total sum of items before any discount or rebate
  double get subtotalUSD {
    return items.fold(0.0, (sum, item) => sum + (item.customUnitPriceUSD * item.quantity));
  }

  /// Total discount on individual items
  double get itemDiscountsUSD {
    return items.fold(0.0, (sum, item) => sum + item.discountUSD);
  }

  /// Total rebate for old battery trade-ins
  double get batteryTradeInRebateUSD {
    return items.fold(0.0, (sum, item) => sum + item.tradeInRebateUSD);
  }

  /// Total discount including overall discount
  double get allDiscountsUSD => itemDiscountsUSD + overallDiscountUSD;

  /// Net total in USD after discounts and trade-in rebates
  double get netTotalUSD {
    final net = subtotalUSD - allDiscountsUSD - batteryTradeInRebateUSD;
    return net > 0 ? net : 0.0;
  }

  /// Net total in KHR at the given exchange rate
  int netTotalKHR(double rate) {
    return CurrencyFormatter.usdToKhr(netTotalUSD, rate);
  }

  /// Total count of physical items/services in cart
  int get totalItemCount {
    return items.fold(0, (count, item) => count + item.quantity);
  }

  bool get isEmpty => items.isEmpty;
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void addToCart(Product product) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);

    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(state.items);
      final current = updatedList[existingIndex];
      updatedList[existingIndex] = current.copyWith(
        quantity: current.quantity + 1,
      );
      state = state.copyWith(items: updatedList);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            product: product,
            quantity: 1,
            tradeInRebateUSD: 0.0,
          ),
        ],
      );
    }
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    state = state.copyWith(
      items: state.items.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(quantity: newQuantity);
        }
        return item;
      }).toList(),
    );
  }

  void updateDiscount(String productId, double discountUSD) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(discountUSD: discountUSD.clamp(0.0, item.customUnitPriceUSD * item.quantity));
        }
        return item;
      }).toList(),
    );
  }

  /// Toggle or set old battery trade-in deduction
  void toggleBatteryTradeIn(String productId) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.product.id == productId && item.product.battery != null) {
          final rebate = item.tradeInRebateUSD > 0
              ? 0.0
              : (item.product.battery!.defaultRebateUSD * item.quantity);
          return item.copyWith(tradeInRebateUSD: rebate);
        }
        return item;
      }).toList(),
    );
  }

  void setOverallDiscount(double discountUSD) {
    state = state.copyWith(overallDiscountUSD: discountUSD >= 0 ? discountUSD : 0.0);
  }

  void setMechanicName(String name) {
    state = state.copyWith(mechanicName: name);
  }

  void setNextServiceInterval(int km) {
    state = state.copyWith(nextServiceIntervalKm: km);
  }

  void clearCart() {
    state = state.copyWith(
      items: [],
      overallDiscountUSD: 0.0,
    );
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
