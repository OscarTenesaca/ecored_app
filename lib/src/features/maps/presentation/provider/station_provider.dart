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
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   isLoading = true;
      //   errorMessage = null;
      //   notifyListeners();
      // });
      log('************ StationProvider findAllStations called ***********');

      stations = await services.findAllStations(query);
      log('StationProvider findAllStations: ${stations?.length}');
      // Process the stations as needed
    } catch (e) {
      log('Error in StationProvider findAllStations: $e');
      errorMessage = e.toString();
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading = false;
        notifyListeners();
      });
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
}
