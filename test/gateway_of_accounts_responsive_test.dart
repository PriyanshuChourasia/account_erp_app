import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:account_erp_app/config/theme/app_theme.dart';
import 'package:account_erp_app/config/token_storage.dart';
import 'package:account_erp_app/features/auth/viewModel/auth_view_model.dart';
import 'package:account_erp_app/features/gateway_of_accounts/screens/gateway_of_accounts_screen.dart';
import 'package:account_erp_app/modules/organisational_masters/modules/company/viewModel/company_view_model.dart';
import 'package:account_erp_app/network/service_locator.dart';

void main() {
  setUpAll(() async {
    await initServiceLocator(tokenStorage: TokenStorage.inMemory());
  });

  const sizes = <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(390, 844),
    Size(600, 800),
    Size(699, 800),
    Size(700, 800),
    Size(760, 600),
    Size(800, 600),
    Size(1024, 700),
    Size(1099, 800),
    Size(1100, 800),
    Size(1280, 800),
    Size(1600, 900),
    Size(1920, 1080),
    Size(700, 500),
    Size(1100, 500),
  ];

  for (final size in sizes) {
    testWidgets('no overflow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AuthViewModel(globalService()),
            ),
            ChangeNotifierProvider(
              create: (_) => CompanyViewModel(globalService()),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const GatewayOfAccountsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final exception = tester.takeException();
      expect(exception, isNull, reason: 'Exception at $size: $exception');
    });
  }

  testWidgets('no overflow with large text at 360x640', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel(globalService())),
          ChangeNotifierProvider(
            create: (_) => CompanyViewModel(globalService()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const GatewayOfAccountsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    expect(exception, isNull, reason: 'Exception with large text: $exception');
  });
}
