/// Mirrors the backend `TypeOfSupplyEnum` record.
///
/// The kind of supply an item is classified as, e.g. taxed goods, exempt
/// services or capital goods.
enum TypeOfSupply {
  goods('goods'),
  services('services'),
  capitalGoods('capital_goods');

  const TypeOfSupply(this.wireValue);

  /// Serialized value used on the wire, e.g. `goods`.
  final String wireValue;

  static TypeOfSupply? fromWire(String? value) {
    for (final type in TypeOfSupply.values) {
      if (type.wireValue == value) return type;
    }
    return null;
  }
}
