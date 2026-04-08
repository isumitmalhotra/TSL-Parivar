import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shared_models.dart';
import '../../navigation/app_router.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dealer_data_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/biometric_service.dart';
import '../../services/url_launcher_service.dart';
import '../../widgets/widgets.dart';

/// Profile Screen
///
/// Features:
/// - User info display (name, role, phone, location)
/// - Edit profile functionality
/// - Settings section (language, notifications, privacy)
/// - Logout functionality
/// - Version info
class ProfileScreen extends StatefulWidget {
  final UserRole userRole;
  final VoidCallback? onLogout;

  const ProfileScreen({super.key, required this.userRole, this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  final BiometricService _biometricService = BiometricService();
  bool _isTogglingBiometric = false;

  UserProvider? _subscribedUserProvider;

  late AppUserProfile _profile;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    // Profile is hydrated from authenticated providers in didChangeDependencies.
    _profile = AppUserProfile(
      id: 'unknown',
      name: 'TSL User',
      phone: '',
      role: widget.userRole,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = context.read<UserProvider>();
    if (_subscribedUserProvider != userProvider) {
      _subscribedUserProvider?.removeListener(_handleUserProviderUpdated);
      _subscribedUserProvider = userProvider;
      _subscribedUserProvider?.addListener(_handleUserProviderUpdated);
    }
    _loadRealUserProfile();
  }

  void _handleUserProviderUpdated() {
    if (!mounted) return;
    _loadRealUserProfile();
    setState(() {});
  }

  /// Load real user data from providers.
  void _loadRealUserProfile() {
    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      if (authProvider.isAuthenticated) {
        final authUid = authProvider.userId;
        final authRole = authProvider.userRole ?? widget.userRole;

        if (!userProvider.hasUser &&
            !userProvider.isLoading &&
            authUid != null) {
          userProvider.loadUserData(
            authUid,
            authRole,
            phoneNumber: authProvider.phoneNumber,
          );
        }

        // Try UserProvider first (has richer data from Firestore)
        if (userProvider.hasUser) {
          final user = userProvider.currentUser!;
          _profile = AppUserProfile(
            id: user.id,
            name: user.name,
            phone: user.phone,
            role: user.role,
            email: user.email,
            location: user.roleSpecificData['location'] as String?,
            address: user.roleSpecificData['address'] as String?,
            joinedDate: user.joinedDate,
            rewardPoints:
                (user.roleSpecificData['approvedPoints'] as int?) ?? 0,
            rank: user.roleSpecificData['rank'] as String?,
          );
        } else if (authProvider.phoneNumber != null) {
          // Fallback while user profile is still being created/fetched.
          _profile = AppUserProfile(
            id: authProvider.userId ?? 'unknown',
            name: 'TSL User',
            phone: authProvider.phoneNumber ?? '',
            role: authProvider.userRole ?? widget.userRole,
            joinedDate: DateTime.now(),
          );
        }
      }
    } catch (_) {
      // Keep current in-memory profile if providers are not yet ready.
    }
  }

  @override
  void dispose() {
    _subscribedUserProvider?.removeListener(_handleUserProviderUpdated);
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricToggle(bool enabled) async {
    final l10n = AppLocalizations.of(context);
    final settingsProvider = context.read<AppSettingsProvider>();

    if (_isTogglingBiometric) return;
    setState(() => _isTogglingBiometric = true);

    try {
      if (!enabled) {
        await settingsProvider.setBiometricEnabled(enabled: false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.biometricAuth} disabled')),
        );
        return;
      }

      final isDeviceSupported = await _biometricService.isDeviceSupported();
      final canCheck = await _biometricService.canCheckBiometrics();
      final hasBiometrics = await _biometricService.hasEnrolledBiometrics();

      if (!mounted) return;

      if (!isDeviceSupported || !canCheck || !hasBiometrics) {
        await settingsProvider.setBiometricEnabled(enabled: false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.biometricAuth} is not available on this device',
            ),
          ),
        );
        return;
      }

      final authenticated = await _biometricService.authenticate();
      if (!mounted) return;

