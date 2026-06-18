import 'package:ecored_app/src/features/charger/domain/repositories/charger_repository.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';

class ChargerServices {
  final ChargerRepository repository;

  ChargerServices(this.repository);

  Future<ModelOrder> getOrderData(Map<String, dynamic> params) {
    return repository.getOrderData(params);
  }

  Future<int> deleteStopCharger(Map<String, dynamic> body) {
    return repository.deleteStopChargerData(body);
  }
}
