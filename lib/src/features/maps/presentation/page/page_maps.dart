// import 'package:ecored_app/src/core/utils/utils_index.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class PageMaps extends StatefulWidget {
//   const PageMaps({super.key});

//   @override
//   State<PageMaps> createState() => _PageMapsState();
// }

// class _PageMapsState extends State<PageMaps> {
//   @override
//   void initState() {
//     _loadMarkers();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<Map> latLngMarkers = [
//       {'_id': 'aoeurcgc', 'lat': -2.888100139166612, 'lng': -78.98455544907367},
//       {'_id': 'aoeurcgc', 'lat': -2.9014499915134335, 'lng': -78.9937269702811},
//       {'_id': 'aoeurcgc', 'lat': -2.89698963821467, 'lng': -79.00210722955012},
//       {'_id': 'aoeurcgc', 'lat': -2.903732995835395, 'lng': -79.0187781133494},
//     ];

//     return Scaffold(body: CustomMap(latLngMarkers: latLngMarkers));
//   }

//   Future<void> _loadMarkers() async {
//     final provider = context.read<StationProvider>();
//     print('PageMaps _loadMarkers');

//     await provider.findAllStations({'status': 'AVAILABLE'});
//     Logger.logDev(provider.stations.toString());
//   }
// }

import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageMaps extends StatefulWidget {
  const PageMaps({super.key});

  @override
  State<PageMaps> createState() => _PageMapsState();
}

class _PageMapsState extends State<PageMaps> {
  List<ModelStation> stationLocations = [];

  @override
  void initState() {
    _loadMarkers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gpsProvider = context.watch<PermissionGpsProvider>();
    print(gpsProvider.isPermissionGranted);
    print(gpsProvider.isAllGranted);

    return Scaffold(body: CustomMap(latLngMarkers: stationLocations));
  }

  Future<void> _loadMarkers() async {
    final provider = context.read<StationProvider>();

    // await provider.findAllStations({'status': 'AVAILABLE'});
    await provider.findAllStations({});
    stationLocations = provider.stations!;
    Logger.logDev(provider.stations.toString());
  }
}
