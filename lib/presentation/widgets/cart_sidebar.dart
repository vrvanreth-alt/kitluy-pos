import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../state/cart_provider.dart';
import '../state/exchange_rate_provider.dart';
import '../state/vehicle_provider.dart';
import 'checkout_dialog.dart';

class CartSidebar extends ConsumerWidget {
  final bool isMobileBottomSheet;

  const CartSidebar({super.key, this.isMobileBottomSheet = false});

  void _showDiscountDialog(BuildContext context, WidgetRef ref, double currentDiscount) {
    final controller = TextEditingController(text: currentDiscount > 0 ? currentDiscount.toString() : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('បញ្ចុះតម្លៃសរុប (Overall Discount)', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [2, 5, 10, 20].map((d) {
                return ActionChip(
                  label: Text('\$$d'),
                  onPressed: () => controller.text = d.toString(),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: GoogleFonts.kantumruyPro(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final discount = double.tryParse(controller.text) ?? 0.0;
              ref.read(cartProvider.notifier).setOverallDiscount(discount);
              Navigator.pop(ctx);
            },
            child: Text('យល់ព្រម', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final exchangeRate = ref.watch(exchangeRateProvider);
    final vehicle = ref.watch(activeVehicleProvider);

    final totalKHR = cart.netTotalKHR(exchangeRate);

    return Container(
      width: isMobileBottomSheet ? double.infinity : 420,
      decoration: BoxDecoration(
        color: Colors.white,
        border: isMobileBottomSheet
            ? null
            : const Border(
                left: BorderSide(color: AppColors.cardBorder, width: 1),
              ),
      ),
      child: Column(
        children: [
          if (isMobileBottomSheet)
            Container(
              color: AppColors.cartHeader,
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

          // Header: Cart Title & Vehicle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.cartHeader,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (isMobileBottomSheet) ...[
                            IconButton(
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 26),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              'វិក្កយបត្រលក់ (Order Cart)',
                              style: GoogleFonts.kantumruyPro(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${cart.totalItemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (!cart.isEmpty)
                      IconButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                        },
                        tooltip: 'សម្អាតទំនិញទាំងអស់ (Clear)',
                        icon: const Icon(Icons.delete_sweep, color: Color(0xFFF87171), size: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Vehicle & Mechanic info row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, color: Color(0xFF38BDF8), size: 15),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          vehicle != null
                              ? '${vehicle.plateNumber} • ${vehicle.model}'
                              : 'មិនទាន់ជ្រើសរើសឡាន (Walk-in)',
                          style: GoogleFonts.kantumruyPro(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cart.mechanicName,
                        style: GoogleFonts.kantumruyPro(
                          color: const Color(0xFFFBBF24),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Cart Items List
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.remove_shopping_cart, size: 56, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          'មិនទាន់មានទំនិញក្នុងកន្ត្រកទេ',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'សូមចុចលើទំនិញនៅខាងឆ្វេងដើម្បីបន្ថែម',
                          style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final isBattery = item.product.battery != null;
                      final hasTradeIn = item.tradeInRebateUSD > 0;

                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Delete
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.nameKh,
                                        style: GoogleFonts.kantumruyPro(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        item.product.attributeSummary,
                                        style: GoogleFonts.kantumruyPro(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
                                  onPressed: () {
                                    ref.read(cartProvider.notifier).removeFromCart(item.product.id);
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),

                            // If battery: Trade-in rebate button
                            if (isBattery) ...[
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () {
                                  ref.read(cartProvider.notifier).toggleBatteryTradeIn(item.product.id);
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: hasTradeIn ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: hasTradeIn ? const Color(0xFF22C55E) : AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        hasTradeIn ? Icons.check_circle : Icons.swap_horizontal_circle,
                                        size: 14,
                                        color: hasTradeIn ? const Color(0xFF16A34A) : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        hasTradeIn
                                            ? 'បានកាត់ថ្លៃអាគុយចាស់: -\$${item.tradeInRebateUSD.toInt()}'
                                            : 'កាត់ថ្លៃអាគុយចាស់ (-\$${item.product.battery!.defaultRebateUSD.toInt()})',
                                        style: GoogleFonts.kantumruyPro(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: hasTradeIn ? const Color(0xFF15803D) : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 8),

                            // Quantity controls & Line Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Quantity Stepper
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          ref.read(cartProvider.notifier).updateQuantity(
                                                item.product.id,
                                                item.quantity - 1,
                                              );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Icon(Icons.remove, size: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          ref.read(cartProvider.notifier).updateQuantity(
                                                item.product.id,
                                                item.quantity + 1,
                                              );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Icon(Icons.add, size: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Line price
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatUSD(item.lineTotalUSD),
                                      style: GoogleFonts.kantumruyPro(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      '@ ${CurrencyFormatter.formatUSD(item.customUnitPriceUSD)}',
                                      style: GoogleFonts.kantumruyPro(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Dual-Currency Calculation Summary Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.cardBorder, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('សរុបរង (Subtotal):', style: GoogleFonts.kantumruyPro(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      CurrencyFormatter.formatUSD(cart.subtotalUSD),
                      style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                // Battery Trade-In deduction
                if (cart.batteryTradeInRebateUSD > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('កាត់ថ្លៃអាគុយចាស់ (Rebate):', style: GoogleFonts.kantumruyPro(fontSize: 13, color: const Color(0xFF16A34A))),
                      Text(
                        '-${CurrencyFormatter.formatUSD(cart.batteryTradeInRebateUSD)}',
                        style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                ],

                // Overall Discount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _showDiscountDialog(context, ref, cart.overallDiscountUSD),
                      child: Row(
                        children: [
                          Text('បញ្ចុះតម្លៃ (Discount):', style: GoogleFonts.kantumruyPro(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 12, color: AppColors.primaryLight),
                        ],
                      ),
                    ),
                    Text(
                      cart.overallDiscountUSD > 0 ? '-${CurrencyFormatter.formatUSD(cart.overallDiscountUSD)}' : '\$0.00',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cart.overallDiscountUSD > 0 ? AppColors.danger : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),

                // Large Dual Currency Total Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cartTotalLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'សរុបត្រូវទូទាត់ (TOTAL):',
                              style: GoogleFonts.kantumruyPro(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.cartTotal,
                              ),
                            ),
                            Text(
                              '1\$ = ${CurrencyFormatter.formatNumber(exchangeRate)} ៛',
                              style: GoogleFonts.kantumruyPro(
                                fontSize: 11,
                                color: const Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.formatUSD(cart.netTotalUSD),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.cartTotal,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatKHR(totalKHR),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: cart.isEmpty
                        ? null
                        : () {
                            if (isMobileBottomSheet) {
                              Navigator.pop(context);
                            }
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const CheckoutDialog(),
                            );
                          },
                    icon: const Icon(Icons.payment, size: 20),
                    label: Text(
                      'គិតលុយ (Checkout) • ${CurrencyFormatter.formatUSD(cart.netTotalUSD)}',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
