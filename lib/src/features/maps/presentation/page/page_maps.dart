import 'dart:developer';

import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:latlong2/latlong.dart';

class PageMaps extends StatefulWidget {
  const PageMaps({super.key});

  @override
  State<PageMaps> createState() => _PageMapsState();
}

class _PageMapsState extends State<PageMaps> {
  List<ModelStation> stationLocations = [];
  late PermissionGpsProvider gpsProvider;

  @override
  void initState() {
    _loadMarkers();
    gpsProvider = context.read<PermissionGpsProvider>();

    // Obtener posición inicial
    gpsProvider.getCurrentPosition();

    // Iniciar tracking
    gpsProvider.startTracking();

    super.initState();
  }

  @override
  void dispose() {
    gpsProvider.stopTracking(); // ya no usamos context
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<StationProvider, PermissionGpsProvider>(
        builder: (context, stationProvider, gpsProvider, _) {
          return Stack(
            children: [
              CustomMap(
                latLngMarkers: stationLocations,
                userMarker:
                    gpsProvider.currentPosition != null
                        ? LatLng(
                          gpsProvider.currentPosition!.latitude,
                          gpsProvider.currentPosition!.longitude,
                        )
                        : null,
              ),

              Visibility(
                visible: stationProvider.isLoading,
                child: Blur(
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          );
        },
      ),
    );

    // return Consumer<PermissionGpsProvider>(
    //   builder: (context, provider, _) {
    //     if (!provider.isAllGranted) {
    //       return PermissionGPS();
    //     }

    // return Scaffold(
    // body: Consumer<StationProvider>(
    //   builder: (context, provider, _) {
    //     return Stack(
    //       children: [
    //         CustomMap(
    //           latLngMarkers: stationLocations,
    //           userMarker:
    //               providerPermissin.currentPosition != null
    //                   ? LatLng(
    //                     providerPermissin.currentPosition!.latitude,
    //                     providerPermissin.currentPosition!.longitude,
    //                   )
    //                   : null,
    //         ),

    //         Visibility(
    //           visible: provider.isLoading,
    //           child: Blur(
    //             child: const Center(child: CircularProgressIndicator()),
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // ),
    // );
    // },
    // );
  }

  Future<void> _loadMarkers() async {
    final provider = context.read<StationProvider>();

    // await provider.findAllStations({'status': 'AVAILABLE'});
    await provider.findAllStations({});
    stationLocations = provider.stations!;
  }
}
