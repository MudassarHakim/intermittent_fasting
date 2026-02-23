class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'https://fjvxpaxoqbzwjbofpynu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqdnhwYXhvcWJ6d2pib2ZweW51Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg2MDAyNTcsImV4cCI6MjA4NDE3NjI1N30.Y58FMkQ6SNJ2tfOj177PV61CsP3gs6YtUTk8n-Wtgwg';

  // Deep link configuration for magic link auth
  static const String authRedirectScheme = 'com.fastingtimer.app';
  static const String authRedirectHost = 'login-callback';
  static String get authRedirectUrl => '$authRedirectScheme://$authRedirectHost';
}
