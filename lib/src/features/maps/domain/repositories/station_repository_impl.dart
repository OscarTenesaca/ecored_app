import 'package:ecored_app/src/features/maps/data/datasources/stations_remote_data_source.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/domain/repositories/station_repository.dart';

class StationRepositoryImpl implements StationRepository {
  final StationsRemoteDataSource remoteDataSource;

  StationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ModelStation>> findAllStations(Map<String, dynamic> query) {
    return remoteDataSource.findAllStations(query);
  }

  @override
  Future<List<ModelCharger>> findAllChargers(Map<String, dynamic> query) {
    return remoteDataSource.findAllChargers(query);
  }

  @override
  Future<int> createStation(Map<String, dynamic> stationData) {
    return remoteDataSource.createStation(stationData);
  }

  @override
  Future<int> createCharger(Map<String, dynamic> chargerData) {
    return remoteDataSource.createCharger(chargerData);
  }
}
