
class InventoryApiConfig {
  InventoryApiConfig._();
  /// stock group api
  static const String stockGroupAPI = "/stock_groups";
  static const String createStockGroupAPI = "$stockGroupAPI/create";

  /// units api
  static const String createUnitAPI = "/units/create";

  /// stock category api
  static const String stockCategoryAPI = "/stock_categories";
  static const String stockCategoryListAPI = "$stockCategoryAPI/list";
  static const String createStockCategoryAPI = "$stockCategoryAPI/create";
  static const String stockCategoryTreeAPI = "$stockCategoryAPI/all-category-tree";
}