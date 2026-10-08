import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_connector_type.dart';
import 'package:ecored_app/src/features/maps/data/model/model_station_preview.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';

abstract class StationRepository {
  Future<List<ModelStation>> findAllStations(Map<String, dynamic> query);
  Future<List<ModelCharger>> findAllChargers(Map<String, dynamic> query);
  Future<ModelStation> createStationWithChargers(
    Map<String, dynamic> stationData,
  );
  Future<List<ModelConnectorType>> findConnectorTypes();
  Future<ModelStationPreview> getStationPreview(String stationId);
}
