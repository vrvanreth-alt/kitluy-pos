import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/cart_sidebar.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/pos_header.dart';
import '../widgets/pos_navigation_drawer.dart';
import '../widgets/product_grid.dart';

class PosMainScreen extends ConsumerWidget {
  const PosMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const PosNavigationDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (scaffoldContext) {
            return Column(
              children: [
                // Top Navigation Bar with Menu Drawer toggle
                PosHeader(
                  onOpenDrawer: () => Scaffold.of(scaffoldContext).openDrawer(),
                  onAddProduct: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const AddProductDialog(),
                    );
                  },
                ),

                // Main Workspace (Products Catalog + Cart Sidebar)
                const Expanded(
                  child: Row(
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

                      // Right Side: Cart & Checkout
                      CartSidebar(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

