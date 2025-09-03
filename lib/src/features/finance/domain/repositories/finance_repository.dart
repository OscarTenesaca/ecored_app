import 'package:ecored_app/src/features/finance/data/models/model_finance.dart';

abstract class FinanceRepository {
  Future<ModelFinance> getWalletData(Map<String, dynamic> params);
  // Future<void> updateFinanceData(String userId, ModelFinance data);
}
