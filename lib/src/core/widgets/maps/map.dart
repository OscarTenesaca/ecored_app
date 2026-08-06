import 'dart:convert';

import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_enums.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Color según el estado de la estación/cargador, consistente con la
/// leyenda del mapa: verde = disponible, azul = ocupado,
/// naranja = mantenimiento, rojo = fuera de servicio.
Color stationStatusColor(String status) {
  switch (status) {
    case 'OCCUPIED':
      return infoColor();
    case 'MAINTENANCE':
      return warningColor();
    case 'OUT_OF_SERVICE':
      return errorColor();
    case 'AVAILABLE':
    default:
      return accentColor();
  }
}

/// Etiqueta legible del estado, usada tanto en la ficha de estación
/// como en la leyenda del mapa.
String stationStatusLabel(String status) {
  final match = STATION_STATUS_LIST.firstWhere(
    (s) => s['key'] == status,
    orElse: () => const {'label': 'No Disponible'},
  );
  return match['label']!;
}

class CustomMap extends StatefulWidget {
  final bool isMapReady;
  final LatLng initLatLng;
  final double initialZoom;
  final List<ModelStation> latLngMarkers;
  final LatLng? userMarker;

  /// Notifier del marcador seleccionado. Si se provee, quien lo pasa es
  /// responsable de escucharlo y de mostrar `MapCardInfomation` en su
  /// propio árbol (así puede pintarse por encima de otros overlays,
  /// como botones flotantes o la leyenda). Si no se provee, `CustomMap`
  /// crea y gestiona uno internamente.
  final ValueNotifier<ModelStation?>? selectedMarkerNotifier;

  /// Cada vez que su `value` cambia, el mapa anima la cámara hacia esa
  /// posición (p. ej. lo dispara un botón "mi ubicación" externo). No
  /// reacciona a `userMarker` directamente para no auto-recentrar el
  /// mapa en cada actualización pasiva del tracking de GPS.
  final ValueNotifier<LatLng>? recenterRequest;

  const CustomMap({
    super.key,
    this.isMapReady = false,
    this.initLatLng = const LatLng(-2.888100139166612, -78.98455544907367),
    this.initialZoom = 16,
    this.latLngMarkers = const [],
    this.userMarker = const LatLng(-2.888100139166612, -78.98455544907367),
    this.selectedMarkerNotifier,
    this.recenterRequest,
  });

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final ValueNotifier<ModelStation?> _internalSelectedMarker;

  // Un único AnimationController para toda la vida del widget: se crea
  // una sola vez y se reinicia (reset + forward) en cada recentrado, en
  // vez de crear/disponer uno nuevo por toque (eso causaba "dispose()
  // called more than once" si un segundo toque llegaba antes de que el
  // anterior terminara de limpiarse).
  late final AnimationController _cameraAnimationController;
  CurvedAnimation? _cameraCurve;
  VoidCallback? _cameraCurveListener;

