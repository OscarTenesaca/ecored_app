import 'dart:developer';

import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';

abstract class StationsRemoteDataSource {
  Future<List<ModelStation>> findAllStations(Map<String, dynamic> query);
  Future<List<ModelCharger>> findAllChargers(Map<String, dynamic> query);
  // Future<ModelCharger
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
      final responseStation = response.data['data'];

      List<ModelStation> stations =
          (responseStation as List)
              .map((stationJson) => ModelStation.fromJson(stationJson))
              .toList();

      return stations;
    } else {
      log('Error fetching stations: ${response.statusCode}');
      return [];
    }
  }

  @override
  Future<List<ModelCharger>> findAllChargers(Map<String, dynamic> query) async {
    final String endpoint = '$url/api/v1/charger';

    final response = await httpAdapter.get(endpoint, queryParams: query);

    if (response.statusCode == 200) {
      final responseChargers = response.data['data'];

      List<ModelCharger> chargers =
          (responseChargers as List)
              .map((chargerJson) => ModelCharger.fromJson(chargerJson))
              .toList();

      return chargers;
    } else {
      log('Error fetching chargers: ${response}');
      return [];
    }
  }
}
