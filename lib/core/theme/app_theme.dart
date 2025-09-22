import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  
  // Accent Colors
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Avatar Colors
  static const List<Color> avatarColors = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF84CC16),
  ];
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );
  
  static const LinearGradient avatarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );
  
  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF1F1F1F);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color cardBorderDark = Color(0xFF374151);
  
  // Input Colors
  static const Color inputBackground = Color(0xFFF9FAFB);
  static const Color inputBackgroundDark = Color(0xFF1F2937);
  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color inputBorderDark = Color(0xFF4B5563);
  static const Color inputFocus = primary;
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x3A000000);
  
  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  
  // Feature-specific Colors
  static const Color aiMessage = Color(0xFFECFDF5);
  static const Color aiMessageDark = Color(0xFF14532D);
  static const Color userMessage = Color(0xFFEFF6FF);
  static const Color userMessageDark = Color(0xFF1E3A8A);
  
  static const Color voiceActive = Color(0xFFDCFCE7);
  static const Color voiceActiveDark = Color(0xFF166534);
  
  static const Color recordingActive = Color(0xFFEF4444);
  static const Color recordingPaused = Color(0xFFF59E0B);
  
  // Media Player Colors
  static const Color playerBackground = Color(0xFF1C1C1E);
  static const Color playerControls = Color(0xFFFFFFFF);
  static const Color playerProgress = primary;
  
  // Calendar Colors
  static const Color calendarSelected = primary;
  static const Color calendarToday = accent;
  static const Color calendarEvent = secondary;
  
  // Chart Colors
  static const List<Color> chartColors = [
    primary,
    secondary,
    accent,
    error,
    info,
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
  ];
}

class AppTextStyles {
  // Headlines
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle headline5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle headline6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  
  // Button Text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  // Special Styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  // Chat Styles
  static const TextStyle chatMessage = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  static const TextStyle chatTimestamp = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );
  
  // Avatar Styles
  static const TextStyle avatarName = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle avatarStatus = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );
}

class AppSizes {
  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  
  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 999.0;
  
  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;
  
  // Button Heights
  static const double buttonHeightSM = 32.0;
  static const double buttonHeightMD = 44.0;
  static const double buttonHeightLG = 56.0;
  
  // Input Heights
  static const double inputHeightSM = 36.0;
  static const double inputHeightMD = 48.0;
  static const double inputHeightLG = 56.0;
  
  // Avatar Sizes
  static const double avatarXS = 24.0;
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;
  static const double avatarXXL = 128.0;
  
  // Card Sizes
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;
  
  // App Bar
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 64.0;
  
  // Bottom Navigation
  static const double bottomNavHeight = 80.0;
  
  // Floating Action Button
  static const double fabSize = 56.0;
  static const double fabSizeMini = 40.0;
  
  // Chat Bubble
  static const double chatBubbleMaxWidth = 280.0;
  static const double chatBubbleMinHeight = 48.0;
  
  // Screen Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}

class AppShadows {
  static const List<BoxShadow> small = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];
  
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
  ];
  
  static const List<BoxShadow> large = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 10),
      blurRadius: 15,
    ),
  ];
  
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 20),
      blurRadius: 25,
    ),
  ];
}