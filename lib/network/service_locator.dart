import 'package:get_it/get_it.dart';

import '../config/token_storage.dart';
import '../features/auth/repository/auth_repository.dart';
import '../features/auth/services/auth_service.dart';
import '../modules/accounting_masters/modules/account_group/repository/account_group_repository.dart';
import '../modules/accounting_masters/modules/account_group/services/account_group_service.dart';
import '../modules/accounting_masters/modules/account_nature/repository/account_nature_repository.dart';
import '../modules/accounting_masters/modules/account_nature/services/account_nature_service.dart';
import '../modules/accounting_masters/modules/voucher_type/repository/voucher_type_repository.dart';
import '../modules/accounting_masters/modules/voucher_type/services/voucher_type_service.dart';
import '../modules/items/repository/item_repository.dart';
import '../modules/items/services/item_service.dart';
import '../modules/inventory_masters/modules/stock_category/repository/stock_category_repository.dart';
import '../modules/inventory_masters/modules/stock_category/services/stock_category_service.dart';
import '../modules/inventory_masters/modules/stock_group/repository/stock_group_repository.dart';
import '../modules/inventory_masters/modules/stock_group/services/stock_group_service.dart';
import '../modules/inventory_masters/modules/unit/repository/unit_repository.dart';
import '../modules/inventory_masters/modules/unit/services/unit_service.dart';
import '../modules/organisational_masters/modules/country/repository/country_repository.dart';
import '../modules/organisational_masters/modules/country/services/country_service.dart';
import '../modules/organisational_masters/modules/financial_year/repository/financial_year_repository.dart';
import '../modules/organisational_masters/modules/financial_year/services/financial_year_service.dart';
import '../modules/organisational_masters/modules/state/repository/state_repository.dart';
import '../modules/organisational_masters/modules/state/services/state_service.dart';
import 'api_service.dart';
import 'dio_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

final GetIt _getIt = GetIt.instance;

bool _isInitialized = false;

/// Resolves a registered dependency. Prefer this over touching GetIt directly.
T globalService<T extends Object>() => _getIt<T>();

/// Registers every singleton in the app. Call once from `main()` before
/// `runApp()`. Safe to call multiple times (e.g. from tests).
Future<void> initServiceLocator() async {
  if (_isInitialized) return;
  _isInitialized = true;

  _getIt
    ..registerLazySingleton<TokenStorage>(TokenStorage.new)
    ..registerLazySingleton<AuthInterceptor>(AuthInterceptor.new)
    ..registerLazySingleton<ErrorInterceptor>(ErrorInterceptor.new)
    ..registerLazySingleton<DioClient>(
      () => DioClient(
        authInterceptor: globalService<AuthInterceptor>(),
        errorInterceptor: globalService<ErrorInterceptor>(),
      ),
    )
    ..registerLazySingleton<ApiService>(
      () => ApiService(globalService<DioClient>().dio),
    )
    ..registerLazySingleton<AuthService>(
      () => AuthService(globalService<ApiService>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        globalService<AuthService>(),
        globalService<TokenStorage>(),
      ),
    )
    ..registerLazySingleton<ItemService>(
      () => ItemService(globalService<ApiService>()),
    )
    ..registerLazySingleton<ItemRepository>(ItemRepository.new)
    ..registerLazySingleton<StockGroupService>(
      () => StockGroupService(globalService<ApiService>()),
    )
    ..registerLazySingleton<StockGroupRepository>(
      () => StockGroupRepository(globalService<StockGroupService>()),
    )
    ..registerLazySingleton<StockCategoryService>(
      () => StockCategoryService(globalService<ApiService>()),
    )
    ..registerLazySingleton<StockCategoryRepository>(
      () => StockCategoryRepository(globalService<StockCategoryService>()),
    )
    ..registerLazySingleton<UnitService>(
      () => UnitService(globalService<ApiService>()),
    )
    ..registerLazySingleton<UnitRepository>(
      () => UnitRepository(globalService<UnitService>()),
    )
    ..registerLazySingleton<AccountNatureService>(
      () => AccountNatureService(globalService<ApiService>()),
    )
    ..registerLazySingleton<AccountNatureRepository>(
      () => AccountNatureRepository(globalService<AccountNatureService>()),
    )
    ..registerLazySingleton<AccountGroupService>(
      () => AccountGroupService(globalService<ApiService>()),
    )
    ..registerLazySingleton<AccountGroupRepository>(
      () => AccountGroupRepository(globalService<AccountGroupService>()),
    )
    ..registerLazySingleton<VoucherTypeService>(
      () => VoucherTypeService(globalService<ApiService>()),
    )
    ..registerLazySingleton<VoucherTypeRepository>(
      () => VoucherTypeRepository(globalService<VoucherTypeService>()),
    )
    ..registerLazySingleton<CountryService>(
      () => CountryService(globalService<ApiService>()),
    )
    ..registerLazySingleton<CountryRepository>(
      () => CountryRepository(globalService<CountryService>()),
    )
    ..registerLazySingleton<StateService>(
      () => StateService(globalService<ApiService>()),
    )
    ..registerLazySingleton<StateRepository>(
      () => StateRepository(globalService<StateService>()),
    )
    ..registerLazySingleton<FinancialYearService>(
      () => FinancialYearService(globalService<ApiService>()),
    )
    ..registerLazySingleton<FinancialYearRepository>(
      () => FinancialYearRepository(globalService<FinancialYearService>()),
    );

  // ViewModels are NOT registered here — they are created (and owned) by the
  // ChangeNotifierProviders in main.dart so their lifetime matches the widget
  // tree. Only shared, stateless-ish dependencies live in GetIt.
}
