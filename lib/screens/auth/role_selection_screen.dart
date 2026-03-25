import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shared_models.dart';

// Re-export UserRole so existing imports continue to work
export '../../models/shared_models.dart' show UserRole, UserRoleExtension;

/// Beautiful role selection screen with 3D card animations
///
/// Features:
/// - 3D flip card animations
/// - Glassmorphism design
/// - Hover/press effects
/// - Gradient backgrounds
class RoleSelectionScreen extends StatefulWidget {
  /// Callback when role is selected
  final ValueChanged<UserRole>? onRoleSelected;

  const RoleSelectionScreen({
    super.key,
    this.onRoleSelected,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardsController;
  late List<AnimationController> _cardAnimations;
  UserRole? _selectedRole;
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardAnimations = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    // Start entrance animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardsController.dispose();
    for (final controller in _cardAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onRoleTap(UserRole role, int index) {
    setState(() {
      _selectedRole = role;
    });

    // Animate selected card
    _cardAnimations[index].forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        widget.onRoleSelected?.call(role);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(size),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),

                // Header
                _buildHeader(l10n),

                const SizedBox(height: AppSpacing.xl),

                // Title section
                _buildTitleSection(l10n),

                const Spacer(),

                // Role cards
                _buildRoleCards(l10n),

                const Spacer(),

                // Footer
                _buildFooter(l10n),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF), // White
                Color(0xFFF0FFF0), // Very light green
                Color(0xFFE8F5E9), // Light green
                Color(0xFFC8E6C9), // Soft green
                Color(0xFFB9DFB9), // Softer medium green
              ],
              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated shapes
              ...List.generate(5, (index) {
                final offset = _backgroundController.value * 2 * math.pi;
                final x = size.width * (0.2 + index * 0.15) +
                    math.sin(offset + index) * 30;
                final y = size.height * (0.1 + index * 0.18) +
                    math.cos(offset + index * 0.5) * 30;

                return Positioned(
                  left: x,
                  top: y,
                  child: Container(
                    width: 100 + index * 30.0,
                    height: 100 + index * 30.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withValues(alpha: 0.8),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/tsl_logo_new.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'TSL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.appName,
                  style: AppTypography.h3.copyWith(
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Text(
            l10n.roleSelectionTitle,
            style: AppTypography.h1.copyWith(
              color: const Color(0xFF2E7D32),
              fontSize: 32,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.roleSelectionSubtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCards(AppLocalizations l10n) {
    final roles = [
      _RoleData(
        role: UserRole.mistri,
        icon: Icons.construction,
        title: l10n.roleMistri,
        description: l10n.roleMistriDesc,
        gradient: const [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
      ),
      _RoleData(
        role: UserRole.dealer,
        icon: Icons.store,
        title: l10n.roleDealer,
        description: l10n.roleDealerDesc,
        gradient: const [Color(0xFF81C784), Color(0xFF4CAF50)],
      ),
      _RoleData(
        role: UserRole.architect,
        icon: Icons.architecture,
        title: l10n.roleArchitect,
        description: l10n.roleArchitectDesc,
        gradient: const [Color(0xFFC8E6C9), Color(0xFF66BB6A)],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: List.generate(roles.length, (index) {
          final data = roles[index];
          final isSelected = _selectedRole == data.role;

          return AnimatedBuilder(
            animation: _cardsController,
            builder: (context, child) {
              final slideAnimation = Tween<Offset>(
                begin: Offset(index.isEven ? -1 : 1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _cardsController,
                  curve: Interval(
                    index * 0.15,
                    0.5 + index * 0.15,
                    curve: Curves.easeOutCubic,
                  ),
                ),
              );

              final opacityAnimation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: _cardsController,
                  curve: Interval(
                    index * 0.15,
                    0.4 + index * 0.15,
                    curve: Curves.easeIn,
                  ),
                ),
              );

              return SlideTransition(
                position: slideAnimation,
                child: Opacity(
                  opacity: opacityAnimation.value,
                  child: _buildRoleCard(data, index, isSelected),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildRoleCard(_RoleData data, int index, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressedIndex = index),
        onTapUp: (_) => setState(() => _pressedIndex = null),
        onTapCancel: () => setState(() => _pressedIndex = null),
        onTap: () => _onRoleTap(data.role, index),
        child: AnimatedBuilder(
          animation: _cardAnimations[index],
          builder: (context, child) {
            final isPressed = _pressedIndex == index;
            final animValue = _cardAnimations[index].value;
            final scale = isPressed ? 0.95 : (1.0 + animValue * 0.05);

            return Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: isSelected ? 0.95 : 0.85),
                  border: Border.all(
                    color: isSelected
                        ? data.gradient.last
                        : const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? data.gradient.first.withValues(alpha: 0.3)
                          : const Color(0xFF2E7D32).withValues(alpha: 0.08),
                      blurRadius: isSelected ? 20 : 10,
                      spreadRadius: isSelected ? 2 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Icon(
                          data.icon,
                          size: 120,
                          color: data.gradient.first.withValues(alpha: 0.06),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: data.gradient,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: data.gradient.first.withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                data.icon,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            // Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.title,
                                    style: AppTypography.h3.copyWith(
                                      color: const Color(0xFF2E7D32),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    data.description,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Arrow
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: data.gradient.first.withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color: data.gradient.last,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Text(
        l10n.roleSelectionFooter,
        style: AppTypography.bodyMedium.copyWith(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Role data model
class _RoleData {
  final UserRole role;
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _RoleData({
    required this.role,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

