import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:account_erp_app/config/token_storage.dart';
import 'package:account_erp_app/main.dart';
import 'package:account_erp_app/network/service_locator.dart';

void main() {
  setUpAll(() async {
    await initServiceLocator(tokenStorage: TokenStorage.inMemory());
  });

  testWidgets('shows the sign-in form when no session is stored', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AccountErpApp());
    await tester.pumpAndSettle();

    // Sign In form should be shown.
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('Register link opens the sign-up modal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AccountErpApp());
    await tester.pumpAndSettle();

    expect(find.text("Don't have an account?"), findsOneWidget);
    final registerLink = find.widgetWithText(TextButton, 'Register');
    await tester.ensureVisible(registerLink);
    await tester.pumpAndSettle();
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
  });
}
