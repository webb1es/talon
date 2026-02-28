/// Supabase project credentials.
///
/// Replace with your project values from https://supabase.com/dashboard.
/// Keep these out of version control for production — use --dart-define or
/// an env file instead.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
