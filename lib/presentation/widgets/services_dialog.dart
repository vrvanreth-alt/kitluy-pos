import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_helper.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/product.dart';
import '../state/cart_provider.dart';
import '../state/exchange_rate_provider.dart';
import '../state/product_provider.dart';

class ServicesDialog extends ConsumerStatefulWidget {
  const ServicesDialog({super.key});

  @override
  ConsumerState<ServicesDialog> createState() => _ServicesDialogState();
}

class _ServicesDialogState extends ConsumerState<ServicesDialog> {
  String _searchQuery = '';

  void _showAddCustomServiceDialog(BuildContext context) {
    final nameKhCtrl = TextEditingController();
    final nameEnCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.serviceColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.handyman, color: AppColors.serviceColor),
            ),
            const SizedBox(width: 10),
            Text(
              'បង្កើតសេវាកម្មជួសជុលថ្មី',
              style: GoogleFonts.kantumruyPro(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel(context, 'ឈ្មោះសេវាកម្ម (ខ្មែរ) *'),
              TextField(
                controller: nameKhCtrl,
                decoration: const InputDecoration(hintText: 'ឧ. សេវាត្រួតពិនិត្យប្រព័ន្ធភ្លើង'),
              ),
              const SizedBox(height: 12),
              _buildFieldLabel(context, 'ឈ្មោះសេវាកម្ម (English)'),
              TextField(
                controller: nameEnCtrl,
                decoration: const InputDecoration(hintText: 'Electrical Diagnostic Service'),
              ),
              const SizedBox(height: 12),
              _buildFieldLabel(context, 'ថ្លៃឈ្នួលសេវា (\$ USD) *'),
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0.00',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: GoogleFonts.kantumruyPro(color: context.textMutedColor)),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceCtrl.text);
              if (nameKhCtrl.text.trim().isNotEmpty && price != null && price > 0) {
                final newService = Product(
                  id: 'S-${DateTime.now().millisecondsSinceEpoch % 1000}',
                  code: 'SRV-CUSTOM-${DateTime.now().millisecondsSinceEpoch % 100}',
                  nameKh: nameKhCtrl.text.trim(),
                  nameEn: nameEnCtrl.text.trim().isEmpty ? nameKhCtrl.text.trim() : nameEnCtrl.text.trim(),
                  category: ProductCategory.services,
                  unitPriceUSD: price,
                  stockQuantity: 999,
                  unit: 'ដង',
                );

                ref.read(productsProvider.notifier).addProduct(newService);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('បានបន្ថែមសេវាកម្មជោគជ័យ!', style: GoogleFonts.kantumruyPro()),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text('រក្សាទុក', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.kantumruyPro(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.textPrimaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final rate = ref.watch(exchangeRateProvider);

    final services = products
        .where((p) => p.category == ProductCategory.services)
        .where((p) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return p.nameKh.toLowerCase().contains(q) || p.nameEn.toLowerCase().contains(q) || p.code.toLowerCase().contains(q);
        })
        .toList();

    return Dialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 820,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.serviceColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.handyman, color: AppColors.serviceColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'សេវាកម្មជួសជុល & ថ្លៃឈ្នួលជាង (Automotive Services)',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          'Labor & Diagnostic Services • មិនកាត់ស្តុកទំនិញ',
                          style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textMutedColor),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddCustomServiceDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('+ សេវាថ្មី', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: context.textMutedColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ស្វែងរកឈ្មោះសេវាកម្ម, កូដសេវា...',
                prefixIcon: Icon(Icons.search, color: context.textMutedColor),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Services Grid / List
            Expanded(
              child: services.isEmpty
                  ? Center(
                      child: Text(
                        'មិនមានសេវាកម្មត្រូវនឹងការស្វែងរកទេ!',
                        style: GoogleFonts.kantumruyPro(fontSize: 15, color: context.textSecondaryColor),
                      ),
                    )
                  : ListView.separated(
                      itemCount: services.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final service = services[index];
                        final priceKHR = service.unitPriceUSD * rate;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.surfaceMutedColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.serviceColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.build_circle, color: AppColors.serviceColor, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.nameKh,
                                      style: GoogleFonts.kantumruyPro(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${service.nameEn} • កូដ៖ ${service.code}',
                                      style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textSecondaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${service.unitPriceUSD.toStringAsFixed(2)}',
                                    style: GoogleFonts.kantumruyPro(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.formatKHR(priceKHR),
                                    style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textSecondaryColor),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref.read(cartProvider.notifier).addToCart(service);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('បានបញ្ចូល៖ ${service.nameKh} ទៅកន្ត្រក!', style: GoogleFonts.kantumruyPro()),
                                      backgroundColor: AppColors.success,
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                                icon: const Icon(Icons.add_shopping_cart, size: 16),
                                label: Text('+ កន្ត្រក', style: GoogleFonts.kantumruyPro(fontSize: 12)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