      if (!authenticated) {
        await settingsProvider.setBiometricEnabled(enabled: false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Biometric verification failed. Please use OTP login.',
            ),
          ),
        );
        return;
      }

      await settingsProvider.setBiometricEnabled(enabled: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.biometricAuth} enabled successfully')),
      );
    } catch (_) {
      if (!mounted) return;
      await settingsProvider.setBiometricEnabled(enabled: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update biometric setting. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isTogglingBiometric = false);
      }
    }
  }

  Future<void> _launchAction(
    Future<bool> Function() launchAction,
    String failureMessage,
  ) async {
    final ok = await launchAction();
    if (!mounted || ok) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failureMessage)));
  }

  Future<void> _shareApp() async {
    final ok = await UrlLauncherService.launchShareApp();
    if (ok || !mounted) return;

    const appUrl =
        'https://play.google.com/store/apps/details?id=com.tslsteel.parivar';
    await Clipboard.setData(const ClipboardData(text: appUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App link copied to clipboard.')),
    );
  }

  Color get _roleColor {
    switch (widget.userRole) {
      case UserRole.mistri:
        return const Color(0xFF388E3C);
      case UserRole.dealer:
        return const Color(0xFF2E7D32);
      case UserRole.architect:
        return const Color(0xFF1B5E20);
    }
  }

  List<Color> get _gradientColors {
    switch (widget.userRole) {
      case UserRole.mistri:
        return [const Color(0xFF4CAF50), const Color(0xFF81C784)];
      case UserRole.dealer:
        return [const Color(0xFF2E7D32), const Color(0xFF66BB6A)];
      case UserRole.architect:
        return [const Color(0xFF1B5E20), const Color(0xFF4CAF50)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileCard(),
                _buildStatsSection(),
                _buildQuickActions(),
                _buildSettingsSection(),
                _buildSupportSection(),
                _buildLogoutSection(),
                _buildVersionInfo(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: _roleColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () => _showEditProfileSheet(),
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_outlined, color: Colors.white),
          onPressed: () => _showQRCode(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(background: _buildHeaderContent()),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _ProfilePatternPainter(color: Colors.white),
            ),
          ),
          // Decorative circles
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Avatar
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final floatOffset =
                          math.sin(_floatController.value * math.pi) * 4;
                      return Transform.translate(
                        offset: Offset(0, floatOffset),
                        child: _buildAvatar(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Name
                  Text(
                    _profile.name,
                    style: AppTypography.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.userRole.icon,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _profile.rank ?? widget.userRole.displayName,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _profile.name[0].toUpperCase(),
              style: AppTypography.h1.copyWith(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.verified, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.phone_outlined, l10n.phoneNumber, _profile.phone),
          const Divider(height: AppSpacing.xl),
          _buildInfoRow(
            Icons.email_outlined,
            'Email',
            _profile.email ?? l10n.profileNotSet,
          ),
          const Divider(height: AppSpacing.xl),
          _buildInfoRow(
            Icons.location_on_outlined,
            l10n.location,
            _profile.location ?? l10n.profileNotSet,
          ),
          const Divider(height: AppSpacing.xl),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            l10n.profileMemberSince,
            _profile.joinedDate != null
                ? _formatDate(_profile.joinedDate!)
                : l10n.profileUnknown,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _roleColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _roleColor, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _roleColor.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.star_outline,
              '${_profile.rewardPoints}',
              l10n.pointsEarned,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.local_shipping_outlined,
              _getStatValue1(),
              _getStatLabel1(l10n),
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.trending_up,
              _getStatValue2(),
              _getStatLabel2(l10n),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatValue1() {
    final userProvider = context.watch<UserProvider>();
    switch (widget.userRole) {
      case UserRole.mistri:
        return '${userProvider.mistriData?.totalDeliveries ?? 0}';
      case UserRole.dealer:
        return '${context.watch<DealerDataProvider>().mistris.length}';
      case UserRole.architect:
        return '${userProvider.architectData?.activeProjects ?? 0}';
    }
  }

  String _getStatLabel1(AppLocalizations l10n) {
    switch (widget.userRole) {
      case UserRole.mistri:
        return l10n.deliveriesTitle;
      case UserRole.dealer:
        return l10n.navMistris;
      case UserRole.architect:
        return l10n.navProjects;
    }
  }

  String _getStatValue2() {
    final userProvider = context.watch<UserProvider>();
    switch (widget.userRole) {
      case UserRole.mistri:
        final successRate = userProvider.mistriData?.successRate ?? 0;
        return '${successRate.toStringAsFixed(0)}%';
      case UserRole.dealer:
        final volume = context
            .watch<DealerDataProvider>()
            .dealerUser
            .weeklyVolume;
        return volume.toStringAsFixed(1);
      case UserRole.architect:
        return '${userProvider.architectData?.completedSpecs ?? 0}';
    }
  }

  String _getStatLabel2(AppLocalizations l10n) {
    switch (widget.userRole) {
      case UserRole.mistri:
        return l10n.profileSuccess;
      case UserRole.dealer:
        return l10n.profileVolume;
      case UserRole.architect:
        return l10n.architectHomeSpecs;
    }
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              Icons.badge_outlined,
              l10n.profileIdCard,
              l10n.profileViewTslId,
              () => _showIDCard(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildQuickActionCard(
              Icons.history,
              l10n.profileActivity,
              l10n.tabHistory,
              () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _roleColor),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              AppLocalizations.of(context).settings,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingsItem(
            Icons.language_outlined,
            AppLocalizations.of(context).profileLanguage,
            _settings.languageCode == 'en'
                ? l10n.languageEnglish
                : l10n.languageHindi,
            onTap: () => _showLanguageSheet(),
          ),
          _buildSettingsItem(
            Icons.notifications_outlined,
            AppLocalizations.of(context).profileNotifications,
            _settings.notificationsEnabled
                ? l10n.profileEnabled
                : l10n.profileDisabled,
            hasToggle: true,
            toggleValue: _settings.notificationsEnabled,
            onToggle: (v) => unawaited(
              context.read<AppSettingsProvider>().setNotificationsEnabled(
                enabled: v,
              ),
            ),
          ),
          _buildSettingsItem(
            Icons.fingerprint,
            l10n.biometricAuth,
            _settings.biometricEnabled
                ? l10n.profileEnabled
                : l10n.profileDisabled,
            hasToggle: true,
            toggleValue: _settings.biometricEnabled,
            onToggle: (v) => unawaited(_handleBiometricToggle(v)),
          ),
          _buildSettingsItem(
            Icons.privacy_tip_outlined,
            l10n.privacyPolicy,
            '',
            onTap: () => context.push(AppRoutes.legalPrivacy),
          ),
          _buildSettingsItem(
            Icons.description_outlined,
            l10n.termsOfService,
            '',
            onTap: () => context.push(AppRoutes.legalTerms),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String value, {
    VoidCallback? onTap,
    bool hasToggle = false,
    bool toggleValue = false,
    ValueChanged<bool>? onToggle,
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasToggle ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(icon, color: colorScheme.onSurfaceVariant, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(title, style: AppTypography.bodyMedium)),
                  if (hasToggle)
                    (_isTogglingBiometric && icon == Icons.fingerprint)
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _roleColor,
                            ),
                          )
                        : Switch(
                            value: toggleValue,
                            onChanged: onToggle,
                            thumbColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return _roleColor;
                              }
                              return null;
                            }),
                            trackColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return _roleColor.withValues(alpha: 0.5);
                              }
                              return null;
                            }),
                          )
                  else ...[
                    if (value.isNotEmpty)
                      Text(
                        value,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 56),
      ],
    );
  }

  Widget _buildSupportSection() {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              l10n.helpSupport,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingsItem(
            Icons.help_outline,
            l10n.helpSupport,
            '',
            onTap: () => unawaited(
              _launchAction(
                UrlLauncherService.launchHelpSupport,
                'Unable to open Help & Support right now.',
              ),
            ),
          ),
          _buildSettingsItem(
            Icons.chat_bubble_outline,
            l10n.profileContactSupport,
            '',
            onTap: () => unawaited(
              _launchAction(
                UrlLauncherService.launchContactSupport,
                'Unable to open Contact Support right now.',
              ),
            ),
          ),
          _buildSettingsItem(
            Icons.star_outline,
            l10n.profileRateApp,
            '',
            onTap: () => unawaited(
              _launchAction(
                UrlLauncherService.launchRateApp,
                'Unable to open app rating page right now.',
              ),
            ),
          ),
          _buildSettingsItem(
            Icons.share_outlined,
            l10n.profileShareApp,
            '',
            onTap: () => unawaited(_shareApp()),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Material(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showLogoutConfirmation(),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, color: AppColors.error),
                const SizedBox(width: AppSpacing.md),
                Text(
                  AppLocalizations.of(context).profileLogout,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Text(
            'TSL Parivar',
            style: AppTypography.labelMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.profileBuildVersion,
            style: AppTypography.caption.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.profileCopyright,
            style: AppTypography.caption.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showEditProfileSheet() {
    final rootNavigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _EditProfileSheet(
        profile: _profile,
        roleColor: _roleColor,
        onSave: (profile) async {
          final userProvider = context.read<UserProvider>();
          if (!userProvider.hasUser) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Profile is still loading. Please try again.'),
              ),
            );
            return;
          }

          final success = await userProvider.updateProfile(
            name: profile.name,
            email: profile.email,
            location: profile.location,
            address: profile.address,
          );

          if (!mounted) return;

          if (success) {
            if (authProvider.userId != null && authProvider.userRole != null) {
              await userProvider.loadUserData(
                authProvider.userId!,
                authProvider.userRole!,
                phoneNumber: authProvider.phoneNumber,
              );
            }
            setState(() => _profile = profile);
            rootNavigator.pop();
          } else {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  userProvider.errorMessage ?? 'Failed to save profile changes',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showLanguageSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppLocalizations.of(context).selectLanguage,
              style: AppTypography.h2,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLanguageOption(
              AppLocalizations.of(context).languageEnglish,
              'en',
              Icons.language,
            ),
            _buildLanguageOption(
              AppLocalizations.of(context).languageHindi,
              'hi',
              Icons.translate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String label, String code, IconData icon) {
    final isSelected = _settings.languageCode == code;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isSelected
          ? _roleColor.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          context.read<AppSettingsProvider>().setLanguageCode(code);
          // Actually change the app locale via LanguageProvider
          context.read<LanguageProvider>().setLocaleByCode(
            code == 'en' ? 'EN' : 'HI',
          );
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? _roleColor : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? _roleColor : colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: _roleColor),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRCode() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).profileYourQrCode,
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_2,
                    size: 150,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _profile.name,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${AppLocalizations.of(context).profileIdPrefix}: ${_profile.id}',
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: TslPrimaryButton(
                  label: AppLocalizations.of(context).profileShareQrCode,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIDCard() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ID Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _roleColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/tsl_logo_white.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'TSL',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: _roleColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).appName.toUpperCase(),
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.userRole.displayName.toUpperCase(),
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _roleColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _profile.name[0],
                                style: AppTypography.h2.copyWith(
                                  color: _roleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile.name,
                                  style: AppTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${AppLocalizations.of(context).profileIdPrefix}: ${_profile.id}',
                                  style: AppTypography.caption.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _profile.phone,
                                  style: AppTypography.caption.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.qr_code,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: TslPrimaryButton(
                  label: AppLocalizations.of(context).profileShareIdCard,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout, color: AppColors.error),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(AppLocalizations.of(context).logoutConfirmTitle),
          ],
        ),
        content: Text(AppLocalizations.of(context).logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              widget.onLogout?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).profileLogout,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

extension on _ProfileScreenState {
  AppSettings get _settings => context.watch<AppSettingsProvider>().settings;
}

/// Edit profile sheet
class _EditProfileSheet extends StatefulWidget {
  final AppUserProfile profile;
  final Color roleColor;
  final Future<void> Function(AppUserProfile) onSave;

  const _EditProfileSheet({
    required this.profile,
    required this.roleColor,
    required this.onSave,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _locationController = TextEditingController(
      text: widget.profile.location ?? '',
    );
    _addressController = TextEditingController(
      text: widget.profile.address ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppLocalizations.of(context).editProfile,
              style: AppTypography.h2,
            ),
            const SizedBox(height: AppSpacing.xl),
            TslTextField(
              controller: _nameController,
              label: AppLocalizations.of(context).profileFullName,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: AppSpacing.lg),
            TslTextField(
              controller: _emailController,
              label: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.lg),
            TslTextField(
              controller: _locationController,
              label: AppLocalizations.of(context).profileCity,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),
            TslTextField(
              controller: _addressController,
              label: AppLocalizations.of(context).profileFullAddress,
              prefixIcon: Icons.home_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: TslPrimaryButton(
                label: AppLocalizations.of(context).profileSaveChanges,
                isLoading: _isSaving,
                onPressed: () async {
                  setState(() => _isSaving = true);
                  final updated = widget.profile.copyWith(
                    name: _nameController.text,
                    email: _emailController.text,
                    location: _locationController.text,
                    address: _addressController.text,
                  );
                  await widget.onSave(updated);
                  if (mounted) {
                    setState(() => _isSaving = false);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile pattern painter
class _ProfilePatternPainter extends CustomPainter {
  final Color color;

  _ProfilePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw curved lines
    for (var i = 0; i < 8; i++) {
      final path = Path();
      path.moveTo(0, size.height * (0.1 + i * 0.1));
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * (0.15 + i * 0.08),
        size.width,
        size.height * (0.05 + i * 0.12),
      );
      canvas.drawPath(path, paint);
    }

    // Draw circles
    final circlePaint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (var i = 0; i < 10; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        5 + random.nextDouble() * 15,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
