import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // បញ្ចូល Supabase Project URL និង Anon Key របស់អ្នកនៅទីនេះ
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient? get client => _client;

  static bool get isInitialized => _client != null && SupabaseConfig.isConfigured;

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('ℹ️ Supabase not yet configured. Running in Local Offline Mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      debugPrint('✅ Supabase connected successfully!');
    } catch (e) {
      debugPrint('⚠️ Supabase connection error: $e');
    }
  }
}
