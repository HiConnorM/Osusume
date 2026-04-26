import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    if (!AppConfig.isSupabaseConfigured) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Invoke a Supabase Edge Function and return the decoded JSON body.
  /// Returns null on error so callers can fall back to mock data gracefully.
  static Future<Map<String, dynamic>?> invoke(
    String function, {
    Map<String, dynamic>? body,
  }) async {
    if (!AppConfig.isSupabaseConfigured) return null;
    try {
      final response = await client.functions.invoke(
        function,
        body: body,
      );
      return response.data as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  /// Query a Supabase table with optional filters.
  /// Returns an empty list on error so callers can fall back gracefully.
  static Future<List<Map<String, dynamic>>> query(
    String table, {
    Map<String, dynamic>? eq,
    int? limit,
  }) async {
    if (!AppConfig.isSupabaseConfigured) return [];
    try {
      var q = client.from(table).select();
      if (eq != null) {
        for (final entry in eq.entries) {
          q = q.eq(entry.key, entry.value);
        }
      }
      final data = limit != null ? await q.limit(limit) : await q;
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }
}
