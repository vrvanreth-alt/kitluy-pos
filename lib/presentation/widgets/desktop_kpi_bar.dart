import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../state/exchange_rate_provider.dart';
import '../state/product_provider.dart';
import '../state/vehicle_provider.dart';

class DesktopKpiBar extends ConsumerWidget {
  final VoidCallback onOpenVehicle;
  final VoidCallback onOpenLowStock;
  final VoidCallback onEditExchangeRate;

  const DesktopKpiBar({
    super.key,
    required this.onOpenVehicle,
    required this.onOpenLowStock,
    required this.onEditExchangeRate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchangeRate = ref.watch(exchangeRateProvider);
    final activeVehicle = ref.watch(activeVehicleProvider);
    final products = ref.watch(productsProvider);
    final lowStockItems = products.where((p) => p.isLowStock).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 950;

          return Row(
            children: [
              // 1. KPI: Today's Revenue (High Contrast Indigo like reference)
              Expanded(
                child: _buildMetricCard(
                  title: 'ការលក់សរុបថ្ងៃនេះ',
                  value: '\$1,250.00',
                  subtitle: '5,125,000 ៛ • 12 វិក្កយបត្រ',
                  icon: Icons.trending_up,
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF2563EB),
                  badgeText: '+14% ពីម្សិលមិញ',
                  badgeColor: const Color(0xFF10B981),
                  badgeBg: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 14),

              // 2. KPI: Active Vehicle
              Expanded(
                child: _buildMetricCard(
                  title: 'យានយន្តកំពុងជួសជុល',
                  value: activeVehicle != null ? activeVehicle.plateNumber : 'ជ្រើសរើសឡាន',
                  subtitle: activeVehicle != null
                      ? '${activeVehicle.model} (${CurrencyFormatter.formatNumber(activeVehicle.currentMileage)} km)'
                      : 'ចុចដើម្បីជ្រើសរើសស្លាកលេខ',
                  icon: Icons.directions_car_filled,
                  iconBg: const Color(0xFFECFDF5),
                  iconColor: const Color(0xFF059669),
                  onTap: onOpenVehicle,
                  badgeText: activeVehicle != null ? 'សកម្ម (Active)' : 'Walk-in',
                  badgeColor: const Color(0xFF059669),
                  badgeBg: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 14),

              // 3. KPI: Low Stock Warning
              Expanded(
                child: _buildMetricCard(
                  title: 'ស្ថានភាពស្តុកទំនិញ',
                  value: lowStockItems.isNotEmpty ? '${lowStockItems.length} មុខជិតអស់' : 'ស្តុកគ្រប់គ្រាន់',
                  subtitle: lowStockItems.isNotEmpty ? 'Michelin, GS, Motul...' : 'ទំនិញទាំងអស់មានក្នុងស្តុក',
                  icon: Icons.warning_amber_rounded,
                  iconBg: const Color(0xFFFFFBEB),
                  iconColor: const Color(0xFFD97706),
                  onTap: onOpenLowStock,
                  badgeText: lowStockItems.isNotEmpty ? 'ពិនិត្យស្តុក' : '100% OK',
                  badgeColor: lowStockItems.isNotEmpty ? const Color(0xFFD97706) : const Color(0xFF10B981),
                  badgeBg: lowStockItems.isNotEmpty ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                ),
              ),

              if (isWide) ...[
                const SizedBox(width: 14),
                // 4. KPI: Exchange Rate
                Expanded(
                  child: _buildMetricCard(
                    title: 'អត្រាប្តូរប្រាក់ NBC',
                    value: '1\$ = ${CurrencyFormatter.formatNumber(exchangeRate)} ៛',
                    subtitle: 'ស្តង់ដារធនាគារជាតិនៃកម្ពុជា',
                    icon: Icons.currency_exchange,
                    iconBg: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFF7C3AED),
                    onTap: onEditExchangeRate,
                    badgeText: 'ចុចកែប្រែ',
                    badgeColor: const Color(0xFF7C3AED),
                    badgeBg: const Color(0xFFF3E8FF),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    VoidCallback? onTap,
    String? badgeText,
    Color? badgeColor,
    Color? badgeBg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg ?? const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeColor ?? AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

