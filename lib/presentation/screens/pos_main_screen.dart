import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_helper.dart';
import '../../core/utils/currency_formatter.dart';
import '../state/cart_provider.dart';
import '../state/customer_debt_provider.dart';
import '../state/exchange_rate_provider.dart';
import '../state/product_provider.dart';
import '../state/theme_provider.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/cart_sidebar.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/customer_debt_dialog.dart';
import '../widgets/desktop_kpi_bar.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/pin_login_dialog.dart';
import '../widgets/pos_header.dart';
import '../widgets/pos_navigation_drawer.dart';
import '../widgets/product_grid.dart';
import '../widgets/services_dialog.dart';
import '../widgets/staff_management_dialog.dart';
import '../widgets/supplier_debt_dialog.dart';
import '../widgets/vehicle_selector_dialog.dart';

class PosMainScreen extends ConsumerStatefulWidget {
  const PosMainScreen({super.key});

  @override
  ConsumerState<PosMainScreen> createState() => _PosMainScreenState();
}

class _PosMainScreenState extends ConsumerState<PosMainScreen> {
  int _selectedSidebarIndex = 0;
  int _mobileNavIndex = 0;

  void _openMobileCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.90,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: const CartSidebar(isMobileBottomSheet: true),
        ),
      ),
    );
  }

  void _showExchangeRateDialog(BuildContext context, WidgetRef ref, double currentRate) {
    final controller = TextEditingController(text: currentRate.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            child: Text('បោះបង់', style: GoogleFonts.kantumruyPro(color: context.textSecondaryColor)),
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

  void _showDailyReportDialog(BuildContext context, WidgetRef ref) {
    final rate = ref.read(exchangeRateProvider);

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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assessment, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'របាយការណ៍បិទបញ្ជីលក់ប្រចាំថ្ងៃ (Z-Report)',
              style: GoogleFonts.kantumruyPro(fontSize: 17, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'កាលបរិច្ឆេទ: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • ហាង គិតលុយ',
                style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textSecondaryColor),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surfaceMutedColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  children: [
                    _buildReportRow(context, 'ចំនួនវិក្កយបត្រសរុប:', '12 វិក្កយបត្រ'),
                    const SizedBox(height: 8),
                    _buildReportRow(context, 'ការលក់ដុល្លារ (\$):', '\$1,250.00'),
                    const SizedBox(height: 8),
                    _buildReportRow(context, 'ការលក់រៀល (៛):', '5,125,000 ៛'),
                    const SizedBox(height: 8),
                    _buildReportRow(context, 'កាត់ថ្លៃអាគុយចាស់:', '-\$45.00 (3 គ្រាប់)', color: AppColors.secondary),
                    const SizedBox(height: 8),
                    _buildReportRow(context, 'អត្រាប្តូរប្រាក់:', '1\$ = ${CurrencyFormatter.formatNumber(rate)} ៛'),
                    const Divider(height: 18),
                    _buildReportRow(
                      context,
                      'ចំណូលសុទ្ធសរុប (Net):',
                      '\$1,205.00',
                      isBold: true,
                      color: AppColors.cartTotal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'ទិន្នន័យត្រូវបាន Sync Realtime ទៅ Cloud Firestore',
                    style: GoogleFonts.kantumruyPro(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បិទ', style: GoogleFonts.kantumruyPro()),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('បានបោះពុម្ពរបាយការណ៍បិទបញ្ជីជោគជ័យ!', style: GoogleFonts.kantumruyPro()),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.print, size: 16),
            label: Text('ព្រីនរបាយការណ៍ 80mm', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
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
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            ),
            const SizedBox(width: 10),
            Text(
              'ទំនិញជិតអស់ស្តុក (${lowStockItems.length})',
              style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: lowStockItems.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'គ្រប់ទំនិញទាំងអស់មានស្តុកគ្រប់គ្រាន់!',
                      style: GoogleFonts.kantumruyPro(fontSize: 15, color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: lowStockItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (c, idx) {
                    final item = lowStockItems[idx];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: item.category.tagColor.withValues(alpha: 0.15),
                        child: Icon(item.category.icon, color: item.category.tagColor, size: 20),
                      ),
                      title: Text(item.nameKh, style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimaryColor)),
                      subtitle: Text('${item.nameEn} • នៅសល់៖ ${item.stockQuantity} ${item.unit}', style: GoogleFonts.kantumruyPro(fontSize: 11, color: context.textSecondaryColor)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'កម្រិតប្រកាស៖ ${item.minStockAlert}',
                          style: GoogleFonts.kantumruyPro(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បិទ', style: GoogleFonts.kantumruyPro()),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              showDialog(context: context, builder: (_) => const SupplierDebtDialog());
            },
            icon: const Icon(Icons.add_shopping_cart, size: 16),
            label: Text('កត់ត្រាបញ្ជាទិញចូល (PO)', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMobileMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: context.borderColor, borderRadius: BorderRadius.circular(2)),
                ),
                ListTile(
                  leading: const Icon(Icons.business_center, color: AppColors.warning),
                  title: Text('បំណុលក្រុមហ៊ុន (Supplier Debt)', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                  subtitle: Text('Accounts Payable • វិក្កយបត្រក្រុមហ៊ុន', style: GoogleFonts.kantumruyPro(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(context: context, builder: (_) => const SupplierDebtDialog());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assessment, color: AppColors.primary),
                  title: Text('របាយការណ៍បិទបញ្ជី (Daily Report)', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                  subtitle: Text('Z-Report • ចំណូលប្រចាំថ្ងៃ', style: GoogleFonts.kantumruyPro(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDailyReportDialog(context, ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shield, color: Color(0xFF6366F1)),
                  title: Text('បុគ្គលិក & សិទ្ធិ (Staff & Roles)', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                  subtitle: Text('គ្រប់គ្រងបុគ្គលិក និងកំណត់សិទ្ធិ', style: GoogleFonts.kantumruyPro(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(context: context, builder: (_) => const StaffManagementDialog());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: AppColors.secondary),
                  title: Text('ប្តូរបុគ្គលិក (Switch Staff PIN)', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                  subtitle: Text('ចូលប្រើដោយលេខកូដសម្ងាត់ ៤ ខ្ទង់', style: GoogleFonts.kantumruyPro(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(context: context, builder: (_) => const PinLoginDialog());
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(context.isDark ? Icons.light_mode : Icons.dark_mode, color: AppColors.accent),
                  title: Text(context.isDark ? 'ប្តូរទៅ Light Mode' : 'ប្តូរទៅ Dark Mode', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportRow(BuildContext context, String title, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.kantumruyPro(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: context.textPrimaryColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.kantumruyPro(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color ?? context.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;
    final isMobile = screenWidth < 768;
    final cart = ref.watch(cartProvider);
    final rate = ref.watch(exchangeRateProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      drawer: isDesktop ? null : const PosNavigationDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (scaffoldContext) {
            return Row(
              children: [
                // 1. Permanent Desktop Sidebar
                if (isDesktop)
                  DesktopSidebar(
                    selectedIndex: _selectedSidebarIndex,
                    onSelectIndex: (idx) {
                      setState(() => _selectedSidebarIndex = idx);
                    },
                    onOpenGarage: () => showDialog(
                      context: context,
                      builder: (ctx) => const VehicleSelectorDialog(),
                    ),
                    onOpenInventory: () => _showLowStockDialog(context, ref),
                    onOpenServices: () => showDialog(
                      context: context,
                      builder: (ctx) => const ServicesDialog(),
                    ),
                    onOpenCustomerDebt: () => showDialog(
                      context: context,
                      builder: (ctx) => const CustomerDebtDialog(),
                    ),
                    onOpenSupplierDebt: () => showDialog(
                      context: context,
                      builder: (ctx) => const SupplierDebtDialog(),
                    ),
                    onOpenReport: () => _showDailyReportDialog(context, ref),
                    onOpenStaff: () => showDialog(
                      context: context,
                      builder: (ctx) => const StaffManagementDialog(),
                    ),
                  ),

                // 2. Main Workspace Body
                Expanded(
                  child: Column(
                    children: [
                      // Top Navigation Header
                      PosHeader(
                        isMobile: isMobile,
                        onOpenDrawer: isDesktop ? null : () => Scaffold.of(scaffoldContext).openDrawer(),
                        onOpenCart: isMobile ? () => _openMobileCart(context) : null,
                        onAddProduct: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const AddProductDialog(),
                          );
                        },
                      ),

                      // Metric Summary KPI Bar
                      if (!isMobile)
                        DesktopKpiBar(
                          onOpenVehicle: () => showDialog(
                            context: context,
                            builder: (ctx) => const VehicleSelectorDialog(),
                          ),
                          onOpenLowStock: () => _showLowStockDialog(context, ref),
                          onOpenCustomerDebt: () => showDialog(
                            context: context,
                            builder: (ctx) => const CustomerDebtDialog(),
                          ),
                          onEditExchangeRate: () => _showExchangeRateDialog(context, ref, rate),
                        ),

                      // Catalog & Cart Split (Desktop) or Full Catalog (Mobile)
                      Expanded(
                        child: isMobile
                            ? const Column(
                                children: [
                                  CategoryFilterBar(),
                                  Expanded(child: ProductGrid()),
                                ],
                              )
                            : const Row(
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

                                  // Right Side: Cart Sidebar (Fixed on Desktop/iPad)
                                  CartSidebar(),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // Floating Bottom Cart Bar & Navigation for Mobile screens
      bottomNavigationBar: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!cart.isEmpty)
                  _buildMobileCartBottomBar(context, cart, rate),
                _buildMobileNavBar(context, ref),
              ],
            )
          : null,
    );
  }

  Widget _buildMobileCartBottomBar(BuildContext context, CartState cart, double exchangeRate) {
    final totalKHR = cart.netTotalKHR(exchangeRate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Cart badge & Total summary
            Expanded(
              child: InkWell(
                onTap: () => _openMobileCart(context),
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_cart, color: AppColors.primaryLight, size: 22),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${cart.totalItemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.formatUSD(cart.netTotalUSD),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: context.isDark ? Colors.white : AppColors.cartTotal,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatKHR(totalKHR),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Big Checkout / View Cart Button
            ElevatedButton.icon(
              onPressed: () => _openMobileCart(context),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                'មើលកន្ត្រក (${cart.totalItemCount})',
                style: GoogleFonts.kantumruyPro(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavBar(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final lowStockCount = products.where((p) => p.isLowStock).length;
    final totalCustDebt = ref.watch(totalCustomerDebtOutstandingProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _mobileNavIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.surfaceColor,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: context.textSecondaryColor,
          selectedLabelStyle: GoogleFonts.kantumruyPro(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.kantumruyPro(fontSize: 10),
          elevation: 0,
          onTap: (index) {
            setState(() => _mobileNavIndex = index);
            if (index == 1) {
              // Services
              showDialog(context: context, builder: (_) => const ServicesDialog());
            } else if (index == 2) {
              // Customer Debt
              showDialog(context: context, builder: (_) => const CustomerDebtDialog());
            } else if (index == 3) {
              // Low stock
              _showLowStockDialog(context, ref);
            } else if (index == 4) {
              // More Menu
              _showMobileMoreMenu(context);
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'លក់ (POS)',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.handyman_outlined),
              activeIcon: Icon(Icons.handyman),
              label: 'សេវាកម្ម',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: totalCustDebt > 0,
                label: Text('\$${totalCustDebt.toStringAsFixed(0)}'),
                backgroundColor: AppColors.danger,
                child: const Icon(Icons.account_balance_wallet_outlined),
              ),
              activeIcon: const Icon(Icons.account_balance_wallet),
              label: 'បំណុល',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: lowStockCount > 0,
                label: Text('$lowStockCount'),
                backgroundColor: AppColors.warning,
                child: const Icon(Icons.inventory_2_outlined),
              ),
              activeIcon: const Icon(Icons.inventory_2),
              label: 'ស្តុក',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              activeIcon: Icon(Icons.menu_open),
              label: 'មីនុយ',
            ),
          ],
        ),
      ),
    );
  }
}
