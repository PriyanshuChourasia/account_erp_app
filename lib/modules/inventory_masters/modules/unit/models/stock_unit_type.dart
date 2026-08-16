/// Mirrors the backend `StockUnitTypeEnum` record.
///
/// A simple unit measures an item directly (e.g. `Piece`); a compound unit
/// is expressed in terms of base unit(s) with a conversion factor.
enum StockUnitType {
  simple('simple'),
  compound('compound');

  const StockUnitType(this.wireValue);

  /// Serialized value used on the wire, e.g. `simple`.
  final String wireValue;

  static StockUnitType? fromWire(String? value) {
    for (final type in StockUnitType.values) {
      if (type.wireValue == value) return type;
    }
    return null;
  }
}
