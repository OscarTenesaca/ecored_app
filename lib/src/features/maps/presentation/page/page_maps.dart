// import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
// import 'package:ecored_app/src/core/widgets/maps/map_permission.dart';
// import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:ecored_app/src/core/theme/theme_index.dart';

// class PageMaps extends StatefulWidget {
//   const PageMaps({super.key});

//   @override
//   State<PageMaps> createState() => _PageMapsState();
// }

// class _PageMapsState extends State<PageMaps> {
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final gps = context.read<PermissionGpsProvider>();
//       final station = context.read<StationProvider>();

//       // ⏳ esperar inicialización del provider
//       while (gps.isLoading) {
//         await Future.delayed(const Duration(milliseconds: 100));
//       }

//       // ❌ permisos o GPS no listos
//       if (!gps.isAllGranted) {
//         print('❌ GPS o permisos no listos');
//         return;
//       }

//       // ✅ obtener ubicación
//       final position = await gps.getCurrentPosition();
//       print('📍 posición actual: $position');

//       await station.findAllStations({});
//       gps.startTracking(); // opcional
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor(),
//       body: Consumer2<PermissionGpsProvider, StationProvider>(
//         builder: (context, gps, station, _) {
//           if (gps.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!gps.isGpsEnabled || !gps.isPermissionGranted) {
//             return MapPermission(
//               isAllGranted: gps.isAllGranted,
//               onPressed: gps.openSettings,
//             );
//           }

//           if (gps.currentPosition == null) {
//             return const Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 12),
//                   Text('Obteniendo ubicación GPS...'),
//                 ],
//               ),
//             );
//           }

//           final position = gps.currentPosition!;

//           // ✅ YA NO SE QUEDA AQUÍ
//           return Stack(
//             children: [
//               Center(
//                 child: Text(
//                   'MAPA → ${position.latitude}, ${position.longitude}',
//                 ),
//               ),

//               if (station.isLoading)
//                 const Center(child: CircularProgressIndicator()),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';

import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';

class PageMaps extends StatefulWidget {
  const PageMaps({super.key});

  @override
  State<PageMaps> createState() => _PageMapsState();
}

class _PageMapsState extends State<PageMaps> {
  late PermissionGpsProvider _gps;
  late StationProvider _station;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _gps = context.read<PermissionGpsProvider>();
      _station = context.read<StationProvider>();

      // ⏳ esperar inicialización del provider
      while (_gps.isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // ❌ permisos o GPS no listos
      if (!_gps.isAllGranted) {
        print('❌ GPS o permisos no listos');
        return;
      }

      // ✅ obtener ubicación
      final position = await _gps.getCurrentPosition();
      print('📍 posición actual: $position');

      await _station.findAllStations({});

      // 🔄 iniciar tracking
      _gps.startTracking();
    });
  }

  @override
  void dispose() {
    _gps.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor(),
      body: Consumer2<PermissionGpsProvider, StationProvider>(
        builder: (context, gps, station, _) {
          if (gps.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!gps.isGpsEnabled || !gps.isPermissionGranted) {
            return MapPermission(
              isAllGranted: gps.isAllGranted,
              onPressed: gps.openSettings,
            );
          }

          if (gps.currentPosition == null) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Obteniendo ubicación GPS...'),
                ],
              ),
            );
          }

          final position = gps.currentPosition!;

          return Stack(
            children: [
              CustomMap(
                latLngMarkers: station.stations ?? [],
                userMarker: LatLng(position.latitude, position.longitude),
              ),

              // CONTROLLER DE POSICIÓN
              Positioned(
                bottom: UtilSize.bottomPadding() + 80,
                right: 20,
                child: Column(
                  children: <Widget>[
                    CustomButtonCircle(
                      icon: Icons.local_gas_station_sharp,
                      color: primaryColor(),
                      onPressed: () async {
                        print('add new station');
                        Navigator.pushNamed(context, RouteNames.pageStation);
                      },
                    ),
                    SizedBox(height: 16),
                    CustomButtonCircle(
                      icon: Icons.my_location,
                      color: primaryColor(),
                      onPressed: () async {
                        final pos = await gps.getCurrentPosition();
                        print('📍 posición actual (botón): $pos');
                      },
                    ),
                  ],
                ),
              ),

              if (station.isLoading)
                Blur(child: const Center(child: CircularProgressIndicator())),
            ],
          );
        },
      ),
    );
  }
}

// import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
// import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:latlong2/latlong.dart';

// class PageMaps extends StatefulWidget {
//   const PageMaps({super.key});

//   @override
//   State<PageMaps> createState() => _PageMapsState();
// }

// class _PageMapsState extends State<PageMaps> {
//   List<ModelStation> stationLocations = [];
//   late PermissionGpsProvider gpsProvider;

//   @override
//   void initState() {
//     _loadMarkers();
//     gpsProvider = context.read<PermissionGpsProvider>();

//     // Obtener posición inicial
//     gpsProvider.getCurrentPosition();

//     // Iniciar tracking
//     gpsProvider.startTracking();

//     super.initState();
//   }

//   @override
//   void dispose() {
//     gpsProvider.stopTracking(); // ya no usamos context
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Consumer2<StationProvider, PermissionGpsProvider>(
//         builder: (context, stationProvider, gpsProvider, _) {
//           return Stack(
//             children: [
//               CustomMap(
//                 latLngMarkers: stationLocations,
//                 userMarker:
//                     gpsProvider.currentPosition != null
//                         ? LatLng(
//                           gpsProvider.currentPosition!.latitude,
//                           gpsProvider.currentPosition!.longitude,
//                         )
//                         : null,
//               ),

//               Visibility(
//                 visible: stationProvider.isLoading,
//                 child: Blur(
//                   child: const Center(child: CircularProgressIndicator()),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     // return Consumer<PermissionGpsProvider>(
//     //   builder: (context, provider, _) {
//     //     if (!provider.isAllGranted) {
//     //       return PermissionGPS();
//     //     }

//     // return Scaffold(
//     // body: Consumer<StationProvider>(
//     //   builder: (context, provider, _) {
//     //     return Stack(
//     //       children: [
//     //         CustomMap(
//     //           latLngMarkers: stationLocations,
//     //           userMarker:
//     //               providerPermissin.currentPosition != null
//     //                   ? LatLng(
//     //                     providerPermissin.currentPosition!.latitude,
//     //                     providerPermissin.currentPosition!.longitude,
//     //                   )
//     //                   : null,
//     //         ),

//     //         Visibility(
//     //           visible: provider.isLoading,
//     //           child: Blur(
//     //             child: const Center(child: CircularProgressIndicator()),
//     //           ),
//     //         ),
//     //       ],
//     //     );
//     //   },
//     // ),
//     // );
//     // },
//     // );
//   }

//   Future<void> _loadMarkers() async {
//     final provider = context.read<StationProvider>();

//     // await provider.findAllStations({'status': 'AVAILABLE'});
//     await provider.findAllStations({});
//     stationLocations = provider.stations!;
//   }
// }
