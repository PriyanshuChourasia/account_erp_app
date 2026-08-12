import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:account_erp_app/main.dart';
import 'package:account_erp_app/network/service_locator.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initServiceLocator();
  });

  testWidgets('shows the login screen when no session is stored',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AccountErpApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('register flow: navigation, validation and error handling',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AccountErpApp());
    await tester.pumpAndSettle();

    // Open the register screen from the login screen.
    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);

    // Submitting an empty form surfaces the validators.
    await tester.ensureVisible(find.text('Sign up'));
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);

    // Fill the form and submit. With no backend reachable the request fails
    // and the error handler shows a SnackBar; the screen stays put.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Priyanshu Sharma',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'priyanshu@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'priyanshu',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret123',
    );
    await tester.ensureVisible(find.text('Sign up'));
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);

    // Back returns to the login screen.
    await tester.ensureVisible(find.byTooltip('Back'));
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
