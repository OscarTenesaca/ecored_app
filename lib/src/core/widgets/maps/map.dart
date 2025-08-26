import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMap extends StatefulWidget {
  final bool isMapReady;
  final LatLng initLatLng;
  final double initialZoom;
  final List<ModelStation> latLngMarkers;

  const CustomMap({
    super.key,
    this.isMapReady = false,
    this.initLatLng = const LatLng(-2.888100139166612, -78.98455544907367),
    this.initialZoom = 16,
    this.latLngMarkers = const [],
  });

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  late final MapController _mapController;
  final ValueNotifier<ModelStation?> selectedMarker =
      ValueNotifier<ModelStation?>(null);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds();
    });
  }

  @override
  void didUpdateWidget(covariant CustomMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cuando cambia la lista de estaciones, ajustar el mapa
    if (widget.latLngMarkers != oldWidget.latLngMarkers &&
        widget.latLngMarkers.isNotEmpty) {
      _fitBounds();
    }
  }

  /// Ajusta el zoom a los bounds de los marcadores
  void _fitBounds() {
    if (widget.latLngMarkers.isEmpty) return;

    final firstMarker = LatLng(
      double.parse(widget.latLngMarkers.first.lat),
      double.parse(widget.latLngMarkers.first.lng),
    );

    final bounds = LatLngBounds(firstMarker, firstMarker);

    for (final markerData in widget.latLngMarkers) {
      bounds.extend(
        LatLng(double.parse(markerData.lat), double.parse(markerData.lng)),
      );
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
              if (widget.latLngMarkers.isNotEmpty)
                MarkerLayer(
                  markers:
                      widget.latLngMarkers
                          .map(
                            (markerData) => Marker(
                              width: 40,
                              height: 40,
                              point: LatLng(
                                double.parse(markerData.lat),
                                double.parse(markerData.lng),
                              ),

                              child: IconButton(
                                onPressed: () {
                                  selectedMarker.value = markerData;
                                },
                                icon: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
            ],
          ),
        ),

        // Pin centrado (opcional)
        Center(
          child: IgnorePointer(
            child: Container(
              height: 35,
              width: 35,
              decoration: const BoxDecoration(shape: BoxShape.circle),
            ),
          ),
        ),

        ValueListenableBuilder<ModelStation?>(
          valueListenable: selectedMarker,
          builder: (context, marker, child) {
            if (marker == null) return const SizedBox.shrink();
            return MapCardInfomation(
              stationData: marker,
              onClose: () => selectedMarker.value = null,
            );
          },
        ),
      ],
    );
  }
}
