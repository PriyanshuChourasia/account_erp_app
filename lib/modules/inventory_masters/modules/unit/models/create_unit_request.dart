import 'stock_unit_type.dart';

/// Request payload for creating a unit.
///
/// Mirrors the backend `CreateUnitRequestDTO` record. Nullable fields are
/// omitted from JSON so the backend's `@NotBlank` validation only applies to
/// `name`.
class CreateUnitRequest {
  const CreateUnitRequest({
    required this.name,
    this.alias,
    this.description,
    this.code,
    this.unitType,
    this.uqcId,
    this.primaryUnitId,
    this.secondaryUnitId,
    this.conversionFactor,
    this.decimalPlaces,
  });

  final String name;
  final String? alias;
  final String? description;
  final String? code;

  /// Whether the unit is [StockUnitType.simple] or [StockUnitType.compound].
  final StockUnitType? unitType;

  /// UQC (Unit Quantity Code) this unit maps to, e.g. `NOS`, `KGS`.
  final int? uqcId;
  final int? primaryUnitId;
  final int? secondaryUnitId;

  /// Factor used when converting to/from the base unit(s).
  final double? conversionFactor;
  final int? decimalPlaces;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (alias != null) 'alias': alias,
    if (description != null) 'description': description,
    if (code != null) 'code': code,
    if (unitType != null) 'unitType': unitType?.wireValue,
    if (uqcId != null) 'uqcId': uqcId,
    if (primaryUnitId != null) 'primaryUnitId': primaryUnitId,
    if (secondaryUnitId != null) 'secondaryUnitId': secondaryUnitId,
    if (conversionFactor != null) 'conversionFactor': conversionFactor,
    if (decimalPlaces != null) 'decimalPlaces': decimalPlaces,
  };
}
