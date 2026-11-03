import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../state/product_provider.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'រកមិនឃើញទំនិញដែលស្វែងរកទេ',
              style: GoogleFonts.kantumruyPro(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'សូមសាកល្បងស្វែងរកតាមពាក្យគន្លឹះផ្សេង (ឧ. Michelin, 5W-30, 70Ah, 04152)',
              style: GoogleFonts.kantumruyPro(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int crossAxisCount;
        final double childAspectRatio;

        if (width < 450) {
          crossAxisCount = 2;
          childAspectRatio = 0.68;
        } else if (width < 750) {
          crossAxisCount = 2;
          childAspectRatio = 0.74;
        } else if (width < 1100) {
          crossAxisCount = 3;
          childAspectRatio = 0.78;
        } else {
          crossAxisCount = (width / 220).floor().clamp(3, 6);
          childAspectRatio = 0.78;
        }

        return GridView.builder(
          padding: EdgeInsets.all(width < 500 ? 10 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: width < 500 ? 8 : 12,
            mainAxisSpacing: width < 500 ? 8 : 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        );
      },
    );
  }
}
