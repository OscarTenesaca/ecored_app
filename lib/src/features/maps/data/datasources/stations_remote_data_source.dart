import 'dart:developer';

import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/core/utils/utils_logger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:flutter/foundation.dart';

abstract class StationsRemoteDataSource {
  Future<List<ModelStation>> findAllStations(Map<String, dynamic> query);
  Future<List<ModelCharger>> findAllChargers(Map<String, dynamic> query);
  Future<ModelCharger> findOneCharger(Map<String, dynamic> query);
  Future<ModelStation> createStation(Map<String, dynamic> stationData);
  Future<int> createCharger(Map<String, dynamic> chargerData);
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

      print('**(**** ): ${responseStation}');

      List<ModelStation> stations =
          (responseStation as List)
              .map((stationJson) => ModelStation.fromJson(stationJson))
              .toList();

      debugPrint('******** stations: ${stations.length}');
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

  @override
  Future<ModelStation> createStation(Map<String, dynamic> stationData) async {
    final String endpoint = '$url/api/v1/station';
    final response = await httpAdapter.post(endpoint, data: stationData);
    switch (response.statusCode) {
      case 200:
      case 201:
        // print('200/201 response data: ${response.data}');
        return ModelStation.fromJson(response.data['data']);
      case 400:
        // print('400 response data: ${response.data}');
        throw Exception('Bad request: ${response.data['message']}');
      case 409:
        // print('409 response data: ${response.data}');
        throw Exception('Conflict: ${response.data['message']}');
      default:
        throw Exception('Failed to create station: ${response.statusCode}');
    }
  }

  @override
  Future<int> createCharger(Map<String, dynamic> chargerData) async {
    final String endpoint = '$url/api/v1/charger';
    final response = await httpAdapter.post(endpoint, data: chargerData);
    return response.statusCode!;
  }

  @override
  Future<ModelCharger> findOneCharger(Map<String, dynamic> query) async {
    final String endpoint = '$url/api/v1/charger/${query['id']}';
    final response = await httpAdapter.get(endpoint);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseCharger = response.data['data'];
      return ModelCharger.fromJson(responseCharger);
    } else {
      throw Exception('Failed to fetch charger: ${response.statusCode}');
    }
  }
}
