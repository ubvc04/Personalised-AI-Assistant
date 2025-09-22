import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_provider.dart';
import 'data/databases/database_service.dart';
import 'services/speech_service.dart';
import 'presentation/pages/main_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

class AIAssistantApp extends StatelessWidget {
  const AIAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainDashboard(),
    );
  }
}
