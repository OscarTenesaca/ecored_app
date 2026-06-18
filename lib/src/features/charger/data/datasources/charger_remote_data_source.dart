import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';

abstract class ChargerRemoteDataSource {
  Future<ModelOrder> getOrderData(Map<String, dynamic> params);
  Future<int> deleteStopCharger(Map<String, dynamic> body);
}

class ChargerRemoteDataSourceImpl implements ChargerRemoteDataSource {
  final String url;
  final HttpAdapter httpAdapter = HttpAdapter();

  ChargerRemoteDataSourceImpl(this.url) {}

  @override
  Future<ModelOrder> getOrderData(Map<String, dynamic> params) async {
    final String endpoint = '$url/api/v1/orders/find/one';
    final response = await httpAdapter.get(endpoint, queryParams: params);
    if (response.statusCode != 200) {
      throw ('Ocurrió un problema, intente más tarde');
    }
    final respModelOrder = ModelOrder.fromJson(response.data['data']);
    return respModelOrder;
  }

  @override
  Future<int> deleteStopCharger(Map<String, dynamic> body) async {
    final String endpoint = '$url/api/v1/orders/stop';

    try {
      final response = await httpAdapter.delete(endpoint, queryParams: body);
      return response.statusCode ?? -1;
    } catch (e) {
      return -1;
    }
  }
}
