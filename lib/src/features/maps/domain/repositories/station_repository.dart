import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';

abstract class StationRepository {
  Future<List<ModelStation>> findAllStations(Map<String, dynamic> query);
  Future<List<ModelCharger>> findAllChargers(Map<String, dynamic> query);
  Future<ModelStation> createStation(Map<String, dynamic> stationData);
  Future<int> createCharger(Map<String, dynamic> chargerData);
}
