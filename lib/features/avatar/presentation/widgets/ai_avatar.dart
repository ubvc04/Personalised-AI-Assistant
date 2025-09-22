import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class AIAvatar extends StatefulWidget {
  final String personality;
  final bool isListening;
  final bool isSpeaking;
  final bool isThinking;
  final String? currentEmotion;
  final double size;

  const AIAvatar({
    super.key,
    this.personality = 'friendly',
    this.isListening = false,
    this.isSpeaking = false,
    this.isThinking = false,
    this.currentEmotion,
    this.size = 150,
  });

  @override
  State<AIAvatar> createState() => _AIAvatarState();
}

class _AIAvatarState extends State<AIAvatar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(AIAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isListening != oldWidget.isListening ||
        widget.isSpeaking != oldWidget.isSpeaking ||
        widget.isThinking != oldWidget.isThinking) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (widget.isListening) {
      _scaleController.forward();
      _pulseController.repeat(reverse: true);
    } else if (widget.isSpeaking) {
      _scaleController.forward();
      _pulseController.repeat(period: const Duration(milliseconds: 500));
    } else if (widget.isThinking) {
      _pulseController.repeat(period: const Duration(milliseconds: 800));
    } else {
      _scaleController.reverse();
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getAvatarGradient(),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background pulse effect
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: widget.size * (0.8 + _pulseController.value * 0.2),
                height: widget.size * (0.8 + _pulseController.value * 0.2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              );
            },
          ),
          
          // Main avatar circle
          AnimatedBuilder(
            animation: _scaleController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + _scaleController.value * 0.1,
                child: Container(
                  width: widget.size * 0.8,
                  height: widget.size * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: _buildAvatarFace(),
                ),
              );
            },
          ),
          
          // Status indicator
          if (widget.isListening || widget.isSpeaking || widget.isThinking)
            Positioned(
              bottom: 10,
              right: 10,
              child: _buildStatusIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarFace() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Face base
        Container(
          width: widget.size * 0.6,
          height: widget.size * 0.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        
        // Eyes
        Positioned(
          top: widget.size * 0.25,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEye(),
              SizedBox(width: widget.size * 0.08),
              _buildEye(),
            ],
          ),
        ),
        
        // Mouth
        Positioned(
          bottom: widget.size * 0.2,
          child: _buildMouth(),
        ),
        
        // Expression overlay
        if (widget.currentEmotion != null)
          _buildEmotionOverlay(),
      ],
    );
  }

  Widget _buildEye() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.size * 0.06,
      height: widget.size * 0.06,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isListening 
            ? AppColors.secondary 
            : widget.isSpeaking
                ? AppColors.accent
                : AppColors.primary,
      ),
    );
  }

  Widget _buildMouth() {
    if (widget.isSpeaking) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: widget.size * (0.08 + _pulseController.value * 0.04),
            height: widget.size * (0.04 + _pulseController.value * 0.02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size * 0.02),
              color: AppColors.accent,
            ),
          );
        },
      );
    }
    
    return Container(
      width: widget.size * 0.08,
      height: 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color color;
    IconData icon;
    
    if (widget.isListening) {
      color = AppColors.secondary;
      icon = Icons.mic;
    } else if (widget.isSpeaking) {
      color = AppColors.accent;
      icon = Icons.volume_up;
    } else {
      color = AppColors.info;
      icon = Icons.psychology;
    }
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: AppShadows.small,
      ),
      child: Icon(
        icon,
        size: 14,
        color: Colors.white,
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .scale(duration: 800.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
     .then()
     .scale(duration: 800.ms, begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8));
  }

  Widget _buildEmotionOverlay() {
    return Container(
      width: widget.size * 0.6,
      height: widget.size * 0.6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getEmotionColor().withOpacity(0.2),
      ),
    );
  }

  LinearGradient _getAvatarGradient() {
    switch (widget.personality.toLowerCase()) {
      case 'energetic':
        return const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'calm':
        return const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'professional':
        return const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'casual':
        return const LinearGradient(
          colors: [Color(0xFFFD79A8), Color(0xFFE17055)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default: // friendly
        return AppColors.primaryGradient;
    }
  }

  Color _getEmotionColor() {
    switch (widget.currentEmotion?.toLowerCase()) {
      case 'happy':
        return Colors.yellow;
      case 'excited':
        return Colors.orange;
      case 'thinking':
        return Colors.blue;
      case 'confused':
        return Colors.purple;
      case 'surprised':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}