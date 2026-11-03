import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/pos_main_screen.dart';
import 'presentation/state/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(
    const ProviderScope(
      child: KitluyPosApp(),
    ),
  );
}

class KitluyPosApp extends ConsumerWidget {
  const KitluyPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appNameKhmer,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const PosMainScreen(),
    );
  }
}