  bool get _ownsSelectedMarker => widget.selectedMarkerNotifier == null;
  ValueNotifier<ModelStation?> get selectedMarker =>
      widget.selectedMarkerNotifier ?? _internalSelectedMarker;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _internalSelectedMarker = ValueNotifier<ModelStation?>(null);
    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    widget.recenterRequest?.addListener(_onRecenterRequested);
  }

  @override
  void dispose() {
    widget.recenterRequest?.removeListener(_onRecenterRequested);
    _disposeCameraCurve();
    _cameraAnimationController.dispose();
    _mapController.dispose();
    if (_ownsSelectedMarker) _internalSelectedMarker.dispose();
    super.dispose();
  }

  void _disposeCameraCurve() {
    if (_cameraCurveListener != null) {
      _cameraCurve?.removeListener(_cameraCurveListener!);
    }
    _cameraCurve?.dispose();
    _cameraCurve = null;
    _cameraCurveListener = null;
  }

  @override
  void didUpdateWidget(covariant CustomMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cuando cambia la lista de estaciones, ajustar el mapa
    if (widget.latLngMarkers != oldWidget.latLngMarkers &&
        widget.latLngMarkers.isNotEmpty) {
      // _fitBounds();
    }

    if (oldWidget.recenterRequest != widget.recenterRequest) {
      oldWidget.recenterRequest?.removeListener(_onRecenterRequested);
      widget.recenterRequest?.addListener(_onRecenterRequested);
    }
  }

  void _onRecenterRequested() {
    final target = widget.recenterRequest?.value;
    if (target != null) _moveToUser(target);
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

  /// Anima la cámara hacia [destination] preservando el zoom actual
  /// (no se fuerza un zoom fijo para no pelear con lo que el usuario ya
  /// tenía configurado manualmente).
  void _moveToUser(LatLng destination) {
    // Si ya había una animación en curso (segundo toque antes de que
    // termine la primera), se descarta su listener para no mezclar
    // destinos ni dejar callbacks huérfanos.
    _disposeCameraCurve();

    final startCenter = _mapController.camera.center;
    final zoom = _mapController.camera.zoom;

    final curve = CurvedAnimation(
      parent: _cameraAnimationController,
      curve: Curves.easeInOut,
    );
    void listener() {
      final t = curve.value;
      final lat =
          startCenter.latitude +
          (destination.latitude - startCenter.latitude) * t;
      final lng =
          startCenter.longitude +
          (destination.longitude - startCenter.longitude) * t;
      _mapController.move(LatLng(lat, lng), zoom);
    }

    _cameraCurve = curve;
    _cameraCurveListener = listener;
    curve.addListener(listener);

    _cameraAnimationController
      ..stop()
      ..reset()
      ..forward();
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
              // Se centra en la posición real desde el primer frame:
              // evita el salto de cámara y el problema de que el mapa
              // quedaba en blanco hasta la primera interacción del
              // usuario (ver _moveToUser).
              initialCenter: widget.userMarker ?? widget.initLatLng,
              initialZoom: widget.initialZoom,
            ),
            children: [
              // Capa de mapa base — opciones gratuitas/públicas de
              // flutter_map, sin API key. Deja una sola activa (la que
              // no está comentada) y usa las demás para probar rápido.
              TileLayer(
                // Google Maps (estilo estándar): calles con nombres,
                // POIs y colores por defecto de Google. Endpoint no
                // oficial/no documentado — funcionaba, pero no tiene
                // garantía de soporte a largo plazo.
                urlTemplate:
                    'https://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga',
                subdomains: ['a', 'b', 'c'],

                // CartoDB Voyager: balanceado entre OSM y un estilo
                // "de navegación" moderno, colores suaves y etiquetas
                // muy legibles.
                // urlTemplate:
                //     'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                // subdomains: ['a', 'b', 'c', 'd'],

                // ✅ ACTIVA — CartoDB Dark Matter (oscuro): combina con
                // la UI dark de la app y hace resaltar mucho más los
                // pines de color (estado de estación + avatar de
                // usuario) que sobre un fondo claro.
                // urlTemplate:
                //     'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                // subdomains: ['a', 'b', 'c', 'd'],

                // OpenTopoMap: mapa topográfico con curvas de nivel y
                // relieve, útil si se necesita mostrar terreno/altitud.
                // urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
                // subdomains: ['a', 'b', 'c'],

                // CartoDB Positron (claro): minimalista, fondo claro y
                // calles en gris suave, muy legible con marcadores de
                // color encima.
                // urlTemplate:
                //     'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                // subdomains: ['a', 'b', 'c', 'd'],
              ),
              if (widget.latLngMarkers.isNotEmpty)
                MarkerLayer(
                  markers:
                      widget.latLngMarkers
                          .map(
                            (markerData) => Marker(
                              width: 44,
                              height: 44,
                              point: LatLng(
                                double.parse(markerData.lat),
                                double.parse(markerData.lng),
                              ),
                              child: _StationMarker(
                                color: stationStatusColor(markerData.status),
                                onTap: () {
                                  selectedMarker.value = markerData;
                                },
                              ),
                            ),
                          )
                          .toList(),
                ),

              // 🔹 Usuario
              if (widget.userMarker != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 58,
                      height: 58,
                      point: widget.userMarker!,
                      // point: widget.initLatLng,
                      child: const _UserMarker(),
                    ),
                  ],
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

        // Si nadie pasó su propio notifier, `CustomMap` muestra la ficha
        // de estación aquí mismo (comportamiento igual al de antes).
        if (_ownsSelectedMarker)
          ValueListenableBuilder<ModelStation?>(
            valueListenable: selectedMarker,
            builder: (context, marker, child) {
              if (marker == null) return const SizedBox.shrink();
              return MapCardInfomation(
                stationData: marker,
                userMarker: widget.userMarker,
                onClose: () => selectedMarker.value = null,
              );
            },
          ),
      ],
    );
  }
}

/// Pin moderno para una estación: insignia circular con el ícono del
/// estado (mismo `stationStatusColor` de siempre) sobre un fondo oscuro
/// translúcido, en vez del `Icons.local_gas_station` genérico. Solo
/// cambia la presentación — el `onTap` sigue disparando exactamente la
/// misma selección de marcador que antes.
class _StationMarker extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _StationMarker({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor().withValues(alpha: 0.94),
            border: Border.all(color: color.withValues(alpha: 0.9), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 10,
                spreadRadius: 0.5,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.ev_station_rounded, color: color, size: 22),
        ),
      ),
    );
  }
}

/// Pin del usuario: avatar circular con su foto de perfil (o un ícono de
/// respaldo si no tiene), halo difuminado con `Blur` y borde/sombra en el
/// color de acento de la app — reemplaza el `Icons.person_pin_circle`
/// genérico. No participa en ningún gesto ni lógica, es puramente visual.
class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    final img = Preferences().getUser()?.img ?? '';

    return Stack(
      alignment: Alignment.center,
      children: [
        // Halo difuminado detrás del avatar.
        ClipOval(
          child: Blur(
            type: BlurType.blur,
            intensity: 8,
            blurColor: accentColor(),
            opacity: 0.18,
            borderRadius: BorderRadius.circular(100),
            child: const SizedBox(width: 52, height: 52),
          ),
        ),
        // Resplandor suave (glow) con el color de acento.
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor().withValues(alpha: 0.45),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(2.4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor(),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(child: _UserAvatarImage(img: img)),
        ),
      ],
    );
  }
}

class _UserAvatarImage extends StatelessWidget {
  final String img;

  const _UserAvatarImage({required this.img});

  @override
  Widget build(BuildContext context) {
    if (img.isEmpty) return _fallback();

    if (img.contains('files/user/')) {
      return Image.network(
        img,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    try {
      return Image.memory(base64.decode(img), fit: BoxFit.cover);
    } catch (_) {
      return _fallback();
    }
  }

  Widget _fallback() {
    return Container(
      color: deepForestGreen(),
      alignment: Alignment.center,
      child: Icon(Icons.person, color: accentColor(), size: 18),
    );
  }
}
