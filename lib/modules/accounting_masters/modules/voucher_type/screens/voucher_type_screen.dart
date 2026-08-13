import 'package:flutter/material.dart';

import '../state/voucher_type_screen_state.dart';

/// Screen for managing voucher types.
///
/// The heavy state logic lives in `state/voucher_type_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class VoucherTypeScreen extends StatefulWidget {
  const VoucherTypeScreen({super.key});

  @override
  State<VoucherTypeScreen> createState() => VoucherTypeScreenState();
}
