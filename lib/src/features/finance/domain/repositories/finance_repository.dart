import 'package:ecored_app/src/features/finance/data/models/model_finance.dart';
import 'package:ecored_app/src/features/finance/data/models/model_transaction.dart';

abstract class FinanceRepository {
  Future<ModelFinance> getWalletData(Map<String, dynamic> params);
  Future<List<ModelTransaction>> getTransactionData(
    Map<String, dynamic> params,
  );
}
