import 'stock_unit_type.dart';

/// Request payload for creating a stock unit.
///
/// Mirrors the backend `CreateStockUnitRequestDTO` record. Nullable fields are
/// omitted from JSON so the backend's `@NotBlank` validation only applies to
/// `name`.
class CreateStockUnitRequest {
  const CreateStockUnitRequest({
    required this.name,
    this.symbol,
    this.alias,
    this.unitType,
    this.uqcId,
    this.primaryUnitId,
    this.secondaryUnitId,
    this.conversionFactor,
    this.decimalPlaces,
    this.active,
  });

  final String name;
  final String? symbol;
  final String? alias;

  /// Whether the unit is [StockUnitType.simple] or [StockUnitType.compound].
  final StockUnitType? unitType;

  /// UQC (Unit Quantity Code) this unit maps to, e.g. `NOS`, `KGS`.
  final String? uqcId;
  final String? primaryUnitId;
  final String? secondaryUnitId;

  /// Factor used when converting to/from the base unit(s).
  final double? conversionFactor;

  /// Number of decimal places the unit supports (0–4).
  final int? decimalPlaces;

  /// Whether the unit is active.
  final bool? active;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (symbol != null) 'symbol': symbol,
    if (alias != null) 'alias': alias,
    if (unitType != null) 'unitType': unitType?.wireValue,
    if (uqcId != null) 'uqcId': uqcId,
    if (primaryUnitId != null) 'primaryUnitId': primaryUnitId,
    if (secondaryUnitId != null) 'secondaryUnitId': secondaryUnitId,
    if (conversionFactor != null) 'conversionFactor': conversionFactor,
    if (decimalPlaces != null) 'decimalPlaces': decimalPlaces,
    if (active != null) 'active': active,
  };
}
