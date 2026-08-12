/// Cross-cutting formatting helpers shared across features.
class Formatters {
  Formatters._();

  /// Formats a number with thousands separators, e.g. 1284 → "1,284".
  static String formatNumber(num value) {
    final digits = value.abs().toStringAsFixed(0);
    final withSeparators = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '${value < 0 ? '-' : ''}$withSeparators';
  }

  /// Formats a decimal amount with two digits, e.g. 45.5 → "45.50".
  static String formatAmount(num value) => value.toStringAsFixed(2);
}
