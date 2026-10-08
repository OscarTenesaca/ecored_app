import 'package:ecored_app/src/features/maps/data/datasources/stations_remote_data_source.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_connector_type.dart';
import 'package:ecored_app/src/features/maps/data/model/model_station_preview.dart';
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
  Future<ModelStation> createStationWithChargers(
    Map<String, dynamic> stationData,
  ) {
    return remoteDataSource.createStationWithChargers(stationData);
  }

  @override
  Future<List<ModelConnectorType>> findConnectorTypes() {
    return remoteDataSource.findConnectorTypes();
  }

  @override
  Future<ModelStationPreview> getStationPreview(String stationId) {
    return remoteDataSource.getStationPreview(stationId);
  }
}
