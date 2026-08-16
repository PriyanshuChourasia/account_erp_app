import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/stock_item.dart';
import '../services/stock_item_service.dart';

/// Orchestrates stock item data: calls [StockItemService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class StockItemRepository {
  StockItemRepository(this._stockItemService);

  final StockItemService _stockItemService;

  Future<List<StockItem>> fetchStockItems() async {
    final json = await _stockItemService.fetchStockItems();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load stock items.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(StockItem.fromJson)
        .toList();
  }

  Future<void> createStockItem({
    required String name,
    String? alias,
    String? code,
    String? description,
    int? stockGroupId,
    int? stockCategoryId,
    int? unitId,
  }) async {
    final json = await _stockItemService.createStockItem({
      'name': name,
      'alias': ?alias,
      'code': ?code,
      'description': ?description,
      'stockGroupId': ?stockGroupId,
      'stockCategoryId': ?stockCategoryId,
      'unitId': ?unitId,
    });
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create stock item.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteStockItem(int id) async {
    final json = await _stockItemService.deleteStockItem(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete stock item.',
        code: wrapper.code,
      );
    }
  }
}
