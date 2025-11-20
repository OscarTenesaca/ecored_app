import 'package:ecored_app/src/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:ecored_app/src/features/finance/data/models/model_finance.dart';
import 'package:ecored_app/src/features/finance/data/models/model_transaction.dart';
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
}
