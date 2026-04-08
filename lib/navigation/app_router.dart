import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/profile_completion_screen.dart';
import '../screens/mistri/mistri_shell_screen.dart';
import '../screens/mistri/mistri_delivery_details_screen.dart';
import '../screens/mistri/mistri_pod_submission_screen.dart';
import '../screens/mistri/mistri_request_order_screen.dart';
import '../screens/dealer/dealer_shell_screen.dart';
import '../screens/dealer/dealer_pending_approvals_screen.dart';
import '../screens/dealer/dealer_rewards_screen.dart';
import '../screens/architect/architect_shell_screen.dart';
import '../screens/architect/architect_create_spec_screen.dart';
import '../screens/architect/architect_rewards_screen.dart';
import '../models/architect_models.dart';
import '../screens/shared/notification_center_screen.dart';
import '../screens/shared/chat_screen.dart';
import '../screens/shared/legal_document_screen.dart';
import '../screens/shared/profile_screen.dart';
import '../screens/shared/product_catalog_screen.dart';
import '../screens/shared/product_detail_screen.dart';
import '../models/shared_models.dart';

/// App route paths
class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String profileCompletion = '/complete-profile';

  // Mistri routes
  static const String mistriHome = '/mistri';
  static const String mistriDeliveries = '/mistri/deliveries';
  static const String mistriDeliveryDetails = '/mistri/deliveries/:id';
  static const String mistriPodSubmission = '/mistri/deliveries/:id/pod';
  static const String mistriRewards = '/mistri/rewards';
  static const String mistriRequestOrder = '/mistri/request-order';

  // Dealer routes
  static const String dealerHome = '/dealer';
  static const String dealerMistris = '/dealer/mistris';
  static const String dealerOrders = '/dealer/orders';
  static const String dealerPendingApprovals = '/dealer/pending-approvals';
  static const String dealerRewards = '/dealer/rewards';

  // Architect routes
  static const String architectHome = '/architect';
  static const String architectProjects = '/architect/projects';
  static const String architectCreateSpec = '/architect/create-spec';
  static const String architectRewards = '/architect/rewards';

  // Shared routes
  static const String notifications = '/notifications';
  static const String profile = '/profile/:role';
  static const String chat = '/chat/:id';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String legalPrivacy = '/legal/privacy';
  static const String legalTerms = '/legal/terms';

  static String profileForRole(UserRole role) => '/profile/${role.name}';

  static String chatWithId(String contactId) => '/chat/$contactId';
}

/// App router configuration
class AppRouter {
  AppRouter._();

