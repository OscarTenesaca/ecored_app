import 'dart:developer';

import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/domain/usecases/station_services.dart';
import 'package:flutter/cupertino.dart';

class StationProvider extends ChangeNotifier {
  final StationServices services;

  bool isLoading = false;
  List<ModelStation>? stations;
  List<ModelCharger>? chargers;
  String? errorMessage;

  StationProvider(this.services);
  Future<void> findAllStations(Map<String, dynamic> query) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      stations = await services.findAllStations(query);
    } catch (e) {
      errorMessage = e.toString();
      stations = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> findAllChargers(Map<String, dynamic> query) async {
    try {
      chargers = await services.findAllChargers(query);
    } catch (e) {
      log('Error in StationProvider findAllChargers: $e');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<ModelStation> createStation(Map<String, dynamic> stationData) async {
  //   try {
  //     isLoading = true;
  //     errorMessage = null;
  //     notifyListeners();

  //     final ModelStation station = await services.createStation(stationData);
  //     print('provider created station: ${station.toJson()}');
  //     errorMessage = null;
  //     return station;
  //   } catch (e) {
  //     print('provider createStation error: $e');
  //     errorMessage = e.toString();
  //     return Future.error(e);
  //   } finally {
  //     print('provider createStation finally');
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<ModelStation> createStation(Map<String, dynamic> stationData) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final station = await services.createStation(stationData);
      return station;
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<int> createCharger(Map<String, dynamic> chargerData) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final statusCode = await services.createCharger(chargerData);
      return statusCode;
    } catch (e) {
      errorMessage = e.toString();
      return -1;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
