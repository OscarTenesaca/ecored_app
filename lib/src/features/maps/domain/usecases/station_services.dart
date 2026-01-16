import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/domain/repositories/station_repository.dart';

class StationServices {
  final StationRepository repository;

  StationServices(this.repository);

  Future<List<ModelStation>> findAllStations(Map<String, dynamic> query) {
    return repository.findAllStations(query);
  }

  Future<List<ModelCharger>> findAllChargers(Map<String, dynamic> query) {
    return repository.findAllChargers(query);
  }

  Future<ModelStation> createStation(Map<String, dynamic> stationData) {
    return repository.createStation(stationData);
  }

  Future<int> createCharger(Map<String, dynamic> chargerData) {
    return repository.createCharger(chargerData);
  }
}
