import 'package:ecored_app/src/features/charger/data/datasources/charger_remote_data_source.dart';
import 'package:ecored_app/src/features/charger/domain/repositories/charger_repository.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';

class ChargerRepositoryImpl implements ChargerRepository {
  final ChargerRemoteDataSource remoteDataSource;

  ChargerRepositoryImpl(this.remoteDataSource);

  @override
  Future<ModelOrder?> getOrderData(Map<String, dynamic> params) {
    return remoteDataSource.getOrderData(params);
  }

  @override
  Future<int> deleteStopChargerData(Map<String, dynamic> body) {
    return remoteDataSource.deleteStopCharger(body);
  }
}
