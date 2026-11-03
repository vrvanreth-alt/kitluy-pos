import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitluy_pos/main.dart';
import 'package:kitluy_pos/presentation/state/customer_debt_provider.dart';
import 'package:kitluy_pos/presentation/state/staff_provider.dart';
import 'package:kitluy_pos/presentation/state/supplier_debt_provider.dart';
import 'package:kitluy_pos/presentation/state/theme_provider.dart';

void main() {
  testWidgets('KITLUY POS boots smoke test (Desktop Viewport)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: KitluyPosApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify app loads with categories & desktop navigation
    expect(find.byType(KitluyPosApp), findsOneWidget);
    expect(find.text('សំបកកង់'), findsWidgets);
    expect(find.text('អាគុយ'), findsWidgets);
    expect(find.text('ប្រេងម៉ាស៊ីន'), findsWidgets);
    expect(find.text('ផ្ទាំងលក់ទំនិញ (POS)'), findsOneWidget);
  });

  testWidgets('KITLUY POS boots smoke test (Mobile Phone Viewport)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: KitluyPosApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify mobile responsive layout loads without overflow
    expect(find.byType(KitluyPosApp), findsOneWidget);
    expect(find.text('សំបកកង់'), findsWidgets);
    expect(find.text('អាគុយ'), findsWidgets);
    expect(find.text('លក់ (POS)'), findsOneWidget);
    expect(find.text('សេវាកម្ម'), findsWidgets);
    expect(find.text('បំណុល'), findsOneWidget);
  });

  test('Dark and Light Theme provider toggle test', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);
    container.read(themeModeProvider.notifier).toggleTheme();
    expect(container.read(themeModeProvider), ThemeMode.dark);
    container.read(themeModeProvider.notifier).toggleTheme();
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('Staff PIN login and role verification test', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial is Owner (9999)
    final staffList = container.read(staffListProvider);
    expect(staffList.length, 4);

    // Test quick switch by PIN
    final success = container.read(currentStaffProvider.notifier).quickSwitchByPin('1234');
    expect(success, true);
    expect(container.read(currentStaffProvider).nameKh, 'ជា សុផល');
    expect(container.read(currentStaffProvider).role.titleKh, contains('Cashier'));

    // Test invalid PIN
    final fail = container.read(currentStaffProvider.notifier).quickSwitchByPin('0001');
    expect(fail, false);
  });

  test('Customer Debt and Supplier Debt state test', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final custDebts = container.read(customerDebtProvider);
    expect(custDebts.isNotEmpty, true);

    final supDebts = container.read(supplierDebtProvider);
    expect(supDebts.isNotEmpty, true);

    final custTotal = container.read(totalCustomerDebtOutstandingProvider);
    expect(custTotal > 0, true);

    final supTotal = container.read(totalSupplierDebtOutstandingProvider);
    expect(supTotal > 0, true);
  });
}
