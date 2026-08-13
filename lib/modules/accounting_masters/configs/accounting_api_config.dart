/// API endpoints for the accounting masters module.
class AccountingApiConfig {
  /// account groups
  static const String accountGroupAPI = "/account_groups";
  static const String createAccountGroupAPI = "$accountGroupAPI/create";
  static String accountGroupEndpoint(int id) => "$accountGroupAPI/$id";

  /// account natures
  static const String accountNatureAPI = "/account_natures";
  static const String createAccountNatureAPI = "$accountNatureAPI/create";
  static String accountNatureEndpoint(int id) => "$accountNatureAPI/$id";

  /// account ledgers
  static const String accountLedgerAPI = "/account_ledgers";
  static const String createAccountLedgerAPI = "$accountLedgerAPI/create";
  static String accountLedgerEndpoint(int id) => "$accountLedgerAPI/$id";

  /// voucher types
  static const String voucherTypeAPI = "/voucher_types";
  static const String createVoucherTypeAPI = "$voucherTypeAPI/create";
  static String voucherTypeEndpoint(int id) => "$voucherTypeAPI/$id";
}
