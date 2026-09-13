/// API endpoints for the developer masters module.
class DeveloperApiConfig {
  /// application modules
  static const String applicationModuleAPI = "/application_modules";
  static const String createApplicationModuleAPI =
      "$applicationModuleAPI/create";
  static String applicationModuleEndpoint(String id) =>
      "$applicationModuleAPI/$id";

  /// application features
  static const String applicationFeatureAPI = "/application_features";
  static const String createApplicationFeatureAPI =
      "$applicationFeatureAPI/create";
  static String applicationFeatureEndpoint(String id) =>
      "$applicationFeatureAPI/$id";
}
