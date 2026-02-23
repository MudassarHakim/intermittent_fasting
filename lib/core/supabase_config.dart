class SupabaseConfig {
  SupabaseConfig._();

  // TODO: Replace with your Supabase project credentials
  // Get these from: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Deep link configuration for magic link auth
  static const String authRedirectScheme = 'com.fastingtimer.app';
  static const String authRedirectHost = 'login-callback';
  static String get authRedirectUrl => '$authRedirectScheme://$authRedirectHost';
}
