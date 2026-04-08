import 'package:flutter_test/flutter_test.dart';

import 'package:tsl/models/shared_models.dart';
import 'package:tsl/navigation/app_router.dart';

void main() {
  group('AppRouter role guard', () {
    test('unauthenticated user is redirected from protected route', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.dealerHome,
        isAuthenticated: false,
        authRole: null,
      );

      expect(redirect, AppRoutes.roleSelection);
    });

    test('authenticated dealer cannot access mistri routes', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.mistriHome,
        isAuthenticated: true,
        authRole: UserRole.dealer,
      );

      expect(redirect, AppRoutes.dealerHome);
    });

    test('authenticated dealer cannot access architect routes', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.architectHome,
        isAuthenticated: true,
        authRole: UserRole.dealer,
      );

      expect(redirect, AppRoutes.dealerHome);
    });

    test('authenticated mistri cannot access dealer routes', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.dealerHome,
        isAuthenticated: true,
        authRole: UserRole.mistri,
      );

      expect(redirect, AppRoutes.mistriHome);
    });

    test('authenticated mistri cannot access architect routes', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.architectHome,
        isAuthenticated: true,
        authRole: UserRole.mistri,
      );

      expect(redirect, AppRoutes.mistriHome);
    });

    test('authenticated architect cannot access dealer routes', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.dealerHome,
        isAuthenticated: true,
        authRole: UserRole.architect,
      );

      expect(redirect, AppRoutes.architectHome);
    });

    test('authenticated architect cannot access mistri routes', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.mistriHome,
        isAuthenticated: true,
        authRole: UserRole.architect,
      );

      expect(redirect, AppRoutes.architectHome);
    });

    test('profile role mismatch is corrected to authenticated role', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.profileForRole(UserRole.mistri),
        isAuthenticated: true,
        authRole: UserRole.dealer,
        profileRoleParam: UserRole.mistri.name,
      );

      expect(redirect, AppRoutes.profileForRole(UserRole.dealer));
    });

    test('shared protected route is allowed for authenticated user', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.products,
        isAuthenticated: true,
        authRole: UserRole.dealer,
      );

      expect(redirect, isNull);
    });

    test('authenticated user is redirected away from public auth route', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.login,
        isAuthenticated: true,
        authRole: UserRole.dealer,
      );

      expect(redirect, AppRoutes.dealerHome);
    });

    test('unauthenticated login route without role context goes to role selection', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.login,
        isAuthenticated: false,
        authRole: null,
        hasLoginRoleContext: false,
      );

      expect(redirect, AppRoutes.roleSelection);
    });

    test('unauthenticated otp route without context goes to role selection', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.otpVerification,
        isAuthenticated: false,
        authRole: null,
        hasOtpContext: false,
      );

      expect(redirect, AppRoutes.roleSelection);
    });

    test('authenticated user without role is redirected to role selection', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.dealerHome,
        isAuthenticated: true,
        authRole: null,
      );

      expect(redirect, AppRoutes.roleSelection);
    });

    test('authenticated unknown protected route falls back to role home', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: '/unsupported/route',
        isAuthenticated: true,
        authRole: UserRole.architect,
      );

      expect(redirect, AppRoutes.architectHome);
    });

    test('dealer deep link alias redirects to dealer tab route', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.dealerOrders,
        isAuthenticated: true,
        authRole: UserRole.dealer,
      );

      expect(redirect, '${AppRoutes.dealerHome}?tab=orders');
    });

    test('architect deep link alias redirects to architect tab route', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.architectProjects,
        isAuthenticated: true,
        authRole: UserRole.architect,
      );

      expect(redirect, '${AppRoutes.architectHome}?tab=projects');
    });

    test('mistri deep link alias redirects to mistri tab route', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.mistriRewards,
        isAuthenticated: true,
        authRole: UserRole.mistri,
      );

      expect(redirect, '${AppRoutes.mistriHome}?tab=rewards');
    });

    test('first launch redirects splash to onboarding', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.splash,
        isAuthenticated: false,
        authRole: null,
        hasSeenOnboarding: false,
      );

      expect(redirect, AppRoutes.onboarding);
    });

    test('returning unauthenticated user skips onboarding after splash', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.splash,
        isAuthenticated: false,
        authRole: null,
        hasSeenOnboarding: true,
      );

      expect(redirect, AppRoutes.roleSelection);
    });

    test('returning authenticated user goes to role home from splash', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.splash,
        isAuthenticated: true,
        authRole: UserRole.dealer,
        hasSeenOnboarding: true,
      );

      expect(redirect, AppRoutes.dealerHome);
    });

    test('authenticated incomplete profile is redirected to completion route', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.dealerHome,
        isAuthenticated: true,
        authRole: UserRole.dealer,
        canEvaluateProfileCompletion: true,
        isProfileComplete: false,
      );

      expect(redirect, AppRoutes.profileCompletion);
    });

    test('profile completion route redirects to role home when profile complete', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.profileCompletion,
        isAuthenticated: true,
        authRole: UserRole.mistri,
        canEvaluateProfileCompletion: true,
        isProfileComplete: true,
      );

      expect(redirect, AppRoutes.mistriHome);
    });

    test('profile completion route is allowed while profile is incomplete', () {
      final redirect = AppRouter.resolveRedirect(
        currentPath: AppRoutes.profileCompletion,
        isAuthenticated: true,
        authRole: UserRole.architect,
        canEvaluateProfileCompletion: true,
        isProfileComplete: false,
      );

      expect(redirect, isNull);
    });
  });
}


