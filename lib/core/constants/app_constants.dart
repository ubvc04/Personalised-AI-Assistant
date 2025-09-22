class AppConstants {
  // API Keys
  static const String geminiApiKey = 'AIzaSyBo7FZ28w0Udd3kMfv5mgvhvm3wN1GTXlI';
  
  // SMTP Configuration
  static const String smtpCode = 'rrfc ylja oyyc ewrq';
  static const String alertEmail = 'baveshchowdary1@gmail.com';
  static const String smtpHost = 'smtp.gmail.com';
  static const int smtpPort = 587;
  
  // App Information
  static const String appName = 'AI Assistant';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'ai_assistant.db';
  static const int databaseVersion = 1;
  
  // Hive Boxes
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String conversationBox = 'conversation_box';
  static const String taskBox = 'task_box';
  static const String contactBox = 'contact_box';
  static const String mediaBox = 'media_box';
  
  // Avatar Configuration
  static const List<String> avatarTypes = ['male', 'female'];
  static const List<String> avatarPersonalities = [
    'friendly',
    'professional',
    'casual',
    'energetic',
    'calm'
  ];
  
  // Supported Languages
  static const List<String> supportedLanguages = [
    'en-US', // English (US)
    'en-GB', // English (UK)
    'es-ES', // Spanish
    'fr-FR', // French
    'de-DE', // German
    'it-IT', // Italian
    'pt-BR', // Portuguese (Brazil)
    'hi-IN', // Hindi
    'zh-CN', // Chinese (Simplified)
    'ja-JP', // Japanese
    'ko-KR', // Korean
    'ar-SA', // Arabic
  ];
  
  // Wake Words
  static const List<String> wakeWords = [
    'hey assistant',
    'ai assistant',
    'hello assistant'
  ];
  
  // Default Settings
  static const bool defaultDarkMode = false;
  static const String defaultLanguage = 'en-US';
  static const String defaultVoice = 'en-US-Wavenet-D';
  static const double defaultSpeechRate = 0.8;
  static const double defaultSpeechPitch = 1.0;
  static const String defaultAvatarType = 'female';
  static const String defaultPersonality = 'friendly';
  
  // Network
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Permissions
  static const List<String> requiredPermissions = [
    'camera',
    'microphone',
    'storage',
    'location',
    'contacts',
    'sms',
    'phone',
    'calendar',
    'notification'
  ];
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // File Limits
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxAudioSize = 50 * 1024 * 1024; // 50MB
  static const int maxDocumentSize = 25 * 1024 * 1024; // 25MB
  
  // Conversation Limits
  static const int maxConversationHistory = 1000;
  static const int maxMessageLength = 5000;
  static const int contextWindowSize = 20;
  
  // Security
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const int otpLength = 6;
  static const Duration otpExpiration = Duration(minutes: 5);
  
  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // Notification Channels
  static const String generalNotificationChannel = 'general';
  static const String aiNotificationChannel = 'ai_responses';
  static const String securityNotificationChannel = 'security';
  static const String reminderNotificationChannel = 'reminders';
  static const String mediaNotificationChannel = 'media';
}