/// API endpoints for the organisational masters module.
class OrganisationalApiConfig {
  /// countries
  static const String countryAPI = "/countries/list";
  static const String createCountryAPI = "$countryAPI/create";
  static String countryEndpoint(String id) => "$countryAPI/$id";

  /// states
  static const String stateAPI = "/states";
  static const String createStateAPI = "$stateAPI/create";
  static String stateEndpoint(String id) => "$stateAPI/$id";

  /// addresses
  static const String addressAPI = "/addresses";
  static const String createAddressAPI = "$addressAPI/create";
  static String addressEndpoint(String id) => "$addressAPI/$id";

  /// financial years
  static const String financialYearAPI = "/financial-years";
  static const String createFinancialYearAPI = "$financialYearAPI/create";

  /// organisation's current fiscal year.
  static const String updateFinancialYearCurrentAPI =
      "$financialYearAPI/current";

  /// companies
  static const String companyAPI = "/companies/list";
  static const String createCompanyAPI = "$companyAPI/create";
  static String companyEndpoint(int id) => "$companyAPI/$id";
}
