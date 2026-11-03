import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../state/exchange_rate_provider.dart';
import '../state/vehicle_provider.dart';
import 'vehicle_selector_dialog.dart';

class PosHeader extends ConsumerWidget {
  final VoidCallback onAddProduct;
  final VoidCallback? onOpenDrawer;
  final bool isMobile;
  final VoidCallback? onOpenCart;

  const PosHeader({
    super.key,
    required this.onAddProduct,
    this.onOpenDrawer,
    this.isMobile = false,
    this.onOpenCart,
  });

  void _showExchangeRateDialog(BuildContext context, WidgetRef ref, double currentRate) {
    final controller = TextEditingController(text: currentRate.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.currency_exchange, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'កំណត់អត្រាប្តូរប្រាក់ (Exchange Rate)',
              style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'អត្រាប្តូរប្រាក់ស្តង់ដារធនាគារជាតិនៃកម្ពុជា (1 USD = ? KHR):',
              style: GoogleFonts.kantumruyPro(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: '1 USD = ',
                suffixText: '៛ (KHR)',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [4050, 4100, 4120, 4150].map((rate) {
                return ActionChip(
                  label: Text('$rate ៛'),
                  onPressed: () {
                    controller.text = rate.toString();
                  },
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
              final newRate = double.tryParse(controller.text);
              if (newRate != null && newRate > 0) {
                ref.read(exchangeRateProvider.notifier).updateRate(newRate);
                Navigator.pop(ctx);
              }
            },
            child: Text('រក្សាទុក', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchangeRate = ref.watch(exchangeRateProvider);
    final activeVehicle = ref.watch(activeVehicleProvider);

    if (isMobile) {
      return Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Menu Drawer Button
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 22),
              onPressed: onOpenDrawer,
            ),

            // Logo & Compact Title
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.car_repair, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) => const VehicleSelectorDialog(),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeVehicle != null ? activeVehicle.plateNumber : AppConstants.appNameKhmer,
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: activeVehicle != null ? AppColors.secondary : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      activeVehicle != null ? activeVehicle.model : '1\$ = ${CurrencyFormatter.formatNumber(exchangeRate)} ៛',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Exchange Rate button
            IconButton(
              icon: const Icon(Icons.currency_exchange, size: 20, color: AppColors.primary),
              tooltip: 'អត្រាប្តូរប្រាក់',
              onPressed: () => _showExchangeRateDialog(context, ref, exchangeRate),
            ),

            // Vehicle Picker button
            IconButton(
              icon: Icon(
                Icons.directions_car,
                size: 20,
                color: activeVehicle != null ? AppColors.secondary : AppColors.textSecondary,
              ),
              tooltip: 'ឡាន / ស្លាកលេខ',
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => const VehicleSelectorDialog(),
              ),
            ),

            // Add Product icon button
            IconButton(
              icon: const Icon(Icons.add_circle, size: 22, color: AppColors.secondary),
              tooltip: 'ថែមទំនិញ',
              onPressed: onAddProduct,
            ),
          ],
        ),
      );
    }

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Drawer Menu Button
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 24),
              tooltip: 'ម៉ឺនុយប្រព័ន្ធ (Main Menu)',
              onPressed: onOpenDrawer,
            ),
            const SizedBox(width: 4),

            // Logo & Shop Name
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.car_repair, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.defaultShopNameKh,
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${AppConstants.appName} • ${AppConstants.defaultShopNameEn}',
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 24),

            // Exchange Rate Pill (Clickable)
            InkWell(
              onTap: () => _showExchangeRateDialog(context, ref, exchangeRate),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Blue 50
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.currency_exchange, size: 15, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '1\$ = ${CurrencyFormatter.formatNumber(exchangeRate)} ៛',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 12, color: AppColors.primaryLight),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Active Vehicle / License Plate Pill (Clickable)
            InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (ctx) => const VehicleSelectorDialog(),
              ),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: activeVehicle != null
                      ? const Color(0xFFECFDF5) // Emerald 50
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activeVehicle != null
                        ? const Color(0xFFA7F3D0)
                        : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 15,
                      color: activeVehicle != null ? AppColors.secondary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activeVehicle != null
                          ? '${activeVehicle.plateNumber} (${activeVehicle.model})'
                          : 'ជ្រើសរើសឡាន / ស្លាកលេខ',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: activeVehicle != null ? const Color(0xFF065F46) : AppColors.textSecondary,
                      ),
                    ),
                    if (activeVehicle != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${CurrencyFormatter.formatNumber(activeVehicle.currentMileage)} km',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Add Product Quick Button
            ElevatedButton.icon(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add_box, size: 16),
              label: Text(
                'ថែមទំនិញ',
                style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
