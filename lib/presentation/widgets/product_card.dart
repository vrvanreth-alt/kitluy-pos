import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
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

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: product.isLowStock ? AppColors.warning : AppColors.cardBorder,
          width: product.isLowStock ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          ref.read(cartProvider.notifier).addToCart(product);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('បានបន្ថែម: ${product.nameKh}'),
              duration: const Duration(milliseconds: 600),
              backgroundColor: AppColors.primaryDark,
              behavior: SnackBarBehavior.floating,
              width: 320,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category Tag & Stock Status
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.category.tagColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
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

                  // Stock indicator
                  if (product.category != ProductCategory.services)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.isLowStock
                            ? const Color(0xFFFEF3C7) // Amber 100
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.isLowStock
                            ? 'ជិតអស់ (${product.stockQuantity})'
                            : 'ស្តុក: ${product.stockQuantity}',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: product.isLowStock ? const Color(0xFFB45309) : AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Product Name (Khmer)
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
                        color: AppColors.textPrimary,
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
                        color: AppColors.textSecondary,
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
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  product.attributeSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),

              // Battery Trade-in note if applicable
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
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Price in USD & KHR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CurrencyFormatter.formatUSD(product.unitPriceUSD),
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatKHR(khrPrice),
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Add button pill
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_shopping_cart, size: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
