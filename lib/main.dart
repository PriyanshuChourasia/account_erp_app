import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme/app_theme.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/viewModel/auth_view_model.dart';
import 'features/auth/viewModel/register_view_model.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/dashboard/viewModel/dashboard_view_model.dart';
import 'modules/accounting_masters/modules/account_group/repository/account_group_repository.dart';
import 'modules/accounting_masters/modules/account_group/viewModel/account_group_view_model.dart';
import 'modules/accounting_masters/modules/account_nature/repository/account_nature_repository.dart';
import 'modules/accounting_masters/modules/account_nature/viewModel/account_nature_view_model.dart';
import 'modules/items/repository/item_repository.dart';
import 'modules/items/viewModel/item_view_model.dart';
import 'modules/inventory_masters/modules/stock_category/repository/stock_category_repository.dart';
import 'modules/inventory_masters/modules/stock_category/viewModel/stock_category_view_model.dart';
import 'modules/inventory_masters/modules/stock_group/repository/stock_group_repository.dart';
import 'modules/inventory_masters/modules/stock_group/viewModel/stock_group_view_model.dart';
import 'modules/inventory_masters/modules/unit/repository/unit_repository.dart';
import 'modules/inventory_masters/modules/unit/viewModel/unit_view_model.dart';
import 'modules/organisational_masters/modules/country/repository/country_repository.dart';
import 'modules/organisational_masters/modules/country/viewModel/country_view_model.dart';
import 'modules/organisational_masters/modules/state/repository/state_repository.dart';
import 'modules/organisational_masters/modules/state/viewModel/state_view_model.dart';
import 'network/service_locator.dart';
import 'routing/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  runApp(const AccountErpApp());
}

class AccountErpApp extends StatelessWidget {
  const AccountErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(globalService<AuthRepository>()),
        ),
        ChangeNotifierProvider<DashboardViewModel>(
          create: (_) => DashboardViewModel(),
        ),
        ChangeNotifierProvider<ItemViewModel>(
          create: (_) => ItemViewModel(globalService<ItemRepository>()),
        ),
        ChangeNotifierProvider<StockGroupViewModel>(
          create: (_) =>
              StockGroupViewModel(globalService<StockGroupRepository>()),
        ),
        ChangeNotifierProvider<StockCategoryViewModel>(
          create: (_) =>
              StockCategoryViewModel(globalService<StockCategoryRepository>()),
        ),
        ChangeNotifierProvider<UnitViewModel>(
          create: (_) => UnitViewModel(globalService<UnitRepository>()),
        ),
        ChangeNotifierProvider<CountryViewModel>(
          create: (_) => CountryViewModel(globalService<CountryRepository>()),
        ),
        ChangeNotifierProvider<StateViewModel>(
          create: (_) => StateViewModel(
            globalService<StateRepository>(),
            globalService<CountryRepository>(),
          ),
        ),
        ChangeNotifierProvider<AccountNatureViewModel>(
          create: (_) =>
              AccountNatureViewModel(globalService<AccountNatureRepository>()),
        ),
        ChangeNotifierProvider<AccountGroupViewModel>(
          create: (_) =>
              AccountGroupViewModel(globalService<AccountGroupRepository>()),
        ),
        // Register additional global ViewModels here.
      ],
      child: MaterialApp(
        title: 'Account ERP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const DashboardScreen(),
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => ChangeNotifierProvider(
            // Local provider: only the register screen needs this ViewModel.
            create: (_) => RegisterViewModel(globalService<AuthRepository>()),
            child: const RegisterScreen(),
          ),
          AppRoutes.dashboard: (_) => const DashboardScreen(),
        },
      ),
    );
  }
}
