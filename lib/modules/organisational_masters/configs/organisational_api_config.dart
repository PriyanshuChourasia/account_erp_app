/// API endpoints for the organisational masters module.
class OrganisationalApiConfig {
  /// countries
  static const String countryAPI = "/countries/list";
  static const String createCountryAPI = "$countryAPI/create";
  static String countryEndpoint(int id) => "$countryAPI/$id";

  /// states
  static const String stateAPI = "/states";
  static const String createStateAPI = "$stateAPI/create";
  static String stateEndpoint(int id) => "$stateAPI/$id";

  /// financial years
  static const String financialYearAPI = "/financial-years";
  static const String createFinancialYearAPI = "$financialYearAPI/create";

  /// organisation's current fiscal year.
  static const String updateFinancialYearCurrentAPI =
      "$financialYearAPI/current";
}
