import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_helper.dart';
import '../../data/models/product.dart';
import '../state/product_provider.dart';

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final allProducts = ref.watch(productsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          bottom: BorderSide(color: context.borderColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Barcode Scan Bar
          SizedBox(
            height: 44,
            child: TextField(
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).setQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'ស្វែងរកឈ្មោះ, ស្លាកលេខ, ទំហំកង់ (215/55), អាគុយ (70Ah), ប្រេង (5W-30), OEM...',
                hintStyle: GoogleFonts.kantumruyPro(fontSize: 13, color: context.textMutedColor),
                prefixIcon: Icon(Icons.search, size: 20, color: context.textSecondaryColor),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (searchQuery.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, size: 18, color: context.textSecondaryColor),
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).setQuery('');
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner, color: AppColors.primaryLight, size: 20),
                      tooltip: 'ស្កេនបាកូដទំនិញ (Scan Barcode)',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'ឧបករណ៍ស្កេនបាកូដ USB/Camera ត្រៀមរួចរាល់!',
                              style: GoogleFonts.kantumruyPro(),
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            width: 320,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                fillColor: context.surfaceMutedColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Category Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ProductCategory.values.map((category) {
                final isSelected = selectedCategory == category;
                final count = category == ProductCategory.all
                    ? allProducts.length
                    : allProducts.where((p) => p.category == category).length;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).select(category);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.tagColor
                            : context.surfaceMutedColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? category.tagColor : context.borderColor,
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: category.tagColor.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 16,
                            color: isSelected ? Colors.white : context.textSecondaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.titleKh,
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : context.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : (context.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: GoogleFonts.kantumruyPro(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : context.textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
