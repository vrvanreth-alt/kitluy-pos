import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_helper.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/product.dart';
import '../state/cart_provider.dart';
import '../state/exchange_rate_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchangeRate = ref.watch(exchangeRateProvider);
    final khrPrice = CurrencyFormatter.usdToKhr(product.unitPriceUSD, exchangeRate);
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: product.isLowStock ? AppColors.warning : context.borderColor,
          width: product.isLowStock ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(cartProvider.notifier).addToCart(product);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text('បានបន្ថែម: ${product.nameKh}')),
                  ],
                ),
                duration: const Duration(milliseconds: 600),
                backgroundColor: AppColors.primaryDark,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                width: 320,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Category Pill & Stock Status Indicator
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: product.category.tagColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(product.category.icon, size: 11, color: product.category.tagColor),
                          const SizedBox(width: 4),
                          Text(
                            product.category.titleKh,
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: product.category.tagColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stock indicator with dot
                    if (product.category != ProductCategory.services)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.isLowStock
                              ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))
                              : context.surfaceMutedColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: product.isLowStock
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.isLowStock
                                  ? 'ជិតអស់ (${product.stockQuantity})'
                                  : '${product.stockQuantity} ${product.unit}',
                              style: GoogleFonts.kantumruyPro(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: product.isLowStock
                                    ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309))
                                    : context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Product Name (Khmer & English)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nameKh,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimaryColor,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.nameEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 11,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Auto Attribute Chip (Size, Viscosity, Ah, OEM)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.surfaceMutedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Text(
                    product.attributeSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ),

                // Battery Trade-in rebate preview if applicable
                if (product.battery != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.swap_horizontal_circle, size: 12, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'កាត់អាគុយចាស់: -\$${product.battery!.defaultRebateUSD.toInt()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),
                Divider(height: 1, color: context.borderColor),
                const SizedBox(height: 8),

                // Price in USD & KHR + Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.formatUSD(product.unitPriceUSD),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.formatKHR(khrPrice),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Modern Add Button Pill
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_shopping_cart, size: 16, color: AppColors.primaryLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
