import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_helper.dart';
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
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('បញ្ចុះតម្លៃសរុប (Overall Discount)', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
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
            child: Text('បោះបង់', style: GoogleFonts.kantumruyPro(color: context.textSecondaryColor)),
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
    final isDark = context.isDark;

    final totalKHR = cart.netTotalKHR(exchangeRate);

    return Container(
      width: isMobileBottomSheet ? double.infinity : 420,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: isMobileBottomSheet
            ? null
            : Border(
                left: BorderSide(color: context.borderColor, width: 1),
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
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (cart.items.isNotEmpty)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFCA5A5),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.delete_sweep, size: 16),
                        label: Text(
                          'សម្អាត',
                          style: GoogleFonts.kantumruyPro(fontSize: 12),
                        ),
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Vehicle Tag in Cart Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, size: 14, color: Color(0xFF6EE7B7)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          vehicle != null
                              ? '${vehicle.plateNumber} • ${vehicle.model}'
                              : 'មិនទាន់ភ្ជាប់រថយន្ត (Walk-in Customer)',
                          style: GoogleFonts.kantumruyPro(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: vehicle != null ? const Color(0xFF047857) : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vehicle != null ? 'បានភ្ជាប់' : 'បណ្តោះអាសន្ន',
                          style: GoogleFonts.kantumruyPro(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_shopping_cart_outlined,
                          size: 56,
                          color: context.textMutedColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'មិនទាន់មានទំនិញក្នុងកន្ត្រកទេ',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'សូមចុចលើទំនិញនៅខាងឆ្វេងដើម្បីបន្ថែម',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 12,
                            color: context.textMutedColor,
                          ),
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
                      final hasTradeIn = item.hasTradeIn;

                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.surfaceMutedColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: context.textPrimaryColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '\$${item.product.unitPriceUSD.toStringAsFixed(2)} / ${item.product.unit}',
                                        style: GoogleFonts.kantumruyPro(
                                          fontSize: 11,
                                          color: context.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    ref.read(cartProvider.notifier).removeFromCart(item.product.id);
                                  },
                                ),
                              ],
                            ),

                            // Battery Trade-In Rebate Toggle
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
                                    color: hasTradeIn ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7)) : context.surfaceColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: hasTradeIn ? const Color(0xFF22C55E) : context.borderColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        hasTradeIn ? Icons.check_circle : Icons.swap_horizontal_circle,
                                        size: 14,
                                        color: hasTradeIn ? const Color(0xFF16A34A) : context.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        hasTradeIn
                                            ? 'បានកាត់ថ្លៃអាគុយចាស់: -\$${item.tradeInRebateUSD.toInt()}'
                                            : 'កាត់ថ្លៃអាគុយចាស់ (-\$${item.product.battery!.defaultRebateUSD.toInt()})',
                                        style: GoogleFonts.kantumruyPro(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: hasTradeIn ? (isDark ? Colors.white : const Color(0xFF15803D)) : context.textPrimaryColor,
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
                                    color: context.surfaceColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: context.borderColor),
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
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimaryColor),
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

                                // Line Total
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatUSD(item.netTotalUSD),
                                      style: GoogleFonts.kantumruyPro(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: context.primaryAccent,
                                      ),
                                    ),
                                    if (item.hasTradeIn)
                                      Text(
                                        'កាត់: -\$${item.tradeInRebateUSD.toInt()}',
                                        style: GoogleFonts.kantumruyPro(
                                          fontSize: 10,
                                          color: const Color(0xFF16A34A),
                                          fontWeight: FontWeight.bold,
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

          // Footer: Totals & Checkout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border(
                top: BorderSide(color: context.borderColor, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('សរុបរង (Subtotal):', style: GoogleFonts.kantumruyPro(fontSize: 13, color: context.textSecondaryColor)),
                    Text(
                      CurrencyFormatter.formatUSD(cart.subtotalUSD),
                      style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
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
                          Text('បញ្ចុះតម្លៃ (Discount):', style: GoogleFonts.kantumruyPro(fontSize: 13, color: context.textSecondaryColor)),
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
                        color: cart.overallDiscountUSD > 0 ? AppColors.danger : context.textPrimaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Divider(color: context.borderColor),
                const SizedBox(height: 8),

                // Large Dual Currency Total Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : AppColors.cartTotalLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0)),
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
                                color: isDark ? const Color(0xFF34D399) : AppColors.cartTotal,
                              ),
                            ),
                            Text(
                              '1\$ = ${CurrencyFormatter.formatNumber(exchangeRate)} ៛',
                              style: GoogleFonts.kantumruyPro(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
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
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.cartTotal,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatKHR(totalKHR),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
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
                  child: ElevatedButton(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (ctx) => const CheckoutDialog(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cart.items.isEmpty ? null : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'គិតលុយ (Checkout) • ${CurrencyFormatter.formatUSD(cart.netTotalUSD)}',
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
