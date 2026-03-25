import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
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

  static String profileForRole(UserRole role) => '/profile/${role.name}';
}

/// App router configuration
class AppRouter {
  AppRouter._();

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
  ];

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final currentPath = state.matchedLocation;
      final isPublicRoute = _publicRoutes.contains(currentPath);

      // If not authenticated and trying to access protected route, redirect to login
      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.roleSelection;
      }

      return null; // No redirect
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: SplashScreen(
            onComplete: () => context.go(AppRoutes.onboarding),
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
            onComplete: () => context.go(AppRoutes.roleSelection),
            onSkip: () => context.go(AppRoutes.roleSelection),
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
              AppRoutes.login,
              extra: role,
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
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
          final role = state.extra as UserRole? ?? UserRole.mistri;
          return CustomTransitionPage(
            key: state.pageKey,
            child: LoginScreen(
              role: role,
              onSubmit: (phone) => context.push(
                AppRoutes.otpVerification,
                extra: {'phone': phone, 'role': role},
              ),
              onBack: () => context.go(AppRoutes.roleSelection),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
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
          final data = state.extra as Map<String, dynamic>? ?? {};
          final phone = data['phone'] as String? ?? '';
          final role = data['role'] as UserRole? ?? UserRole.mistri;

          return CustomTransitionPage(
            key: state.pageKey,
            child: OtpVerificationScreen(
              phoneNumber: phone,
              onVerified: (otp) {
                // Navigate to role-specific home
                switch (role) {
                  case UserRole.mistri:
                    context.go(AppRoutes.mistriHome);
                    break;
                  case UserRole.dealer:
                    context.go(AppRoutes.dealerHome);
                    break;
                  case UserRole.architect:
                    context.go(AppRoutes.architectHome);
                    break;
                }
              },
              onBack: () => context.pop(),
              onResend: () {
                // Resend OTP via auth provider
                if (phone.isNotEmpty) {
                  context.read<AuthProvider>().sendOtp(phone);
                }
              },
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
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
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MistriShellScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
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
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
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
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
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
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
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
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DealerShellScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        routes: [
          // Pending Approvals
          GoRoute(
            path: 'pending-approvals',
            name: 'dealerPendingApprovals',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DealerPendingApprovalsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
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
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
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
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ArchitectShellScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        routes: [
          // Create Specification
          GoRoute(
            path: 'create-spec',
            name: 'architectCreateSpec',
            pageBuilder: (context, state) {
              final existingProject = state.extra as ArchitectProject?;
              return CustomTransitionPage(
                key: state.pageKey,
                child: ArchitectCreateSpecScreen(existingProject: existingProject),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
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
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),

      // Shared routes (all roles)
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationCenterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
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
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
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
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
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
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/chat-contacts',
        name: 'chatContacts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ChatContactsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
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
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'The requested page could not be found.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
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

