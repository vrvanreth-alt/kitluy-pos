import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/cart_sidebar.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/pos_header.dart';
import '../widgets/product_grid.dart';

class PosMainScreen extends ConsumerWidget {
  const PosMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            PosHeader(
              onAddProduct: () {
                showDialog(
                  context: context,
                  builder: (ctx) => const AddProductDialog(),
                );
              },
            ),

            // Main Workspace (Products Catalog + Cart Sidebar)
            Expanded(
              child: Row(
                children: [
                  // Left Side: Catalog & Search
                  const Expanded(
                    child: Column(
                      children: [
                        CategoryFilterBar(),
                        Expanded(child: ProductGrid()),
                      ],
                    ),
                  ),

                  // Right Side: Cart & Checkout
                  const CartSidebar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

