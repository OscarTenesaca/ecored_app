import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_station_preview.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/domain/usecases/station_services.dart';
import 'package:flutter/cupertino.dart';

class StationProvider extends ChangeNotifier {
  final StationServices services;

  bool isLoading = false;
  List<ModelStation>? stations;
  List<ModelCharger>? chargers;
  ModelStationPreview? stationPreview;
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
    // No usa el `isLoading` compartido: findAllStations también lo usa
    // para el overlay de carga del mapa, y si ambas llamadas coinciden
    // esta podía apagarlo antes de tiempo.
    try {
      chargers = await services.findAllChargers(query);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
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

  Future<void> getStationPreview(String stationId) async {
    // No usa el `isLoading` compartido: findAllStations también lo usa
    // para el overlay de carga del mapa (mismo motivo que findAllChargers).
    try {
      errorMessage = null;
      stationPreview = await services.getStationPreview(stationId);
    } catch (e) {
      errorMessage = e.toString();
      stationPreview = null;
    } finally {
      notifyListeners();
    }
  }
}
