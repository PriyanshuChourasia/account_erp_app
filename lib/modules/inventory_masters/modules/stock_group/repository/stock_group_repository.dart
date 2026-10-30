import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/stock_group.dart';
import '../services/stock_group_service.dart';

/// Orchestrates stock group data: calls [StockGroupService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class StockGroupRepository {
  StockGroupRepository(this._stockGroupService);

  final StockGroupService _stockGroupService;

  Future<List<StockGroup>> fetchStockGroups() async {
    final json = await _stockGroupService.fetchStockGroups();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load stock groups.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(StockGroup.fromJson)
        .toList();
  }

  Future<void> createStockGroup({
    required String name,
    String? alias,
    String? parentId,
    String? description,
    bool shouldAddQuantities = false,
    bool setAlterGstDetails = false,
  }) async {
    final json = await _stockGroupService.createStockGroup({
      'name': name,
      'alias': ?alias,
      'description': ?description,
      'parentId': ?parentId,
      'shouldAddQuantities': shouldAddQuantities,
      'setAlterGstDetails': setAlterGstDetails,
    });
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create stock group.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteStockGroup(String id) async {
    final json = await _stockGroupService.deleteStockGroup(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete stock group.',
        code: wrapper.code,
      );
    }
  }
}
