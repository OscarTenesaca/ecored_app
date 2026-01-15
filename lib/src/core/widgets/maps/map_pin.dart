import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMapPin extends StatefulWidget {
  final LatLng initialPosition;
  final ValueChanged<LatLng> onLocationSelected;

  const CustomMapPin({
    super.key,
    this.initialPosition = const LatLng(-2.888100139166612, -78.98455544907367),
    required this.onLocationSelected,
  });

  @override
  State<CustomMapPin> createState() => _CustomMapPinState();
}

class _CustomMapPinState extends State<CustomMapPin> {
  late final MapController _controller;
  LatLng? _center;

  @override
  void initState() {
    super.initState();
    _controller = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: widget.initialPosition,
            initialZoom: 16,

            // Se ejecuta cuando el usuario deja de mover el mapa
            onMapEvent: (event) {
              if (event is MapEventMoveEnd) {
                final center = _controller.camera.center;
                _center = center;
                widget.onLocationSelected(center);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga',
              subdomains: ['a', 'b', 'c'],
            ),
          ],
        ),

        // 📍 PIN FIJO EN EL CENTRO
        const Center(
          child: IgnorePointer(
            child: Icon(Icons.location_pin, size: 46, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
