class InventoryApiConfig {
  InventoryApiConfig._();

  /// stock group api
  static const String stockGroupAPI = "/stock_groups";
  static const String createStockGroupAPI = "$stockGroupAPI/create";

  /// units api
  static const String unitAPI = "/units";
  static const String unitListAPI = "$unitAPI/list";
  static const String createUnitAPI = "$unitAPI/create";
  static String unitEndpoint(String id) => "$unitAPI/$id";

  /// stock items api
  static const String stockItemAPI = "/stock_items";
  static const String createStockItemAPI = "$stockItemAPI/create";
  static String stockItemEndpoint(String id) => "$stockItemAPI/$id";

  /// stock category api
  static const String stockCategoryAPI = "/stock_categories";
  static const String stockCategoryListAPI = "$stockCategoryAPI/list";
  static const String createStockCategoryAPI = "$stockCategoryAPI/create";
  static const String stockCategoryTreeAPI =
      "$stockCategoryAPI/all-category-tree";

  /// unique Quantity Code
  static const String uniqueQuantityCodeAPI = "/unique_quantity_codes";
  static const String createUniqueQuantityCodeAPI =
      "$uniqueQuantityCodeAPI/create";
  static String uniqueQuantityCodeEndpoint(String id) =>
      "$uniqueQuantityCodeAPI/$id";
}
