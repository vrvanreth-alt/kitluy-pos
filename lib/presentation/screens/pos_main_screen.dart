import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../state/cart_provider.dart';
import '../state/exchange_rate_provider.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/cart_sidebar.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/pos_header.dart';
import '../widgets/pos_navigation_drawer.dart';
import '../widgets/product_grid.dart';

class PosMainScreen extends ConsumerWidget {
  const PosMainScreen({super.key});

  void _openMobileCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.90,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: const CartSidebar(isMobileBottomSheet: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final cart = ref.watch(cartProvider);
    final rate = ref.watch(exchangeRateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const PosNavigationDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (scaffoldContext) {
            return Column(
              children: [
                // Top Navigation Bar (Adaptive for Mobile & Desktop)
                PosHeader(
                  isMobile: isMobile,
                  onOpenDrawer: () => Scaffold.of(scaffoldContext).openDrawer(),
                  onOpenCart: isMobile ? () => _openMobileCart(context) : null,
                  onAddProduct: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const AddProductDialog(),
                    );
                  },
                ),

                // Main Workspace
                Expanded(
                  child: isMobile
                      ? const Column(
                          children: [
                            CategoryFilterBar(),
                            Expanded(child: ProductGrid()),
                          ],
                        )
                      : const Row(
                          children: [
                            // Left Side: Catalog & Search
                            Expanded(
                              child: Column(
                                children: [
                                  CategoryFilterBar(),
                                  Expanded(child: ProductGrid()),
                                ],
                              ),
                            ),

                            // Right Side: Cart Sidebar (Fixed on Desktop/iPad)
                            CartSidebar(),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
      // Floating Bottom Cart Bar for Mobile screens
      bottomNavigationBar: isMobile && !cart.isEmpty
          ? _buildMobileCartBottomBar(context, cart, rate)
          : null,
    );
  }

  Widget _buildMobileCartBottomBar(BuildContext context, CartState cart, double exchangeRate) {
    final totalKHR = cart.netTotalKHR(exchangeRate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Cart badge & Total summary
            Expanded(
              child: InkWell(
                onTap: () => _openMobileCart(context),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_cart, color: AppColors.primary, size: 22),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${cart.totalItemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.formatUSD(cart.netTotalUSD),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cartTotal,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatKHR(totalKHR),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Big Checkout / View Cart Button
            ElevatedButton.icon(
              onPressed: () => _openMobileCart(context),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                'មើលកន្ត្រក (${cart.totalItemCount})',
                style: GoogleFonts.kantumruyPro(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
