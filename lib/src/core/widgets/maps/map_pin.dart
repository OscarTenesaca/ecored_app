import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMapPin extends StatefulWidget {
  static const LatLng defaultPosition = LatLng(
    -2.888100139166612,
    -78.98455544907367,
  );

  final LatLng? initialPosition;
  // Cada vez que cambia, el mapa se mueve a esta posición (p. ej. "Usar mi
  // ubicación"). No dispara onLocationSelected: quien la cambia ya conoce
  // la coordenada.
  final LatLng? focusPosition;
  final Color pinColor;
  final ValueChanged<LatLng> onLocationSelected;

  const CustomMapPin({
    super.key,
    this.initialPosition,
    this.focusPosition,
    this.pinColor = Colors.red,
    required this.onLocationSelected,
  });

  @override
  State<CustomMapPin> createState() => _CustomMapPinState();
}

class _CustomMapPinState extends State<CustomMapPin> {
  static const double _pinSize = 46;

  late final MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapController();
  }

  @override
  void didUpdateWidget(covariant CustomMapPin oldWidget) {
    super.didUpdateWidget(oldWidget);
    final focus = widget.focusPosition;
    if (focus != null && focus != oldWidget.focusPosition) {
      _controller.move(focus, _controller.camera.zoom);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter:
                widget.initialPosition ?? CustomMapPin.defaultPosition,
            initialZoom: 16,

            // Sin esto, si el usuario no mueve el mapa nunca se reporta la
            // posición inicial y la estación quedaría sin coordenadas.
            onMapReady:
                () => widget.onLocationSelected(_controller.camera.center),

            // Se ejecuta cuando el usuario deja de mover el mapa
            onMapEvent: (event) {
              if (event is MapEventMoveEnd) {
                widget.onLocationSelected(_controller.camera.center);
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

        // 📍 PIN FIJO EN EL CENTRO — el padding inferior deja la punta del
        // ícono (no su centro) sobre la coordenada reportada.
        Center(
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.only(bottom: _pinSize * 0.83),
              child: Icon(
                Icons.location_on,
                size: _pinSize,
                color: widget.pinColor,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
