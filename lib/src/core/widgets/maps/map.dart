import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMap extends StatefulWidget {
  final bool isMapReady;
  final LatLng initLatLng;
  final double initialZoom;
  final List<Map>? latLngMarkers;

  const CustomMap({
    super.key,
    this.isMapReady = false,
    this.initLatLng = const LatLng(-2.888100139166612, -78.98455544907367),
    this.initialZoom = 16,
    this.latLngMarkers,
  });

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Esperar que se construya el widget y luego ajustar el zoom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds();
    });
  }

  /// Método que ajusta el mapa a los bounds de los marcadores
  void _fitBounds() {
    if (widget.latLngMarkers == null || widget.latLngMarkers!.isEmpty) return;

    final firstMarker = LatLng(
      widget.latLngMarkers!.first['lat'],
      widget.latLngMarkers!.first['lng'],
    );

    // Inicializamos con el primer punto
    final bounds = LatLngBounds(firstMarker, firstMarker);

    for (final markerData in widget.latLngMarkers!) {
      bounds.extend(LatLng(markerData['lat'], markerData['lng']));
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
        maxZoom: 17,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: widget.isMapReady,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initLatLng,
              initialZoom: widget.initialZoom,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga',
                subdomains: ['a', 'b', 'c'],
              ),
              if (widget.latLngMarkers != null &&
                  widget.latLngMarkers!.isNotEmpty)
                MarkerLayer(
                  markers:
                      widget.latLngMarkers!
                          .map(
                            (markerData) => Marker(
                              width: 40,
                              height: 40,
                              point: LatLng(
                                markerData['lat'],
                                markerData['lng'],
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          )
                          .toList(),
                ),
            ],
          ),
        ),

        // Pin centrado (opcional: podría cambiarse por un ícono si deseas)
        Center(
          child: IgnorePointer(
            child: Container(
              height: 35,
              width: 35,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                // color: Colors.red, // color desactivado
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class CustomMap extends StatefulWidget {
//   final bool isMapReady;
//   final LatLng initLatLng;
//   final double initialZoom;
//   final List<Map>? latLngMarkers;

//   const CustomMap({
//     super.key,
//     this.isMapReady = false,
//     this.initLatLng = const LatLng(-2.888100139166612, -78.98455544907367),
//     this.initialZoom = 16,
//     this.latLngMarkers,
//   });

//   @override
//   _CustomMapState createState() => _CustomMapState();
// }

// class _CustomMapState extends State<CustomMap> {
//   late MapController _mapController;

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         AbsorbPointer(
//           absorbing: widget.isMapReady,
//           child: FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: widget.initLatLng,
//               initialZoom: widget.initialZoom,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate:
//                     'https://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga',
//                 subdomains: ['a', 'b', 'c'],
//               ),
//               // ✅ El MarkerLayer debe ir aquí dentro
//               if (widget.latLngMarkers != null &&
//                   widget.latLngMarkers!.isNotEmpty)
//                 MarkerLayer(
//                   markers:
//                       widget.latLngMarkers!
//                           .map(
//                             (markerData) => Marker(
//                               width: 40,
//                               height: 40,
//                               point: LatLng(
//                                 markerData['lat'],
//                                 markerData['lng'],
//                               ),
//                               child: const Icon(
//                                 Icons.location_on,
//                                 color: Colors.red,
//                                 size: 40,
//                               ),
//                             ),
//                           )
//                           .toList(),
//                 ),
//             ],
//           ),
//         ),

//         // Pin centrado
//         Center(
//           child: IgnorePointer(
//             child: Container(
//               height: 35,
//               width: 35,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 // color: Colors.red,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
