import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
// import 'services/auth_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await StorageService.init();
  
  // Initialize Supabase (uncomment after adding credentials in lib/core/supabase_config.dart)
  // await AuthService.initialize();
  
  runApp(const ProviderScope(child: FastingTimerApp()));
}