  static UserRole? _userRoleFromName(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final role in UserRole.values) {
      if (role.name == value) return role;
    }
    return null;
  }

  static const _sharedProtectedPrefixes = [
    '/notifications',
    '/products',
    '/chat',
    '/chat-contacts',
    '/profile',
  ];

  static String _homeForRole(UserRole role) {
    switch (role) {
      case UserRole.mistri:
        return AppRoutes.mistriHome;
      case UserRole.dealer:
        return AppRoutes.dealerHome;
      case UserRole.architect:
        return AppRoutes.architectHome;
    }
  }

  static UserRole? _roleForPath(String path) {
    if (path.startsWith('/mistri')) return UserRole.mistri;
    if (path.startsWith('/dealer')) return UserRole.dealer;
    if (path.startsWith('/architect')) return UserRole.architect;
    return null;
  }

  static bool _isSharedProtectedPath(String path) {
    return _sharedProtectedPrefixes.any(path.startsWith);
  }

  static String _safeAuthenticatedFallback(UserRole? role) {
    if (role == null) return AppRoutes.roleSelection;
    return _homeForRole(role);
  }

  static String? _canonicalRoleRoute(String path) {
    switch (path) {
      case AppRoutes.dealerOrders:
        return '${AppRoutes.dealerHome}?tab=orders';
      case AppRoutes.dealerMistris:
        return '${AppRoutes.dealerHome}?tab=mistris';
      case AppRoutes.mistriDeliveries:
        return '${AppRoutes.mistriHome}?tab=deliveries';
      case AppRoutes.mistriRewards:
        return '${AppRoutes.mistriHome}?tab=rewards';
      case AppRoutes.architectProjects:
        return '${AppRoutes.architectHome}?tab=projects';
      default:
        return null;
    }
  }

  @visibleForTesting
  static String? resolveRedirect({
    required String currentPath,
    required bool isAuthenticated,
    required UserRole? authRole,
    bool canEvaluateProfileCompletion = false,
    bool isProfileComplete = true,
    String? profileRoleParam,
    bool hasLoginRoleContext = true,
    bool hasOtpContext = true,
    bool hasSeenOnboarding = true,
    bool isAuthInitialized = true,
  }) {
    if (!isAuthInitialized) {
      return currentPath == AppRoutes.splash ? null : AppRoutes.splash;
    }

    if (currentPath == AppRoutes.splash) {
      if (!hasSeenOnboarding) {
        return AppRoutes.onboarding;
      }
      return isAuthenticated
          ? _safeAuthenticatedFallback(authRole)
          : AppRoutes.roleSelection;
    }

    if (!hasSeenOnboarding &&
        !isAuthenticated &&
        currentPath != AppRoutes.onboarding) {
      return AppRoutes.onboarding;
    }

    final isPublicRoute = _publicRoutes.contains(currentPath);

    if (currentPath == AppRoutes.onboarding && hasSeenOnboarding) {
      return isAuthenticated
          ? _safeAuthenticatedFallback(authRole)
          : AppRoutes.roleSelection;
    }

    if (!isAuthenticated && !isPublicRoute) {
      return AppRoutes.roleSelection;
    }

    if (!isAuthenticated &&
        currentPath == AppRoutes.login &&
        !hasLoginRoleContext) {
      return AppRoutes.roleSelection;
    }

    if (!isAuthenticated &&
        currentPath == AppRoutes.otpVerification &&
        !hasOtpContext) {
      return AppRoutes.roleSelection;
    }

    if (!isAuthenticated) {
      return null;
    }

    if (authRole == null) {
      return AppRoutes.roleSelection;
    }

    final requiresProfileCompletion =
        canEvaluateProfileCompletion && !isProfileComplete;
    if (requiresProfileCompletion && currentPath != AppRoutes.profileCompletion) {
      return AppRoutes.profileCompletion;
    }

    if (!requiresProfileCompletion && currentPath == AppRoutes.profileCompletion) {
      return _homeForRole(authRole);
    }

    if (isAuthenticated && isPublicRoute) {
      return _safeAuthenticatedFallback(authRole);
    }

    if (currentPath.startsWith('/profile/')) {
      if (profileRoleParam != authRole.name) {
        return AppRoutes.profileForRole(authRole);
      }
    }

    final routeRole = _roleForPath(currentPath);
    if (routeRole != null && routeRole != authRole) {
      return _homeForRole(authRole);
    }

    if (!isPublicRoute &&
        routeRole == null &&
        !_isSharedProtectedPath(currentPath) &&
        currentPath != AppRoutes.profileCompletion) {
      return _homeForRole(authRole);
    }

    final canonicalRoute = _canonicalRoleRoute(currentPath);
    if (canonicalRoute != null && canonicalRoute != currentPath) {
      return canonicalRoute;
    }

    return null;
  }

  static int _mistriTabFromQuery(GoRouterState state) {
    switch (state.uri.queryParameters['tab']) {
      case 'deliveries':
        return 1;
      case 'rewards':
        return 2;
      default:
        return 0;
    }
  }

  static int _dealerTabFromQuery(GoRouterState state) {
    switch (state.uri.queryParameters['tab']) {
      case 'orders':
        return 1;
      case 'mistris':
        return 2;
      default:
        return 0;
    }
  }

  static int _architectTabFromQuery(GoRouterState state) {
    switch (state.uri.queryParameters['tab']) {
      case 'projects':
        return 1;
      case 'rewards':
        return 2;
      default:
        return 0;
    }
  }

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter get router => _router;

  /// Auth routes that don't require authentication
  static const _publicRoutes = [
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.roleSelection,
    AppRoutes.login,
    AppRoutes.otpVerification,
    AppRoutes.legalPrivacy,
    AppRoutes.legalTerms,
  ];

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      final roleFromQuery = _userRoleFromName(state.uri.queryParameters['role']);
      final loginRoleFromExtra = state.extra is UserRole ? state.extra as UserRole : null;
      final hasLoginRoleContext =
          loginRoleFromExtra != null || roleFromQuery != null;

      final otpExtra = state.extra;
      final otpData = otpExtra is Map<String, dynamic> ? otpExtra : null;
      final otpPhoneFromExtra =
          otpData == null ? null : otpData['phone'] as String?;
      final otpRoleRaw = otpData == null ? null : otpData['role'];
      final otpRoleFromExtra = otpRoleRaw is UserRole
          ? otpRoleRaw
          : null;
      final otpPhoneFromQuery = state.uri.queryParameters['phone'];
      final otpRoleFromQuery = roleFromQuery;
      final hasOtpContext =
          ((otpPhoneFromExtra?.isNotEmpty ?? false) && otpRoleFromExtra != null) ||
          ((otpPhoneFromQuery?.isNotEmpty ?? false) && otpRoleFromQuery != null);

      return resolveRedirect(
        currentPath: state.uri.path,
        isAuthenticated: authProvider.isAuthenticated,
        authRole: authProvider.userRole,
        canEvaluateProfileCompletion:
            authProvider.isAuthenticated && userProvider.canEvaluateProfileCompleteness,
        isProfileComplete: userProvider.isProfileComplete,
        profileRoleParam: state.pathParameters['role'],
        hasLoginRoleContext: hasLoginRoleContext,
        hasOtpContext: hasOtpContext,
        hasSeenOnboarding: authProvider.hasSeenOnboarding,
        isAuthInitialized: authProvider.isInitialized,
      );
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: SplashScreen(
            onComplete: () {
              final authProvider = context.read<AuthProvider>();
              if (!authProvider.hasSeenOnboarding) {
                context.go(AppRoutes.onboarding);
                return;
              }

              if (authProvider.isAuthenticated &&
                  authProvider.userRole != null) {
                final userProvider = context.read<UserProvider>();
                if (userProvider.canEvaluateProfileCompleteness &&
                    !userProvider.isProfileComplete) {
                  context.go(AppRoutes.profileCompletion);
                  return;
                }
                context.go(_homeForRole(authProvider.userRole!));
                return;
              }

              context.go(AppRoutes.roleSelection);
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Onboarding Screen
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: OnboardingScreen(
            onComplete: () {
              unawaited(context.read<AuthProvider>().markOnboardingSeen());
              context.go(AppRoutes.roleSelection);
            },
            onSkip: () {
              unawaited(context.read<AuthProvider>().markOnboardingSeen());
              context.go(AppRoutes.roleSelection);
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Role Selection Screen
      GoRoute(
        path: AppRoutes.roleSelection,
        name: 'roleSelection',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: RoleSelectionScreen(
            onRoleSelected: (role) => context.go(
              '${AppRoutes.login}?role=${role.name}',
              extra: role,
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      // Login Screen
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) {
          final roleFromExtra = state.extra is UserRole ? state.extra as UserRole : null;
          final roleFromQuery = _userRoleFromName(
            state.uri.queryParameters['role'],
          );
          final role = roleFromExtra ?? roleFromQuery ?? UserRole.mistri;
          return CustomTransitionPage(
            key: state.pageKey,
            child: LoginScreen(
              role: role,
              onSubmit: (phone) => context.push(
                '${AppRoutes.otpVerification}?phone=${Uri.encodeComponent(phone)}&role=${role.name}',
                extra: {'phone': phone, 'role': role},
              ),
              onBack: () => context.go(AppRoutes.roleSelection),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),

      // OTP Verification Screen
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otpVerification',
        pageBuilder: (context, state) {
          final data = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : const <String, dynamic>{};
          final phone =
              data['phone'] as String? ?? state.uri.queryParameters['phone'] ?? '';
          final role =
              data['role'] as UserRole? ??
              _userRoleFromName(state.uri.queryParameters['role']) ??
              UserRole.mistri;

          return CustomTransitionPage(
            key: state.pageKey,
            child: OtpVerificationScreen(
              phoneNumber: phone,
              onVerified: (otp) {
                // Route through centralized guards (role + profile completion).
                context.go(AppRoutes.splash);
              },
              onBack: () => context.pop(),
              onResend: () async {
                // Resend OTP via auth provider
                if (phone.isNotEmpty) {
                  return context.read<AuthProvider>().sendOtp(phone);
                }
                return false;
              },
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),

      // Mistri Shell (with bottom navigation)
      GoRoute(
        path: AppRoutes.mistriHome,
        name: 'mistriHome',
        pageBuilder: (context, state) {
          final initialIndex = _mistriTabFromQuery(state);
          return CustomTransitionPage(
            key: state.pageKey,
            child: MistriShellScreen(initialIndex: initialIndex),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
        routes: [
          // Delivery Details
          GoRoute(
            path: 'deliveries/:id',
            name: 'mistriDeliveryDetails',
            pageBuilder: (context, state) {
              final deliveryId = state.pathParameters['id'] ?? '';
              return CustomTransitionPage(
                key: state.pageKey,
                child: MistriDeliveryDetailsScreen(deliveryId: deliveryId),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      );
                    },
              );
            },
            routes: [
              // POD Submission
              GoRoute(
                path: 'pod',
                name: 'mistriPodSubmission',
                pageBuilder: (context, state) {
                  final deliveryId = state.pathParameters['id'] ?? '';
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: MistriPodSubmissionScreen(deliveryId: deliveryId),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0, 1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: child,
                          );
                        },
                  );
                },
              ),
            ],
          ),
          // Request Order
          GoRoute(
            path: 'request-order',
            name: 'mistriRequestOrder',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MistriRequestOrderScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    );
                  },
            ),
          ),
        ],
      ),

      // Dealer Shell (with bottom navigation)
      GoRoute(
        path: AppRoutes.dealerHome,
        name: 'dealerHome',
        pageBuilder: (context, state) {
          final initialIndex = _dealerTabFromQuery(state);
          return CustomTransitionPage(
            key: state.pageKey,
            child: DealerShellScreen(initialIndex: initialIndex),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
        routes: [
          // Pending Approvals
          GoRoute(
            path: 'pending-approvals',
            name: 'dealerPendingApprovals',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DealerPendingApprovalsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    );
                  },
            ),
          ),
          // Rewards
          GoRoute(
            path: 'rewards',
            name: 'dealerRewards',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DealerRewardsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    );
                  },
            ),
          ),
        ],
      ),

      // Architect Shell (with bottom navigation)
      GoRoute(
        path: AppRoutes.architectHome,
        name: 'architectHome',
        pageBuilder: (context, state) {
          final initialIndex = _architectTabFromQuery(state);
          return CustomTransitionPage(
            key: state.pageKey,
            child: ArchitectShellScreen(initialIndex: initialIndex),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
        routes: [
          // Create Specification
          GoRoute(
            path: 'create-spec',
            name: 'architectCreateSpec',
            pageBuilder: (context, state) {
              final existingProject = state.extra as ArchitectProject?;
              return CustomTransitionPage(
                key: state.pageKey,
                child: ArchitectCreateSpecScreen(
                  existingProject: existingProject,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      );
                    },
              );
            },
          ),
          // Rewards
          GoRoute(
            path: 'rewards',
            name: 'architectRewards',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ArchitectRewardsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    );
                  },
            ),
          ),
        ],
      ),

      // Shared routes (all roles)
      GoRoute(
        path: AppRoutes.profileCompletion,
        name: 'profileCompletion',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileCompletionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationCenterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) {
          final roleParam = state.pathParameters['role'] ?? 'mistri';
          final role = UserRole.values.firstWhere(
            (r) => r.name == roleParam,
            orElse: () => UserRole.mistri,
          );
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProfileScreen(
              userRole: role,
              onLogout: () => context.go(AppRoutes.splash),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        pageBuilder: (context, state) {
          final contactId = state.pathParameters['id'] ?? '';
          final contact = state.extra as ChatContact?;
          final canOpenConversation =
              contact != null &&
              contact.id == contactId &&
              contact.chatId != null;

          return CustomTransitionPage(
            key: state.pageKey,
            child: canOpenConversation
                ? ChatScreen(contact: contact)
                : const ChatContactsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
      // Product Catalog
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProductCatalogScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      // Product Detail
      GoRoute(
        path: '/products/:id',
        name: 'productDetail',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(productId: productId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.legalPrivacy,
        name: 'legalPrivacy',
        builder: (context, state) => const LegalDocumentScreen(
          title: 'Privacy Policy',
          sections: LegalDocumentScreen.privacyPolicySections,
        ),
      ),
      GoRoute(
        path: AppRoutes.legalTerms,
        name: 'legalTerms',
        builder: (context, state) => const LegalDocumentScreen(
          title: 'Terms of Service',
          sections: LegalDocumentScreen.termsOfServiceSections,
        ),
      ),
      GoRoute(
        path: '/chat-contacts',
        name: 'chatContacts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ChatContactsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
    ],

    // Error handling
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: _ErrorScreen(error: state.error),
    ),
  );
}

/// Error screen
class _ErrorScreen extends StatelessWidget {
  final Exception? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'The requested page could not be found.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
