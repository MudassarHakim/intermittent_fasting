import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

class UserProfile {
  final String id;
  final String email;
  final String? country;
  final String? mobileNo;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    this.country,
    this.mobileNo,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      country: json['country'],
      mobileNo: json['mobile_no'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class AuthService {
  AuthService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static String? get userEmail => currentUser?.email;

  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  static Future<AuthResponse> signInWithMagicLink(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: SupabaseConfig.authRedirectUrl,
    );
    return AuthResponse();
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> saveUserProfile({
    required String email,
    String? country,
    String? mobileNo,
  }) async {
    final user = currentUser;
    if (user == null) return;

    await _client.from('user_profiles').upsert({
      'id': user.id,
      'email': email,
      'country': country,
      'mobile_no': mobileNo,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<UserProfile?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> hasCompletedProfile() async {
    final profile = await getUserProfile();
    return profile != null && 
           profile.country != null && 
           profile.mobileNo != null;
  }
}
