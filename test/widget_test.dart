import 'package:flutter_test/flutter_test.dart';

import 'package:account_erp_app/config/token_storage.dart';
import 'package:account_erp_app/main.dart';
import 'package:account_erp_app/network/service_locator.dart';

void main() {
  setUpAll(() async {
    await initServiceLocator(tokenStorage: TokenStorage.inMemory());
  });

  testWidgets('shows the sign-in form when no session is stored',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AccountErpApp());
    await tester.pumpAndSettle();

    // Sign In form should be shown.
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
