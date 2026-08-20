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

  testWidgets('shows the three auth tabs when no session is stored',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AccountErpApp());
    await tester.pumpAndSettle();

    // Default tab is License; all three tabs should be visible.
    expect(find.text('License'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Enter your license'), findsOneWidget);
  });

  testWidgets('tab switching: license, sign in, register',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AccountErpApp());
    await tester.pumpAndSettle();

    // Default: License tab content.
    expect(find.text('Enter your license'), findsOneWidget);

    // Switch to Sign In tab.
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    // Switch to Register tab.
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsAtLeastNWidgets(1));
  });

  testWidgets('register flow: inline tab, validation and cross-navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AccountErpApp());
    await tester.pumpAndSettle();

    // Switch to Register tab.
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsAtLeastNWidgets(1));

    // Submitting an empty form surfaces validators.
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();
    expect(find.text('Enter your name'), findsOneWidget);

    // Fill the form fields.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Priyanshu Sharma',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
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
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'secret123',
    );
    await tester.pumpAndSettle();

    // Submit the form — should switch to Sign In tab.
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    // Cross-nav: "Create one" goes to Register tab.
    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsAtLeastNWidgets(1));

    // Cross-nav: "Sign in" text button goes back to Sign In tab.
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
