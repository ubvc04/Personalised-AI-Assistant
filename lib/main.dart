import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'core/theme/theme_provider.dart';
import 'data/databases/database_service.dart';
import 'services/speech_service.dart';
import 'presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize core services
  await _initializeServices();
  
  runApp(
    const ProviderScope(
      child: AIAssistantApp(),
    ),
  );
}

Future<void> _initializeServices() async {
  try {
    // Initialize database
    await DatabaseService.instance.initialize();
    
    // Initialize speech service (with error handling)
    try {
      await SpeechService.instance.initialize();
    } catch (e) {
      debugPrint('Speech service initialization failed: $e');
    }
  } catch (e) {
    debugPrint('Failed to initialize services: $e');
  }
}

class AIAssistantApp extends ConsumerWidget {
  const AIAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AI Personal Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
