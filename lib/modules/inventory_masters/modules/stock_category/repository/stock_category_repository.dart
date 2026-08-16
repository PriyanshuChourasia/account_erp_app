import 'package:account_erp_app/modules/inventory_masters/modules/stock_category/models/stock_category_hierarchy.dart';

import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_stock_category_request.dart';
import '../models/stock_category.dart';
import '../services/stock_category_service.dart';

/// Orchestrates stock category data: calls [StockCategoryService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class StockCategoryRepository {
  StockCategoryRepository(this._stockCategoryService);

  final StockCategoryService _stockCategoryService;

  Future<List<StockCategory>> fetchStockCategories() async {
    final json = await _stockCategoryService.fetchStockCategories();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load stock categories.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(StockCategory.fromJson)
        .toList();
  }

  Future<List<StockCategoryHierarchy>> fetchStockCategoryHierarchy() async {
    final json = await _stockCategoryService.fetchStockCategoryHierarchy();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? "Could not load stock hierarchy",
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(StockCategoryHierarchy.fromJson)
        .toList();
  }

  Future<void> createStockCategory(CreateStockCategoryRequest request) async {
    final json = await _stockCategoryService.createStockCategory(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create stock category.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteStockCategory(int id) async {
    final json = await _stockCategoryService.deleteStockCategory(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete stock category.',
        code: wrapper.code,
      );
    }
  }
}
