import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/features/finance/data/models/model_finance.dart';

abstract class FinanceRemoteDataSource {
  Future<ModelFinance> getWalletData(Map<String, dynamic> params);
  // Future<void> updateFinanceData(String userId, ModelFinance data);
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final String url;
  final HttpAdapter httpAdapter = HttpAdapter();

  FinanceRemoteDataSourceImpl(this.url) {}

  @override
  Future<ModelFinance> getWalletData(Map<String, dynamic> params) async {
    final String endpoint = '$url/api/v1/wallets';
    final response = await httpAdapter.get(endpoint, queryParams: params);

    if (response.statusCode != 200) {
      throw ('Ocurrió un problema, intente más tarde');
    }

    final respModelFinance = ModelFinance.fromJson(response.data['data'][0]);
    return respModelFinance;
  }
}
