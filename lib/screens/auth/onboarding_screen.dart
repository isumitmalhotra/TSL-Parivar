import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';

/// Beautiful onboarding screen with 3 slides introducing TSL Parivar
///
/// Features:
/// - Smooth page transitions with parallax effect
/// - Animated illustrations
/// - Progress indicator
/// - Skip and Next buttons
class OnboardingScreen extends StatefulWidget {
  /// Callback when onboarding completes
  final VoidCallback? onComplete;

  /// Callback when skip is pressed
  final VoidCallback? onSkip;

  const OnboardingScreen({
    super.key,
    this.onComplete,
    this.onSkip,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _floatController;
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    _pages.clear();
    _pages.addAll([
      _OnboardingData(
        icon: Icons.handshake_outlined,
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
        color: const Color(0xFF2E7D32),
        gradient: const [Color(0xFF66BB6A), Color(0xFF43A047), Color(0xFF2E7D32)],
      ),
      _OnboardingData(
        icon: Icons.local_shipping_outlined,
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
        color: const Color(0xFF388E3C),
        gradient: const [Color(0xFF81C784), Color(0xFF4CAF50), Color(0xFF388E3C)],
      ),
      _OnboardingData(
        icon: Icons.emoji_events_outlined,
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
        color: const Color(0xFF1B5E20),
        gradient: const [Color(0xFFA5D6A7), Color(0xFF66BB6A), Color(0xFF1B5E20)],
      ),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.forward(from: 0);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onComplete?.call();
    }
  }

  void _skip() {
    widget.onSkip?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // White
              Color(0xFFF0FFF0), // Very light green
              Color(0xFFE8F5E9), // Light green
              Color(0xFFC8E6C9), // Soft green
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              _buildHeader(l10n),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(index);
                  },
                ),
              ),

              // Bottom section
              _buildBottomSection(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/tsl_logo_new.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'TSL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Parivar',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          // Skip button
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: _skip,
              child: Text(
                l10n.commonSkip,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    final data = _pages[index];

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * math.pi) * 10;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated illustration
              Transform.translate(
                offset: Offset(0, floatOffset),
                child: _buildIllustration(data, index),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Title with gradient
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: data.gradient,
                ).createShader(bounds),
                child: Text(
                  data.title,
                  style: AppTypography.h1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Description
              Text(
                data.description,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIllustration(
    _OnboardingData data,
    int index,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circles
        ...List.generate(3, (i) {
          final size = 200.0 - (i * 40);
          return AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final scale = 1.0 + math.sin(_floatController.value * math.pi + i * 0.5) * 0.05;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        data.color.withValues(alpha: 0.1 - i * 0.03),
                        data.color.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // 3D Icon container
        _build3DIconContainer(data),
      ],
    );
  }

  Widget _build3DIconContainer(_OnboardingData data) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final rotateY = math.sin(_floatController.value * math.pi) * 0.1;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotateY),
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: data.gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.color.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 20,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shine effect
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    width: 50,
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.5),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Icon
                Center(
                  child: Icon(
                    data.icon,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // Page indicator
          _buildPageIndicator(),

          const SizedBox(height: AppSpacing.xl),

          // Action buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: TslSecondaryButton(
                    label: l10n.commonBack,
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: _currentPage == 0 ? 1 : 1,
                child: _buildNextButton(l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isActive
                ? LinearGradient(colors: _pages[_currentPage].gradient)
                : null,
            color: isActive ? null : AppColors.disabled,
          ),
        );
      }),
    );
  }

  Widget _buildNextButton(AppLocalizations l10n) {
    final isLastPage = _currentPage == _pages.length - 1;
    final data = _pages[_currentPage];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        borderRadius: AppRadius.radiusButton,
        child: InkWell(
          onTap: _nextPage,
          borderRadius: AppRadius.radiusButton,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusButton,
              gradient: LinearGradient(colors: data.gradient),
              boxShadow: [
                BoxShadow(
                  color: data.color.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastPage ? l10n.commonGetStarted : l10n.commonNext,
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  isLastPage ? Icons.check : Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data model for onboarding page
class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<Color> gradient;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradient,
  });
}

