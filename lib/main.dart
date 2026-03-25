import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/providers.dart';
import 'services/firebase_service.dart';
import 'services/messaging_service.dart';

/// Entry point of the TSL Parivar application
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handling for production
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('❌ Flutter Error: ${details.exceptionAsString()}');
    debugPrint('Stack trace: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('❌ Platform Error: $error');
    debugPrint('Stack trace: $stack');
    return true;
  };

  // Initialize Firebase
  await FirebaseService.initialize();

  // Initialize Firebase Cloud Messaging
  await MessagingService.initialize();

  // Setup push notification handlers
  MessagingService.setupForegroundHandler((message) {
    debugPrint('🔔 Foreground notification: ${message.notification?.title}');
  });
  MessagingService.setupBackgroundHandler();
  MessagingService.setupNotificationOpenedHandler((message) {
    debugPrint('🔔 Notification opened: ${message.data}');
  });

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize providers
  final languageProvider = LanguageProvider();
  final authProvider = AuthProvider();

  // Initialize providers that need async setup
  await Future.wait([
    languageProvider.initialize(),
    authProvider.initialize(),
  ]);

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),

        // Data providers - created lazily
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, authProvider, userProvider) {
            final provider = userProvider ?? UserProvider();

            if (authProvider.isAuthenticated &&
                authProvider.userId != null &&
                authProvider.userRole != null) {
              unawaited(
                provider.loadUserData(
                  authProvider.userId!,
                  authProvider.userRole!,
                  phoneNumber: authProvider.phoneNumber,
                ),
              );
            } else {
              provider.clearUserData();
            }

            return provider;
          },
        ),
        ChangeNotifierProvider<DeliveryProvider>(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider<RewardsProvider>(create: (_) => RewardsProvider()),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(),
          update: (_, authProvider, notificationProvider) {
            final provider = notificationProvider ?? NotificationProvider();
            unawaited(provider.syncAuthState(
              isAuthenticated: authProvider.isAuthenticated,
              userId: authProvider.userId,
            ));
            return provider;
          },
        ),
      ],
      child: const TslApp(),
    ),
  );
}

