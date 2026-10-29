import 'stock_item_type.dart';
import 'type_of_supply.dart';

/// Request payload for creating a stock item.
///
/// Mirrors the backend `CreateStockItemDTO` record. Nullable fields are
/// omitted from JSON so unset optional fields are not sent; `name` and `unitId`
/// are the required identifiers.
class CreateStockItemRequest {
  const CreateStockItemRequest({
    required this.name,
    this.code,
    this.alias,
    this.description,
    this.stockItemType,
    this.typeOfSupply,
    this.stockGroupId,
    this.stockCategoryId,
    required this.unitId,
    this.altUnitId,
    this.gstRate,
    this.purchasePrice,
    this.sellingPrice,
    this.openingQuantity,
    this.openingValue,
    this.currentQuantity,
    this.reorderLevel,
    this.minimumStock,
    this.maximumStock,
    this.barcode,
    this.hsn,
    this.sac,
    this.manufacturePartNo,
    this.articleNo,
    this.sku,
    this.brandId,
    this.active = true,
  });

  final String name;
  final String? code;
  final String? alias;
  final String? description;

  /// Whether the item is a tangible [StockItemType.goods] or a service.
  final StockItemType? stockItemType;

  /// The kind of supply this item represents.
  final TypeOfSupply? typeOfSupply;
  final String? stockGroupId;
  final String? stockCategoryId;

  /// The unit of measurement this item is quantified in (UUID).
  final String unitId;

  /// Alternate unit of measurement for compound stock items (UUID).
  final String? altUnitId;

  final double? gstRate;
  final double? purchasePrice;
  final double? sellingPrice;
  final double? openingQuantity;
  final double? openingValue;
  final double? currentQuantity;
  final double? reorderLevel;
  final double? minimumStock;
  final double? maximumStock;

  final String? barcode;
  final String? hsn;
  final String? sac;
  final String? manufacturePartNo;
  final String? articleNo;
  final String? sku;

  final int? brandId;

  /// Whether the stock item is active.
  final bool active;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (code != null) 'code': code,
    if (alias != null) 'alias': alias,
    if (description != null) 'description': description,
    if (stockItemType != null) 'stockItemType': stockItemType?.wireValue,
    if (typeOfSupply != null) 'typeOfSupply': typeOfSupply?.wireValue,
    if (stockGroupId != null) 'stockGroupId': stockGroupId,
    if (stockCategoryId != null) 'stockCategoryId': stockCategoryId,
    'unitId': unitId,
    if (altUnitId != null) 'altUnitId': altUnitId,
    if (gstRate != null) 'gstRate': gstRate,
    if (purchasePrice != null) 'purchasePrice': purchasePrice,
    if (sellingPrice != null) 'sellingPrice': sellingPrice,
    if (openingQuantity != null) 'openingQuantity': openingQuantity,
    if (openingValue != null) 'openingValue': openingValue,
    if (currentQuantity != null) 'currentQuantity': currentQuantity,
    if (reorderLevel != null) 'reorderLevel': reorderLevel,
    if (minimumStock != null) 'minimumStock': minimumStock,
    if (maximumStock != null) 'maximumStock': maximumStock,
    if (barcode != null) 'barcode': barcode,
    if (hsn != null) 'hsn': hsn,
    if (sac != null) 'sac': sac,
    if (manufacturePartNo != null) 'manufacturePartNo': manufacturePartNo,
    if (articleNo != null) 'articleNo': articleNo,
    if (sku != null) 'sku': sku,
    if (brandId != null) 'brandId': brandId,
    if (active) 'active': active,
  };
}
