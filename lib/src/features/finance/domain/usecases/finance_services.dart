import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:ecored_app/src/features/finance/domain/repositories/finance_repository.dart';

class FinanceServices {
  final FinanceRepository repository;

  FinanceServices(this.repository);

  Future<ModelFinance> getWalletData(Map<String, dynamic> params) async {
    return await repository.getWalletData(params);
  }

  Future<List<ModelTransaction>> getTransactionData(
    Map<String, dynamic> params,
  ) async {
    return await repository.getTransactionData(params);
  }

  Future<ModelOrder> getOrderData(Map<String, dynamic> params) {
    return repository.getOrderData(params);
  }

  Future<ModelRecharge> getRechargeData(Map<String, dynamic> params) {
    return repository.getRechargeData(params);
  }
}
