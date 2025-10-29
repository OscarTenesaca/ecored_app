import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/domain/usecases/station_services.dart';
import 'package:flutter/cupertino.dart';

class StationProvider extends ChangeNotifier {
  final StationServices services;

  bool isLoading = false;
  List<ModelStation>? stations;
  String? errorMessage;

  StationProvider(this.services);

  Future<void> findAllStations(Map<String, dynamic> query) async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading = true;
        errorMessage = null;
        notifyListeners();
      });

      stations = await services.findAllStations(query);
      print('StationProvider findAllStations: ${stations?.length}');
      // Process the stations as needed
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading = false;
        notifyListeners();
      });
    }
  }
}
