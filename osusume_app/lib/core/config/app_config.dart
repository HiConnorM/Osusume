/// Runtime configuration. Values come from --dart-define at build time.
/// Set these in your IDE run config or CI environment:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// If neither value is provided, the app falls back to mock data automatically.
class AppConfig {
  AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// True when Supabase credentials have been provided at build time.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// OSM tile template — no key required.
  static const osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// User-agent sent with OSM tile requests (required by their ToS).
  static const osmUserAgent = 'com.osusume.osusume_app';
}
