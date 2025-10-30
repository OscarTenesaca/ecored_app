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
}
