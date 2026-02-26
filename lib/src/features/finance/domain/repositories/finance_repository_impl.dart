import 'package:ecored_app/src/core/models/nuvei_model.dart';
import 'package:ecored_app/src/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';

import 'package:ecored_app/src/features/finance/domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  FinanceRepositoryImpl(this.remoteDataSource);

  @override
  Future<ModelFinance> getWalletData(Map<String, dynamic> params) async {
    return await remoteDataSource.getWalletData(params);
  }

  @override
  Future<List<ModelTransaction>> getTransactionData(
    Map<String, dynamic> params,
  ) async {
    return await remoteDataSource.getTransactionData(params);
  }

  @override
  Future<ModelOrder> getOrderData(Map<String, dynamic> params) {
    return remoteDataSource.getOrderData(params);
  }

  @override
  Future<ModelRecharge> getRechargeData(Map<String, dynamic> params) {
    return remoteDataSource.getRechargeData(params);
  }

  @override
  Future<Map> postNuveiData(ModelNuvei body) {
    return remoteDataSource.postNuveiData(body);
  }

  @override
  Future<int> postRecharge(Map<String, dynamic> body) {
    return remoteDataSource.postRecharge(body);
  }

  @override
  Future<int> postOrder(Map<String, dynamic> body) {
    return remoteDataSource.postOrder(body);
  }

  @override
  Future<int> postOrderPayment(Map<String, dynamic> body) {
    return remoteDataSource.postOrderPayment(body);
  }
}
