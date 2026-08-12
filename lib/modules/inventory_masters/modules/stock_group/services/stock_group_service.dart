import '../../../../../config/api_config.dart';
import '../../../../../network/api_service.dart';

/// Raw HTTP calls for stock groups. No parsing, no state.
class StockGroupService {
  StockGroupService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchStockGroups() =>
      _apiService.get(ApiConfig.stockGroupsEndpoint);

  Future<Map<String, dynamic>> createStockGroup(Map<String, dynamic> data) =>
      _apiService.post(ApiConfig.stockGroupCreateEndpoint, data: data);

  Future<Map<String, dynamic>> deleteStockGroup(int id) =>
      _apiService.delete(ApiConfig.stockGroupEndpoint(id));
}
