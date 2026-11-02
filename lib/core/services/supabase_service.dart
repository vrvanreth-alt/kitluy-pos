import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // បញ្ចូល Supabase Project URL និង Anon Key របស់អ្នកនៅទីនេះ
  static const String supabaseUrl = 'https://izokcxxkszdfrywodubw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml6b2tjeHhrc3pkZnJ5d29kdWJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM2MTY1MjIsImV4cCI6MjEwOTE5MjUyMn0.gp3gFYe3Rrn_I2mazsW5uaDllLOgUb3xH9sIkMt6To8';

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
