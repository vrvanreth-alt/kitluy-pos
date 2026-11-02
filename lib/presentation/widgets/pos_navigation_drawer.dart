import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../state/exchange_rate_provider.dart';
import '../state/product_provider.dart';

class PosNavigationDrawer extends ConsumerWidget {
  const PosNavigationDrawer({super.key});

  void _showDailyReportDialog(BuildContext context, WidgetRef ref) {
    final rate = ref.read(exchangeRateProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.assessment, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'របាយការណ៍បិទបញ្ជីប្រចាំថ្ងៃ (Daily Z-Report)',
              style: GoogleFonts.kantumruyPro(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReportItem('សរុបការលក់សរុប (Total Sales):', '\$680.00 (2,788,000 ៛)'),
              _buildReportItem('ទូទាត់តាម Bakong KHQR:', '\$420.00'),
              _buildReportItem('សាច់ប្រាក់ដុល្លារ (Cash USD):', '\$160.00'),
              _buildReportItem('សាច់ប្រាក់រៀល (Cash KHR):', '410,000 ៛ (\$100.00)'),
              const Divider(height: 20),
              _buildReportItem('កាត់កងអាគុយចាស់ (Rebates):', '-\$30.00', color: const Color(0xFF16A34A)),
              _buildReportItem('ចំនួនវិក្កយបត្រសរុប:', '12 វិក្កយបត្រ'),
              _buildReportItem('អត្រាប្តូរប្រាក់ថ្ងៃនេះ:', '1\$ = ${CurrencyFormatter.formatNumber(rate)} ៛'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បិទ', style: GoogleFonts.kantumruyPro()),
          ),
        ],
      ),
    );
  }

  static Widget _buildReportItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.kantumruyPro(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: GoogleFonts.kantumruyPro(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showLowStockDialog(BuildContext context, WidgetRef ref) {
    final products = ref.read(productsProvider);
    final lowStockItems = products.where((p) => p.isLowStock).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              'ទំនិញជិតអស់ពីស្តុក (Low Stock Alert)',
              style: GoogleFonts.kantumruyPro(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 300,
          child: lowStockItems.isEmpty
              ? Center(
                  child: Text(
                    'មិនមានទំនិញជិតអស់ពីស្តុកទេ!',
                    style: GoogleFonts.kantumruyPro(color: const Color(0xFF16A34A), fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.separated(
                  itemCount: lowStockItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = lowStockItems[index];
                    return ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFFED7AA)),
                      ),
                      tileColor: const Color(0xFFFFF7ED),
                      leading: Icon(item.category.icon, color: item.category.tagColor),
                      title: Text(item.nameKh, style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(item.attributeSummary, style: GoogleFonts.kantumruyPro(fontSize: 11)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'នៅសល់ ${item.stockQuantity} ${item.unit}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('យល់ព្រម', style: GoogleFonts.kantumruyPro()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final lowStockCount = products.where((p) => p.isLowStock).length;
    final isCloudConnected = SupabaseService.isInitialized;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 1. Header with branding & Cashier profile
          Container(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.car_repair, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: GoogleFonts.kantumruyPro(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            AppConstants.defaultShopNameEn,
                            style: GoogleFonts.kantumruyPro(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cashier info & Cloud status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 14, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'បេឡាករ: សុខ វិសាល',
                              style: GoogleFonts.kantumruyPro(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'សាខាទី ១ • ផ្លូវ ២៧១ ភ្នំពេញ',
                              style: GoogleFonts.kantumruyPro(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCloudConnected ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCloudConnected ? Icons.cloud_done : Icons.cloud_queue,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCloudConnected ? 'Cloud' : 'Local',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Menu Sections (Scrollable)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // SECTION 1: ការលក់ (Sales)
                _buildSectionHeader('ផ្នែកលក់ (SALES & CASHIER)'),
                _buildDrawerTile(
                  icon: Icons.point_of_sale,
                  title: 'ផ្ទាំងលក់ POS (Register)',
                  isSelected: true,
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerTile(
                  icon: Icons.receipt_long,
                  title: 'ប្រវត្តិវិក្កយបត្រ (Order History)',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('មុខងារប្រវត្តិវិក្កយបត្រកំពុងដំណើរការ!')),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.pause_circle_outline,
                  title: 'បញ្ជីផ្អាកទុក (Held Orders)',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('0', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => Navigator.pop(context),
                ),

                const Divider(height: 16),

                // SECTION 2: ឃ្លាំង & ស្តុក (Inventory)
                _buildSectionHeader('ផ្នែកឃ្លាំង & ស្តុក (INVENTORY)'),
                _buildDrawerTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'បញ្ជីទំនិញ & គ្រឿងបន្លាស់',
                  subtitle: '${products.length} មុខទំនិញ',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerTile(
                  icon: Icons.warning_amber_rounded,
                  title: 'ទំនិញជិតអស់ពីស្តុក',
                  iconColor: lowStockCount > 0 ? AppColors.warning : AppColors.textSecondary,
                  trailing: lowStockCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Text(
                            '$lowStockCount',
                            style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _showLowStockDialog(context, ref);
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.add_shopping_cart,
                  title: 'នាំចូលស្តុកថ្មី (Stock-In)',
                  onTap: () => Navigator.pop(context),
                ),

                const Divider(height: 16),

                // SECTION 3: យានយន្ត & សេវាកម្ម (Garage)
                _buildSectionHeader('ផ្នែកយានយន្ត & ជាង (GARAGE & VEHICLES)'),
                _buildDrawerTile(
                  icon: Icons.directions_car_outlined,
                  title: 'ប្រវត្តិឡាន & ស្លាកលេខ',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'ដាស់តឿនប្តូរប្រេងម៉ាស៊ីន',
                  subtitle: 'Service Due Reminder',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerTile(
                  icon: Icons.engineering_outlined,
                  title: 'កម្រៃជើងសារជាង (Mechanic)',
                  onTap: () => Navigator.pop(context),
                ),

                const Divider(height: 16),

                // SECTION 4: របាយការណ៍ (Reports)
                _buildSectionHeader('របាយការណ៍ & គណនេយ្យ (REPORTS)'),
                _buildDrawerTile(
                  icon: Icons.assessment_outlined,
                  title: 'បិទបញ្ជីប្រចាំថ្ងៃ (Daily Z-Report)',
                  onTap: () {
                    Navigator.pop(context);
                    _showDailyReportDialog(context, ref);
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.qr_code,
                  title: 'របាយការណ៍ Bakong KHQR',
                  onTap: () => Navigator.pop(context),
                ),

                const Divider(height: 16),

                // SECTION 5: ការកំណត់ (Settings)
                _buildSectionHeader('ការកំណត់ (SETTINGS)'),
                _buildDrawerTile(
                  icon: Icons.currency_exchange,
                  title: 'អត្រាប្តូរប្រាក់ (Exchange Rate)',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerTile(
                  icon: Icons.print_outlined,
                  title: 'ម៉ាស៊ីនព្រីន 80mm & ឧបករណ៍',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerTile(
                  icon: Icons.storefront_outlined,
                  title: 'ព័ត៌មានហាង & វិក្កយបត្រ',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 3. Footer with version & Sign out
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppConstants.appName} v${AppConstants.appVersion}',
                      style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Cambodian POS Standard',
                      style: GoogleFonts.kantumruyPro(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.danger, size: 20),
                  tooltip: 'ចាកចេញពីប្រព័ន្ធ (Sign Out)',
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('បានចាកចេញពីវេនបេឡា!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: GoogleFonts.kantumruyPro(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        dense: true,
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.primary : (iconColor ?? AppColors.textSecondary),
        ),
        title: Text(
          title,
          style: GoogleFonts.kantumruyPro(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: GoogleFonts.kantumruyPro(fontSize: 11, color: AppColors.textMuted))
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
