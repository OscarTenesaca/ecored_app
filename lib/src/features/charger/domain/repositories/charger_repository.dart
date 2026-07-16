import 'package:ecored_app/src/features/finance/data/models/model_index.dart';

abstract class ChargerRepository {
  Future<ModelOrder?> getOrderData(Map<String, dynamic> params);
  Future<int> deleteStopChargerData(Map<String, dynamic> body);
}
