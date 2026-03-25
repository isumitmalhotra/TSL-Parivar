import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';
import 'role_selection_screen.dart';

/// Modern login screen with phone + OTP verification
///
/// Features:
/// - Beautiful gradient background
/// - Animated input fields
/// - Country code selector
/// - Language toggle
/// - Smooth transitions
/// - Real Firebase OTP authentication
class LoginScreen extends StatefulWidget {
  /// User's selected role
  final UserRole role;

  /// Callback when login is submitted (OTP sent successfully)
  final void Function(String phoneNumber)? onSubmit;

  /// Callback to go back
  final VoidCallback? onBack;

  const LoginScreen({
    super.key,
    required this.role,
    this.onSubmit,
    this.onBack,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _buttonController;

  bool _isLoading = false;
  String? _errorText;
  String _countryCode = '+91';

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _phoneFocusNode.addListener(() => setState(() {}));

    // Set the role in AuthProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().selectRole(widget.role);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _backgroundController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final l10n = AppLocalizations.of(context);
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() => _errorText = l10n.loginPhoneRequired);
      return;
    }

    if (phone.length < 10) {
      setState(() => _errorText = l10n.loginPhoneError);
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final fullPhoneNumber = '$_countryCode$phone';
    debugPrint('🧪[OTP:UI] submit phone=$fullPhoneNumber role=${widget.role.key}');

    // Send OTP using Firebase Auth via AuthProvider
    final success = await authProvider.sendOtp(fullPhoneNumber);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        // OTP sent successfully, navigate to OTP screen
        widget.onSubmit?.call(fullPhoneNumber);
      } else {
        // Show error from AuthProvider
        setState(() {
          _errorText = authProvider.errorMessage ??
              l10n.loginSendOtpFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(size),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: size.height - MediaQuery.of(context).padding.top,
                child: Column(
                  children: [
                    // Header with back and language toggle
                    _buildHeader(l10n),

                    const Spacer(flex: 1),

                    // Main content
                    _buildMainContent(l10n),

                    const Spacer(flex: 2),

                    // Terms and conditions
                    _buildTerms(l10n),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
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
          width: size.width,
          height: size.height,
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
          child: Stack(
            children: [
              // Animated decorative shapes
              ..._buildDecorativeShapes(size),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDecorativeShapes(Size size) {
    final offset = _backgroundController.value * 2 * math.pi;

    return [
      // Top right blob
      Positioned(
        right: -50 + math.sin(offset) * 20,
        top: -50 + math.cos(offset) * 20,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
      // Bottom left blob
      Positioned(
        left: -80 + math.cos(offset * 0.5) * 30,
        bottom: 100 + math.sin(offset * 0.5) * 30,
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.secondary.withValues(alpha: 0.1),
                AppColors.secondary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
      // Center decorative circle
      Positioned(
        right: size.width * 0.2 + math.sin(offset * 0.7) * 15,
        top: size.height * 0.3 + math.cos(offset * 0.7) * 15,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          _build3DIconButton(
            icon: Icons.arrow_back,
            onTap: widget.onBack,
          ),
          // Language toggle
          const TslLanguageToggle(
            style: TslLanguageToggleStyle.toggle,
          ),
        ],
      ),
    );
  }

  Widget _build3DIconButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 10,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildMainContent(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _contentController,
          curve: Curves.easeOutCubic,
        ));

        final opacityAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Role badge
                  _buildRoleBadge(l10n),

                  const SizedBox(height: AppSpacing.xl),

                  // Welcome text
                  Text(
                    l10n.loginTitle,
                    style: AppTypography.h1.copyWith(
                      fontSize: 32,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.loginSubtitle,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Phone input
                  _buildPhoneInput(l10n),

                  const SizedBox(height: AppSpacing.xxl),

                  // Continue button
                  _buildContinueButton(l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(AppLocalizations l10n) {
    final roleData = _getRoleData(l10n);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: roleData.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: roleData.color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                roleData.icon,
                size: 18,
                color: roleData.color,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                roleData.title,
                style: AppTypography.labelMedium.copyWith(
                  color: roleData.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _RoleDisplayData _getRoleData(AppLocalizations l10n) {
    switch (widget.role) {
      case UserRole.mistri:
        return _RoleDisplayData(
          title: l10n.roleMistri,
          icon: Icons.construction,
          color: AppColors.primary,
        );
      case UserRole.dealer:
        return _RoleDisplayData(
          title: l10n.roleDealer,
          icon: Icons.store,
          color: AppColors.secondary,
        );
      case UserRole.architect:
        return _RoleDisplayData(
          title: l10n.roleArchitect,
          icon: Icons.architecture,
          color: AppColors.info,
        );
    }
  }

  Widget _buildPhoneInput(AppLocalizations l10n) {
    final isFocused = _phoneFocusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _errorText != null
              ? AppColors.error
              : isFocused
                  ? AppColors.primary
                  : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isFocused ? 20 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Country code selector
          GestureDetector(
            onTap: _showCountryCodePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Text('🇮🇳', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _countryCode,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Phone input
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                hintText: l10n.loginPhoneHint,
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCountryCodePicker() {
    final l10n = AppLocalizations.of(context);
    // For now, India only
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.loginIndiaOnly),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.info,
      ),
    );
  }

  Widget _buildContinueButton(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_errorText != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        AnimatedBuilder(
          animation: _buttonController,
          builder: (context, child) {
            final glowOpacity = 0.3 + _buttonController.value * 0.2;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: glowOpacity),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _onSubmit,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4CAF50),
                          AppColors.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        else ...[
                          Text(
                            l10n.loginSendOtp,
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTerms(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Text.rich(
        TextSpan(
          text: '${l10n.byPhoneAuth} ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: l10n.termsOfService,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' ${l10n.andText} '),
            TextSpan(
              text: l10n.privacyPolicy,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Role display data
class _RoleDisplayData {
  final String title;
  final IconData icon;
  final Color color;

  const _RoleDisplayData({
    required this.title,
    required this.icon,
    required this.color,
  });
}

