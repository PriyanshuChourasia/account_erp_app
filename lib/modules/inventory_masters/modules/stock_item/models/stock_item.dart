import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import 'stock_item_type.dart';
import 'type_of_supply.dart';

/// A stock item — an individual inventory product tracked under a stock
/// group, stock category and unit of measurement.
///
/// This is a lean scaffold: only the core identity and classification fields
/// are modelled for now (no GST/HSN, opening balances, godowns or batches
/// yet). Mirrors the backend `StockItemDTO` record. [demo] serves as
/// placeholder data until the backend is reachable.
class StockItem {
  const StockItem({
    required this.id,
    required this.name,
    this.code,
    this.alias,
    this.description,
    this.stockItemType,
    this.typeOfSupply,
    this.stockGroupId,
    this.stockCategoryId,
    this.unitId,
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
    this.isActive = true,
    this.icon = Icons.inventory_2_rounded,
    this.color = AppColors.primary,
  });

  final String id;
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
  final String? unitId;
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
  final bool isActive;
  final IconData icon;
  final Color color;

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    alias: json['alias'] as String?,
    description: json['description'] as String?,
    stockItemType: StockItemType.fromWire(json['stockItemType'] as String?),
    typeOfSupply: TypeOfSupply.fromWire(json['typeOfSupply'] as String?),
    stockGroupId: json['stockGroupId'] as String?,
    stockCategoryId: json['stockCategoryId'] as String?,
    unitId: json['unitId'] as String?,
    altUnitId: json['altUnitId'] as String?,
    gstRate: (json['gstRate'] as num?)?.toDouble(),
    purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
    sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
    openingQuantity: (json['openingQuantity'] as num?)?.toDouble(),
    openingValue: (json['openingValue'] as num?)?.toDouble(),
    currentQuantity: (json['currentQuantity'] as num?)?.toDouble(),
    reorderLevel: (json['reorderLevel'] as num?)?.toDouble(),
    minimumStock: (json['minimumStock'] as num?)?.toDouble(),
    maximumStock: (json['maximumStock'] as num?)?.toDouble(),
    barcode: json['barcode'] as String?,
    hsn: json['hsn'] as String?,
    sac: json['sac'] as String?,
    manufacturePartNo: json['manufacturePartNo'] as String?,
    articleNo: json['articleNo'] as String?,
    sku: json['sku'] as String?,
    brandId: (json['brandId'] as num?)?.toInt(),
    isActive: json['active'] == true,
  );

  static const List<StockItem> demo = [
    StockItem(
      id: '1',
      name: 'A4 Copier Paper',
      code: 'PAP-A4',
      description: '80 GSM, ream of 500 sheets',
      stockGroupId: '4',
      stockCategoryId: '4',
      unitId: '5',
      gstRate: 18,
      purchasePrice: 120,
      sellingPrice: 150,
      openingQuantity: 10,
      openingValue: 1200,
      currentQuantity: 10,
      reorderLevel: 2,
      minimumStock: 1,
      maximumStock: 50,
      icon: Icons.description_rounded,
      color: Color(0xFF1D4ED8),
    ),
    StockItem(
      id: '2',
      name: 'Wireless Mouse',
      alias: 'Mouse',
      code: 'ELEC-MS1',
      description: '2.4GHz wireless optical mouse',
      stockGroupId: '2',
      stockCategoryId: '1',
      unitId: '1',
      gstRate: 18,
      purchasePrice: 250,
      sellingPrice: 350,
      openingQuantity: 5,
      openingValue: 1250,
      currentQuantity: 5,
      reorderLevel: 1,
      minimumStock: 1,
      maximumStock: 20,
      icon: Icons.mouse_rounded,
      color: Color(0xFF059669),
    ),
    StockItem(
      id: '3',
      name: 'Steel Sheet 2mm',
      code: 'RAW-SS2',
      description: 'Cold-rolled steel sheet, 2mm thickness',
      stockGroupId: '3',
      unitId: '3',
      gstRate: 18,
      purchasePrice: 900,
      sellingPrice: 1200,
      openingQuantity: 2,
      openingValue: 1800,
      currentQuantity: 2,
      reorderLevel: 1,
      minimumStock: 1,
      maximumStock: 10,
      icon: Icons.square_foot_rounded,
      color: Color(0xFFD97706),
    ),
    StockItem(
      id: '4',
      name: 'Office Chair',
      code: 'FURN-CH1',
      description: 'Ergonomic office chair',
      stockGroupId: '4',
      stockCategoryId: '2',
      unitId: '1',
      isActive: false,
      gstRate: 18,
      purchasePrice: 1800,
      sellingPrice: 2400,
      openingQuantity: 1,
      openingValue: 1800,
      currentQuantity: 0,
      reorderLevel: 1,
      minimumStock: 1,
      maximumStock: 5,
      icon: Icons.chair_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];
}
