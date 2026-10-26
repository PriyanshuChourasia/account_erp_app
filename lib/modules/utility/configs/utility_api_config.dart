/// API endpoints for the utility modules (banks, bank types, bank branches).
class UtilityApiConfig {
  UtilityApiConfig._();

  /// bank types
  static const String bankTypeAPI = "/bank_types";
  static const String createBankTypeAPI = "$bankTypeAPI/create";
  static String bankTypeEndpoint(int id) => "$bankTypeAPI/$id";

  /// banks
  static const String bankAPI = "/banks";
  static const String createBankAPI = "$bankAPI/create";
  static String bankEndpoint(int id) => "$bankAPI/$id";

  /// bank branches
  static const String bankBranchAPI = "/bank_branches";
  static const String createBankBranchAPI = "$bankBranchAPI/create";
  static String bankBranchEndpoint(int id) => "$bankBranchAPI/$id";

  /// blood groups
  static const String bloodGroupAPI = "/blood_groups";
  static const String createBloodGroupAPI = "$bloodGroupAPI/create";
  static String bloodGroupEndpoint(int id) => "$bloodGroupAPI/$id";

  /// genders
  static const String genderAPI = "/genders";
  static const String genderListAPI = "$genderAPI/list";
  static const String createGenderAPI = "$genderAPI/create";
  static String genderEndpoint(String id) => "$genderAPI/$id";
}