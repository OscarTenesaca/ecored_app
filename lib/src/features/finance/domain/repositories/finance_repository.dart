import 'package:ecored_app/src/features/finance/data/models/model_index.dart';

abstract class FinanceRepository {
  Future<ModelFinance> getWalletData(Map<String, dynamic> params);
  Future<List<ModelTransaction>> getTransactionData(
    Map<String, dynamic> params,
  );
  Future<ModelOrder> getOrderData(Map<String, dynamic> params);
  Future<ModelRecharge> getRechargeData(Map<String, dynamic> params);
}
