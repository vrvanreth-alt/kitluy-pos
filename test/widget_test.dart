import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitluy_pos/main.dart';

void main() {
  testWidgets('KITLUY POS boots smoke test (Desktop Viewport)', (WidgetTester tester) async {
    // Configure desktop viewport for POS Web layout
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

    // Verify app loads
    expect(find.byType(KitluyPosApp), findsOneWidget);
    expect(find.text('សំបកកង់'), findsWidgets);
    expect(find.text('អាគុយ'), findsWidgets);
    expect(find.text('ប្រេងម៉ាស៊ីន'), findsWidgets);
  });

  testWidgets('KITLUY POS boots smoke test (Mobile Phone Viewport)', (WidgetTester tester) async {
    // Configure mobile phone viewport (e.g. iPhone / Android 390x844)
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
  });
}
