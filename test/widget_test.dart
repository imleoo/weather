// This is a basic Flutter widget test for the weather app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:weather/main.dart';
import 'package:weather/providers/weather_provider.dart';
import 'package:weather/providers/settings_provider.dart';
import 'package:weather/l10n/app_localizations.dart';
import 'package:weather/screens/main_navigation_screen.dart';

void main() {
  testWidgets('Weather app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for initialization
    await tester.pumpAndSettle();
    
    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Weather app has main navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for initialization
    await tester.pumpAndSettle();
    
    // Verify that the main navigation screen is present
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('Weather app supports localization', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for initialization
    await tester.pumpAndSettle();
    
    // Verify that localization delegates are present
    expect(find.byType(MaterialApp), findsOneWidget);
    final MaterialApp app = tester.widget(find.byType(MaterialApp)) as MaterialApp;
    expect(app.localizationsDelegates, isNotNull);
    expect(app.supportedLocales, isNotEmpty);
  });
}
