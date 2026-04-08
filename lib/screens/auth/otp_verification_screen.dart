import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

/// Beautiful OTP verification screen with animated input fields
///
/// Features:
/// - Animated OTP input boxes
/// - Auto-focus navigation
/// - Resend timer
/// - Success animation
/// - Smooth transitions
class OtpVerificationScreen extends StatefulWidget {
  /// Phone number to display
  final String phoneNumber;

  /// Callback when OTP is verified
  final void Function(String otp)? onVerified;

  /// Callback to go back
  final VoidCallback? onBack;

  /// Callback to resend OTP
  final Future<bool> Function()? onResend;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.onVerified,
    this.onBack,
    this.onResend,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _resendSeconds = 30;

  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _successController;
  late AnimationController _shakeController;

  Timer? _resendTimer;
  int _resendCountdown = _resendSeconds;
  bool _isVerifying = false;
  bool _isSuccess = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _startResendTimer();

    // Auto-focus first field after animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _backgroundController.dispose();
    _contentController.dispose();
    _successController.dispose();
    _shakeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = _resendSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCountdown--;
          if (_resendCountdown <= 0) {
            timer.cancel();
          }
        });
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Clear error when typing
    if (_errorText != null) {
      setState(() => _errorText = null);
    }

    // Check if OTP is complete
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == _otpLength) {
      _verifyOtp(otp);
    }
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp(String otp) async {
    debugPrint('🧪[OTP:UI] verify tapped phone=${widget.phoneNumber}');
    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    final authProvider = context.read<AuthProvider>();

    // Verify OTP using Firebase Auth via AuthProvider
    final success = await authProvider.verifyOtp(otp);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isVerifying = false;
        _isSuccess = true;
      });
      _successController.forward();

      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        widget.onVerified?.call(otp);
      }
    } else {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _isVerifying = false;
        _errorText = _readableOtpError(
          authProvider.errorMessage ?? l10n.otpError,
        );
      });
      _shakeController.forward(from: 0);
    }
  }

  String _readableOtpError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('missing-client-identifier') ||
        lower.contains('app verification failed')) {
      return 'App verification failed. Use Play Internal/Store build and try again.';
    }
    if (lower.contains('quota') || lower.contains('too many')) {
      return 'Too many OTP attempts. Please wait and try again later.';
    }
    if (lower.contains('network')) {
      return 'Network issue detected. Check connection and retry.';
    }
    if (lower.contains('expired') || lower.contains('session')) {
      return 'OTP expired. Please resend and enter the latest code.';
    }
    if (lower.contains('invalid')) {
      return 'Invalid OTP. Please check the code and try again.';
    }
    return raw;
  }

  Future<void> _resendOtp() async {
    final authProvider = context.read<AuthProvider>();
    final providerCooldown = authProvider.otpCooldownSecondsRemaining;
    if (_resendCountdown > 0 || providerCooldown > 0) return;
    debugPrint('🧪[OTP:UI] resend tapped phone=${widget.phoneNumber}');

    bool success;
    if (widget.onResend != null) {
      success = await widget.onResend!.call();
    } else if (authProvider.phoneNumber != null) {
      success = await authProvider.sendOtp(authProvider.phoneNumber!);
    } else {
      success = false;
    }

    if (success) {
      _startResendTimer();
    }

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? l10n.otpSentTo(widget.phoneNumber)
                : _readableOtpError(authProvider.errorMessage ?? l10n.otpError),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? AppColors.success : AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() => _errorText = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(size),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: AppSpacing.md),
                          _buildMainContent(l10n),
                          const Spacer(),
                          _buildFooter(l10n),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        final offset = _backgroundController.value * 2 * math.pi;

        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF101512),
                      Color(0xFF142019),
                      Color(0xFF1B2A22),
                      Color(0xFF23352A),
                    ]
                  : const [
                      Color(0xFFFFFFFF),
                      Color(0xFFF0FFF0),
                      Color(0xFFE8F5E9),
                      Color(0xFFC8E6C9),
                    ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30 + math.sin(offset) * 15,
                top: 100 + math.cos(offset) * 15,
                child: Container(
                  width: 150,
                  height: 150,
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
              ),
              Positioned(
                left: -50 + math.cos(offset * 0.5) * 20,
                bottom: 200 + math.sin(offset * 0.5) * 20,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.08),
                        AppColors.secondary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
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
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ],
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

        return SlideTransition(
          position: slideAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                // Icon
                _buildVerificationIcon(),

                const SizedBox(height: AppSpacing.xxl),

                // Title
                Text(
                  l10n.otpTitle,
                  style: AppTypography.h1.copyWith(
                    fontSize: 28,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.md),

                if (_isSuccess) ...[
                  _buildInlineSuccessTick(),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Subtitle
                Text(
                  l10n.otpSubtitle(widget.phoneNumber),
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // OTP Input
                _buildOtpInput(),

                // Error message
                if (_errorText != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildErrorMessage(),
                ],

                const SizedBox(height: AppSpacing.xxl),

                // Resend section
                _buildResendSection(l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shine effect
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          const Icon(
            Icons.sms_outlined,
            color: Colors.white,
            size: 45,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shakeOffset = math.sin(_shakeController.value * math.pi * 4) * 10;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_otpLength, (index) {
                final isFilled = _controllers[index].text.isNotEmpty;
                final isFocused = _focusNodes[index].hasFocus;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _otpLength - 1 ? AppSpacing.sm : 0,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isFilled
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _errorText != null
                            ? AppColors.error
                            : isFocused
                                ? AppColors.primary
                                : isFilled
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.border,
                        width: isFocused ? 2 : 1.5,
                      ),
                      boxShadow: [
                        if (isFocused)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) => _onKeyPressed(index, event),
                      child: Center(
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: AppTypography.h2.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            height: 1.0,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) => _onOtpChanged(index, value),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorText!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineSuccessTick() {
    return AnimatedBuilder(
      animation: _successController,
      builder: (context, child) {
        return Opacity(
          opacity: _successController.value,
          child: Transform.scale(
            scale: 0.8 + (_successController.value * 0.2),
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResendSection(AppLocalizations l10n) {
    final providerCooldown = context.watch<AuthProvider>().otpCooldownSecondsRemaining;
    final remaining = _resendCountdown > providerCooldown ? _resendCountdown : providerCooldown;
    final canResend = remaining <= 0;

    return Column(
      children: [
        Text(
          l10n.otpDidntReceive,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: canResend ? _resendOtp : null,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTypography.labelLarge.copyWith(
              color: canResend ? AppColors.primary : AppColors.textDisabled,
              fontWeight: FontWeight.w600,
            ),
            child: Text(
              canResend
                  ? l10n.otpResend
                  : l10n.otpResendCountdown(remaining),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    if (_isVerifying) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.otpVerifying,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: _clearOtp,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.otpClear),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

