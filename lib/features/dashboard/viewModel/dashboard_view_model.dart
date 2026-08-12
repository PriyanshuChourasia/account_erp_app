import 'package:flutter/foundation.dart';

import '../models/dashboard_stat.dart';

/// Holds all dashboard UI state.
///
/// Currently serves demo data so the screen demonstrates the full MVVM flow.
/// TODO: replace [loadStats] internals with a repository call — add a
/// `DashboardService` under `services/` and a `DashboardRepository` under
/// `repository/` (both folders exist for this purpose), then register them
/// in `network/service_locator.dart`.
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel();

  bool _isLoading = false;
  List<DashboardStat> _stats = const [];

  bool get isLoading => _isLoading;
  List<DashboardStat> get stats => _stats;

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    // Demo data — swap for `_stats = await _repository.fetchStats();`
    _stats = DashboardStat.demo;

    _isLoading = false;
    notifyListeners();
  }
}
