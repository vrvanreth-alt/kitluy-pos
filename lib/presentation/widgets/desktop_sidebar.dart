import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/theme_helper.dart';
import '../state/customer_debt_provider.dart';
import '../state/product_provider.dart';
import '../state/staff_provider.dart';
import '../state/supplier_debt_provider.dart';
import '../state/theme_provider.dart';
import 'pin_login_dialog.dart';

class DesktopSidebar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;
  final VoidCallback onOpenGarage;
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenServices;
  final VoidCallback onOpenCustomerDebt;
  final VoidCallback onOpenSupplierDebt;
  final VoidCallback onOpenReport;
  final VoidCallback onOpenStaff;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.onOpenGarage,
    required this.onOpenInventory,
    required this.onOpenServices,
    required this.onOpenCustomerDebt,
    required this.onOpenSupplierDebt,
    required this.onOpenReport,
    required this.onOpenStaff,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final lowStockCount = products.where((p) => p.isLowStock).length;
    final totalCustDebt = ref.watch(totalCustomerDebtOutstandingProvider);
    final totalSupDebt = ref.watch(totalSupplierDebtOutstandingProvider);
    final isCloudConnected = FirebaseService.isInitialized;
    final currentStaff = ref.watch(currentStaffProvider);
    final isDark = context.isDark;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          right: BorderSide(color: context.borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // 1. Logo & App Branding Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.car_repair, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appNameKhmer,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      Text(
                        'Automotive POS Web',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 11,
                          color: context.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: context.borderColor),
          const SizedBox(height: 12),

          // 2. Navigation Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 6),
                    child: Text(
                      'មឺនុយមេ (MAIN MENU)',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: context.textMutedColor,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    context: context,
                    index: 0,
                    icon: Icons.storefront_rounded,
                    labelKh: 'ផ្ទាំងលក់ទំនិញ (POS)',
                    isSelected: selectedIndex == 0,
                    onTap: () => onSelectIndex(0),
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    icon: Icons.directions_car_rounded,
                    labelKh: 'យានដ្ឋាន & ឡាន',
                    isSelected: selectedIndex == 1,
                    onTap: onOpenGarage,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    icon: Icons.inventory_2_rounded,
                    labelKh: 'ស្តុកទំនិញ',
                    badgeCount: lowStockCount,
                    isSelected: selectedIndex == 2,
                    onTap: onOpenInventory,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    icon: Icons.handyman_rounded,
                    labelKh: 'សេវាកម្មជួសជុល',
                    isSelected: selectedIndex == 3,
                    onTap: onOpenServices,
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 6),
                    child: Text(
                      'ហិរញ្ញវត្ថុ & បំណុល (FINANCE)',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: context.textMutedColor,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    context: context,
                    index: 4,
                    icon: Icons.account_balance_wallet_rounded,
                    labelKh: 'បំណុលអតិថិជន',
                    badgeText: totalCustDebt > 0 ? '\$${totalCustDebt.toStringAsFixed(0)}' : null,
                    badgeColor: AppColors.danger,
                    isSelected: selectedIndex == 4,
                    onTap: onOpenCustomerDebt,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 5,
                    icon: Icons.business_center_rounded,
                    labelKh: 'បំណុលក្រុមហ៊ុន',
                    badgeText: totalSupDebt > 0 ? '\$${totalSupDebt.toStringAsFixed(0)}' : null,
                    badgeColor: AppColors.warning,
                    isSelected: selectedIndex == 5,
                    onTap: onOpenSupplierDebt,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 6,
                    icon: Icons.assessment_rounded,
                    labelKh: 'របាយការណ៍បិទបញ្ជី',
                    isSelected: selectedIndex == 6,
                    onTap: onOpenReport,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 7,
                    icon: Icons.shield_rounded,
                    labelKh: 'បុគ្គលិក & សិទ្ធិ',
                    isSelected: selectedIndex == 7,
                    onTap: onOpenStaff,
                  ),
                ],
              ),
            ),
          ),

          // 3. Dark/Light Theme Switcher & Cashier Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surfaceMutedColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cashier Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: currentStaff.avatarColor,
                      child: Text(
                        currentStaff.nameKh.substring(0, 1),
                        style: GoogleFonts.kantumruyPro(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentStaff.nameKh,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          Text(
                            currentStaff.role.titleKh.split(' ')[0],
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 11,
                              color: currentStaff.role.roleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'ប្តូរបុគ្គលិក (Switch PIN)',
                      icon: const Icon(Icons.lock_reset, size: 18),
                      color: context.textSecondaryColor,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const PinLoginDialog(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(height: 1, color: context.borderColor),
                const SizedBox(height: 8),

                // Theme Mode Switch & Cloud Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cloud Status
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCloudConnected ? AppColors.success : AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isCloudConnected ? 'Cloud Sync' : 'Offline',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 11,
                            color: context.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Theme Toggle Button
                    InkWell(
                      onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              size: 14,
                              color: isDark ? AppColors.accent : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isDark ? 'Light' : 'Dark',
                              style: GoogleFonts.kantumruyPro(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String labelKh,
    int? badgeCount,
    String? badgeText,
    Color? badgeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Material(
        color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? activeColor.withValues(alpha: 0.35) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? activeColor : context.textSecondaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    labelKh,
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? activeColor : context.textPrimaryColor,
                    ),
                  ),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeColor ?? AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
