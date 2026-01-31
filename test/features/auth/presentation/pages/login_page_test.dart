import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_finder/features/auth/presentation/pages/login_page.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const ProviderScope(
      child: MaterialApp(home: LoginPage(role: 'student')),
    );
  }

  group('LoginPage Widget Tests', () {
    // Test 1: UI Rendering
    testWidgets('should display all login initial elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Login as student'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // Email and Password fields
      expect(find.text('Login'), findsOneWidget);
    });

    // Test 2: Form Validation
    testWidgets('should show validation errors when submitted empty', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final loginBtn = find.text('Login');
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    // Test 3: Input Interaction
    testWidgets('should populate text fields when entering text', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final emailField = find
          .ancestor(
            of: find.text('Email'),
            matching: find.byType(TextFormField),
          )
          .first;

      // Or simply find by type since order is known
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    // Test 4: Password Visibility Toggle
    testWidgets('should toggle password visibility when icon clicked', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initially visibility_off (obscured)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Now visibility (visible)
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    // Test 5: Checkbox Toggle
    testWidgets('should toggle "Remember Me" checkbox', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final checkboxFinder = find.byType(Checkbox);
      final checkboxWidget = tester.widget<Checkbox>(checkboxFinder);

      expect(checkboxWidget.value, false);

      await tester.tap(checkboxFinder);
      await tester.pump();

      final checkboxWidgetAfter = tester.widget<Checkbox>(checkboxFinder);
      expect(checkboxWidgetAfter.value, true);
    });
  });
}
