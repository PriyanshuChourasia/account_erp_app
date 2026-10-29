/// Mirrors the backend `StockItemTypeEnum` record.
///
/// A stock item is either a `goods` entry (a tangible product) or a `service`
/// (a non-tangible offering).
enum StockItemType {
  goods('goods'),
  service('service');

  const StockItemType(this.wireValue);

  /// Serialized value used on the wire, e.g. `goods`.
  final String wireValue;

  static StockItemType? fromWire(String? value) {
    for (final type in StockItemType.values) {
      if (type.wireValue == value) return type;
    }
    return null;
  }
}
