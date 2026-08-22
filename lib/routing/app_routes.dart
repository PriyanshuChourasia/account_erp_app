/// Central registry of named routes.
///
/// Never hardcode route strings — always reference these constants.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String splash = '/splash';
  static const String items = '/items';
  static const String invoices = '/invoices';
  static const String payments = '/payments';
  static const String customers = '/customers';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String accountingMasters = '/accounting-masters';
  static const String inventoryMasters = '/inventory-masters';
  static const String organisationalMasters = '/organisational-masters';
  static const String companies = '/companies';
  static const String createCompany = '/companies/create';
  static const String utilities = '/utilities';
  static const String help = '/help';
  static const String support = '/support';
  static const String profile = '/profile';
  static const String gatewayOfAccounts = '/gateway-of-accounts';
}
