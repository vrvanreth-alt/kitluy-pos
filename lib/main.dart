import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/pos_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(
    const ProviderScope(
      child: KitluyPosApp(),
    ),
  );
}

class KitluyPosApp extends StatelessWidget {
  const KitluyPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appNameKhmer,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PosMainScreen(),
    );
  }
}
