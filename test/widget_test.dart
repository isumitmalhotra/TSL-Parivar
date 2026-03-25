// Basic widget test for TSL Parivar app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tsl/providers/language_provider.dart';

void main() {
  setUpAll(() async {
    // Mock SharedPreferences for tests
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LanguageProvider smoke test', (tester) async {
    // Create a language provider
    final languageProvider = LanguageProvider();
    await languageProvider.initialize();

    // Verify language provider is initialized
    expect(languageProvider.currentLocale, isNotNull);
    expect(languageProvider.isEnglish || languageProvider.isHindi, isTrue);

    // Test toggle functionality
    final initialLocale = languageProvider.currentLocale;
    await languageProvider.toggleLocale();
    expect(languageProvider.currentLocale != initialLocale, isTrue);

    // Toggle back
    await languageProvider.toggleLocale();
    expect(languageProvider.currentLocale, equals(initialLocale));
  });

  testWidgets('App basic structure test', (tester) async {
    // Test basic widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => const Center(
              child: Text('TSL Parivar Test'),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify the basic structure works
    expect(find.text('TSL Parivar Test'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
