import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';

abstract class StationRepository {
  Future<List<ModelStation>> findAllStations(Map<String, dynamic> query);
}
