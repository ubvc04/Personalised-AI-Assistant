import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../features/avatar/presentation/widgets/ai_avatar.dart';
import 'in_app_search_page.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  bool _isListening = false;
  bool _isSpeaking = false;
  final TextEditingController _messageController = TextEditingController();

  final List<DashboardFeature> _features = [
    DashboardFeature(
      title: 'Chat with AI',
      subtitle: 'Have conversations with your AI assistant',
      icon: Icons.chat_bubble_outline,
      color: AppColors.primary,
    ),
    DashboardFeature(
      title: 'Voice Commands',
      subtitle: 'Control your phone with voice',
      icon: Icons.mic,
      color: AppColors.secondary,
    ),
    DashboardFeature(
      title: 'Task Manager',
      subtitle: 'Organize your tasks and reminders',
      icon: Icons.task_alt,
      color: AppColors.accent,
    ),
    DashboardFeature(
      title: 'Media Player',
      subtitle: 'Music, videos, and photos',
      icon: Icons.play_circle_outline,
      color: AppColors.info,
    ),
    DashboardFeature(
      title: 'Smart Tools',
      subtitle: 'Calculator, QR scanner, weather',
      icon: Icons.build,
      color: AppColors.success,
    ),
    DashboardFeature(
      title: 'Contacts',
      subtitle: 'Manage your contacts',
      icon: Icons.contacts,
      color: AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildCurrentPage(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: _buildVoiceButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildChatInterface();
      case 1:
        return _buildFeatureGrid();
      case 2:
        return _buildSearchInterface();
      case 3:
        return _buildSettingsInterface();
      default:
        return _buildChatInterface();
    }
  }

  Widget _buildSearchInterface() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        children: [
          // Search header
          Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Smart Search',
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ).animate().fadeIn().slideX(),
          
          const SizedBox(height: 24),
          
          // Search bar
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InAppSearchPage(),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceMD,
                vertical: AppSizes.spaceMD,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(color: AppColors.inputBorder),
                boxShadow: AppShadows.small,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search anything on Google...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(),
          
          const SizedBox(height: 32),
          
          // Quick search categories
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildSearchCategory(
                  'News & Updates',
                  Icons.newspaper,
                  AppColors.info,
                  'latest news',
                ),
                _buildSearchCategory(
                  'Weather',
                  Icons.wb_sunny,
                  AppColors.warning,
                  'weather today',
                ),
                _buildSearchCategory(
                  'Technology',
                  Icons.computer,
                  AppColors.primary,
                  'latest technology',
                ),
                _buildSearchCategory(
                  'Entertainment',
                  Icons.movie,
                  AppColors.error,
                  'movies and shows',
                ),
                _buildSearchCategory(
                  'Sports',
                  Icons.sports_soccer,
                  AppColors.success,
                  'sports news',
                ),
                _buildSearchCategory(
                  'Finance',
                  Icons.trending_up,
                  AppColors.secondary,
                  'stock market',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCategory(String title, IconData icon, Color color, String query) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InAppSearchPage(initialQuery: query),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate(delay: (100 * title.hashCode % 500).ms)
     .fadeIn(duration: 600.ms)
     .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildSettingsInterface() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ).animate().fadeIn().slideX(),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: [
                _buildSettingsTile(
                  Icons.person,
                  'Profile',
                  'Manage your account settings',
                  () {},
                ),
                _buildSettingsTile(
                  Icons.notifications,
                  'Notifications',
                  'Control notification preferences',
                  () {},
                ),
                _buildSettingsTile(
                  Icons.security,
                  'Privacy & Security',
                  'Manage your privacy settings',
                  () {},
                ),
                _buildSettingsTile(
                  Icons.palette,
                  'Appearance',
                  'Customize app theme',
                  () {},
                ),
                _buildSettingsTile(
                  Icons.help,
                  'Help & Support',
                  'Get help and support',
                  () {},
                ),
                _buildSettingsTile(
                  Icons.info,
                  'About',
                  'App information and credits',
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello there! 👋',
                    style: AppTextStyles.headline5.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceXS),
                  Text(
                    'How can I help you today?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLG),
          Center(
            child: AIAvatar(
              size: 120,
              isListening: _isListening,
              isSpeaking: _isSpeaking,
              personality: 'friendly',
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(AppSizes.spaceMD),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              boxShadow: AppShadows.medium,
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppSizes.spaceMD),
                  Text(
                    'Start a conversation!',
                    style: AppTextStyles.headline6,
                  ),
                  SizedBox(height: AppSizes.spaceSM),
                  Text(
                    'Type a message or use voice commands',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.small,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceMD,
                  vertical: AppSizes.spaceSM,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSM),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(AppSizes.spaceSM),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceMD),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: AppSizes.spaceMD,
          mainAxisSpacing: AppSizes.spaceMD,
        ),
        itemCount: _features.length,
        itemBuilder: (context, index) {
          final feature = _features[index];
          return _buildFeatureCard(feature, index);
        },
      ),
    );
  }

  Widget _buildFeatureCard(DashboardFeature feature, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: AppShadows.medium,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          onTap: () => _openFeature(feature),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spaceMD),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: feature.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: Icon(
                    feature.icon,
                    color: feature.color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceSM),
                Text(
                  feature.title,
                  style: AppTextStyles.labelLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceXS),
                Text(
                  feature.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (100 * index).ms)
     .fadeIn(duration: 600.ms)
     .slideY(begin: 0.3, end: 0);
  }

  Widget _buildBottomNavigation() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.chat, 'Chat', 0),
          _buildNavItem(Icons.apps, 'Features', 1),
          const SizedBox(width: 40), // Space for FAB
          _buildNavItem(Icons.search, 'Search', 2),
          _buildNavItem(Icons.settings, 'Settings', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        if (index == 2) {
          // Handle search differently - open search page directly
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InAppSearchPage(),
            ),
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceSM,
          vertical: AppSizes.spaceXS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return FloatingActionButton(
      onPressed: _toggleVoice,
      backgroundColor: _isListening ? AppColors.error : AppColors.secondary,
      child: Icon(
        _isListening ? Icons.mic_off : Icons.mic,
        color: Colors.white,
      ),
    ).animate(target: _isListening ? 1 : 0)
     .scale(duration: 200.ms);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      // TODO: Implement message sending
      _messageController.clear();
      
      // Simulate AI response
      setState(() => _isSpeaking = true);
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isSpeaking = false);
      });
    }
  }

  void _toggleVoice() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        // TODO: Start voice recognition
      } else {
        // TODO: Stop voice recognition
      }
    });
  }

  void _openFeature(DashboardFeature feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${feature.title}...'),
        backgroundColor: feature.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class DashboardFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  DashboardFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}