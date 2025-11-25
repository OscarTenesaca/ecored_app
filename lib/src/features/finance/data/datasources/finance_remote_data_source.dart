import 'dart:developer';

import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';

abstract class FinanceRemoteDataSource {
  Future<ModelFinance> getWalletData(Map<String, dynamic> params);
  Future<List<ModelTransaction>> getTransactionData(
    Map<String, dynamic> params,
  );
  Future<ModelOrder> getOrderData(Map<String, dynamic> params);
  Future<ModelRecharge> getRechargeData(Map<String, dynamic> params);
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

  @override
  Future<List<ModelTransaction>> getTransactionData(
    Map<String, dynamic> params,
  ) async {
    final String endpoint = '$url/api/v1/transaction';
    final response = await httpAdapter.get(endpoint, queryParams: params);
    if (response.statusCode == 200) {
      final respTransactions = response.data['data'];

      List<ModelTransaction> transaction =
          (respTransactions as List)
              .map((item) => ModelTransaction.fromJson(item))
              .toList();

      return transaction;
    } else {
      log('Error fetching transactions: ${response.statusCode}');
      return [];
    }
  }

  @override
  Future<ModelOrder> getOrderData(Map<String, dynamic> params) async {
    final String endpoint = '$url/api/v1/orders/${params['id']}';
    final response = await httpAdapter.get(endpoint);

    if (response.statusCode != 200) {
      throw ('Ocurrió un problema, intente más tarde');
    }
    final respModelOrder = ModelOrder.fromJson(response.data['data']);

    return respModelOrder;
  }

  @override
  Future<ModelRecharge> getRechargeData(Map<String, dynamic> params) async {
    final String endpoint = '$url/api/v1/recharges/${params['id']}';
    final response = await httpAdapter.get(endpoint);

    if (response.statusCode != 200) {
      throw ('Ocurrió un problema, intente más tarde');
    }

    print('Recharge Response Data: ${response.data}');
    final respModelRecharge = ModelRecharge.fromJson(response.data['data']);
    print(respModelRecharge.toJson());
    return respModelRecharge;
  }
}
