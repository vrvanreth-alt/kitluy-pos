import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/theme_helper.dart';
import '../../core/utils/currency_formatter.dart';
import '../state/exchange_rate_provider.dart';
import '../state/staff_provider.dart';
import '../state/theme_provider.dart';
import '../state/vehicle_provider.dart';
import 'pin_login_dialog.dart';
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
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.currency_exchange, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'កំណត់អត្រាប្តូរប្រាក់ (Exchange Rate)',
              style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'អត្រាប្តូរប្រាក់ស្តង់ដារធនាគារជាតិនៃកម្ពុជា (1 USD = ? KHR):',
              style: GoogleFonts.kantumruyPro(fontSize: 14, color: context.textSecondaryColor),
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
            child: Text('បោះបង់', style: GoogleFonts.kantumruyPro(color: context.textMutedColor)),
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
    final currentStaff = ref.watch(currentStaffProvider);
    final isDark = context.isDark;

    if (isMobile) {
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          border: Border(
            bottom: BorderSide(color: context.borderColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            if (onOpenDrawer != null)
              IconButton(
                icon: Icon(Icons.menu, color: context.textPrimaryColor, size: 22),
                onPressed: onOpenDrawer,
              ),

            // Staff Avatar with quick PIN switcher
            InkWell(
              onTap: () => showDialog(context: context, builder: (_) => const PinLoginDialog()),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: currentStaff.avatarColor,
                      child: Text(
                        currentStaff.nameKh.substring(0, 1),
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.lock_open, size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Vehicle Picker Compact Button
            Expanded(
              child: InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) => const VehicleSelectorDialog(),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: activeVehicle != null ? const Color(0xFFECFDF5) : context.surfaceMutedColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: activeVehicle != null ? const Color(0xFFA7F3D0) : context.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 14,
                        color: activeVehicle != null ? AppColors.secondary : context.textSecondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          activeVehicle != null ? activeVehicle.plateNumber : 'ជ្រើសរើសឡាន',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: activeVehicle != null ? const Color(0xFF065F46) : context.textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Theme Switcher Button
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                size: 20,
                color: isDark ? AppColors.accent : context.textSecondaryColor,
              ),
              onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            ),

            // Add Product Button
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
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          bottom: BorderSide(color: context.borderColor, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // If drawer is enabled (tablet mode)
            if (onOpenDrawer != null) ...[
              IconButton(
                icon: Icon(Icons.menu, color: context.textPrimaryColor, size: 24),
                tooltip: 'ម៉ឺនុយប្រព័ន្ធ (Main Menu)',
                onPressed: onOpenDrawer,
              ),
              const SizedBox(width: 8),
            ],

            // Shop Title
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.defaultShopNameKh,
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  '${AppConstants.appName} • ${AppConstants.defaultShopNameEn}',
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 11,
                    color: context.textSecondaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 24),

            // 1. Exchange Rate Pill
          InkWell(
            onTap: () => _showExchangeRateDialog(context, ref, exchangeRate),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.3) : const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.currency_exchange, size: 15, color: AppColors.primaryLight),
                  const SizedBox(width: 6),
                  Text(
                    '1\$ = ${CurrencyFormatter.formatNumber(exchangeRate)} ៛',
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 12, color: AppColors.primaryLight),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 2. Active Vehicle Pill
          InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => const VehicleSelectorDialog(),
            ),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: activeVehicle != null
                    ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                    : context.surfaceMutedColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: activeVehicle != null
                      ? (isDark ? const Color(0xFF10B981) : const Color(0xFFA7F3D0))
                      : context.borderColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 15,
                    color: activeVehicle != null ? AppColors.secondary : context.textSecondaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    activeVehicle != null
                        ? '${activeVehicle.plateNumber} (${activeVehicle.model})'
                        : 'ជ្រើសរើសឡាន / ស្លាកលេខ',
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: activeVehicle != null
                          ? (isDark ? Colors.white : const Color(0xFF065F46))
                          : context.textSecondaryColor,
                    ),
                  ),
                  if (activeVehicle != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF047857) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${CurrencyFormatter.formatNumber(activeVehicle.currentMileage)} km',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 16, color: context.textSecondaryColor),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 3. Current Staff Chip (Interactive PIN Switch)
          InkWell(
            onTap: () => showDialog(context: context, builder: (_) => const PinLoginDialog()),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.surfaceMutedColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: currentStaff.avatarColor,
                    child: Text(
                      currentStaff.nameKh.substring(0, 1),
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentStaff.nameKh,
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: currentStaff.role.roleColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentStaff.role.titleKh.split(' ')[0],
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: currentStaff.role.roleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.lock_outline, size: 14, color: context.textMutedColor),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 4. Dark / Light Mode Toggle Button
          IconButton(
            tooltip: isDark ? 'ប្តូរទៅ Light Mode' : 'ប្តូរទៅ Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? AppColors.accent : AppColors.primary,
              size: 20,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(width: 4),

          // 5. Add Product Button
          ElevatedButton.icon(
            onPressed: onAddProduct,
            icon: const Icon(Icons.add_box, size: 16),
            label: Text(
              'ថែមទំនិញ',
              style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              backgroundColor: AppColors.secondary,
            ),
          ),
        ],
      ),
    ),
  );
}
}
