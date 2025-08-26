import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';

abstract class StationsRemoteDataSource {
  Future<List<ModelStation>> findAllStations(Map<String, dynamic> query);
}

class StationsRemoteDataSourceImpl implements StationsRemoteDataSource {
  final String url;
  final HttpAdapter httpAdapter = HttpAdapter();

  StationsRemoteDataSourceImpl(this.url) {}

  @override
  Future<List<ModelStation>> findAllStations(Map<String, dynamic> query) async {
    final String endpoint = '$url/api/v1/station';

    final response = await httpAdapter.get(endpoint, queryParams: query);
    if (response.statusCode == 200) {
      final List<ModelStation> stations =
          (response.data['data'] as List)
              .map((stationJson) => ModelStation.fromJson(stationJson))
              .toList();
      return stations;
    } else {
      return [];
    }
  }
}
