import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

// `GET /station` devuelve 10 por defecto; el mapa (y el buscador/filtros,
// que trabajan sobre lo cargado) necesita todas las estaciones visibles.
const int _mapStationsLimit = 500;

class PageMaps extends StatefulWidget {
  const PageMaps({super.key});

  @override
  State<PageMaps> createState() => _PageMapsState();
}

class _PageMapsState extends State<PageMaps> {
  PermissionGpsProvider? _gps;
  late StationProvider _station;

  // Se maneja aquí (y no dentro de CustomMap) para poder pintar
  // MapCardInfomation por encima de los botones flotantes y la leyenda.
  final ValueNotifier<ModelStation?> _selectedMarker =
      ValueNotifier<ModelStation?>(null);

  // Dispara la animación de la cámara hacia una posición puntual (botón
  // "mi ubicación" o un resultado del buscador); no se usa para el
  // tracking pasivo de GPS.
  final ValueNotifier<LatLng> _recenterRequest = ValueNotifier<LatLng>(
    const LatLng(0, 0),
  );

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  MapStationFilters _filters = const MapStationFilters();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gps = context.read<PermissionGpsProvider>();
      _gps = gps;
      _station = context.read<StationProvider>();

      // ⏳ esperar inicialización del provider
      while (gps.isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // ❌ permisos o GPS no listos
      if (!gps.isAllGranted) {
        return;
      }

      // ✅ obtener ubicación
      await gps.getCurrentPosition();
      await _station.findAllStations({'limit': _mapStationsLimit});

      // 🔄 iniciar tracking
      gps.startTracking();
    });
  }

  @override
  void dispose() {
    _gps?.stopTracking();
    _selectedMarker.dispose();
    _recenterRequest.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _focusStation(ModelStation station) {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {});

    final lat = double.tryParse(station.lat);
    final lng = double.tryParse(station.lng);
    if (lat != null && lng != null) {
      _recenterRequest.value = LatLng(lat, lng);
    }
    _selectedMarker.value = station;
  }

  Future<void> _openFilters(List<ModelStation> stations) async {
    _searchFocus.unfocus();
    final result = await showModalBottomSheet<MapStationFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapFiltersSheet(initial: _filters, stations: stations),
    );
    if (result != null && mounted) setState(() => _filters = result);
  }

  Future<void> _centerOnUser(PermissionGpsProvider gps) async {
    if (!gps.isAllGranted) {
      showSnackbar(
        context,
        'Activa el GPS y otorga permisos de ubicación para centrar el mapa.',
        SnackbarStatus.error,
      );
      return;
    }

    final newPosition = await gps.getCurrentPosition();
    if (!mounted) return;

    if (newPosition == null) {
      showSnackbar(
        context,
        'No se pudo obtener tu ubicación actual.',
        SnackbarStatus.error,
      );
      return;
    }

    _recenterRequest.value = LatLng(
      newPosition.latitude,
      newPosition.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor(),
      // El teclado del buscador no debe redimensionar el mapa.
      resizeToAvoidBottomInset: false,
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
          final allStations = station.stations ?? const <ModelStation>[];
          final visibleStations = allStations.where(_filters.matches).toList();

          return Stack(
            children: [
              CustomMap(
                latLngMarkers: visibleStations,
                userMarker: LatLng(position.latitude, position.longitude),
                selectedMarkerNotifier: _selectedMarker,
                recenterRequest: _recenterRequest,
              ),

              // Botones flotantes
              Positioned(
                bottom: UtilSize.bottomPadding() + 80,
                right: 16,
                child: Column(
                  children: [
                    _MapActionButton(
                      icon: Icons.add_location_alt_outlined,
                      tooltip: 'Nueva estación',
                      primary: true,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            RouteNames.pageStation,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _MapActionButton(
                      icon: Icons.my_location,
                      tooltip: 'Mi ubicación',
                      onTap: () => _centerOnUser(gps),
                    ),
                  ],
                ),
              ),

              if (station.isLoading)
                Blur(
                  child: Center(
                    child: CircularProgressIndicator(color: accentColor()),
                  ),
                ),

              // Leyenda de estados (con cuántas estaciones hay de cada uno)
              Positioned(
                bottom: UtilSize.bottomPadding() + 80,
                left: 16,
                child: _StatusLegend(stations: allStations),
              ),

              // Buscador: se oculta mientras la ficha de estación está abierta.
              ValueListenableBuilder<ModelStation?>(
                valueListenable: _selectedMarker,
                builder: (context, marker, child) {
                  if (marker != null) return const SizedBox.shrink();
                  return _searchArea(visibleStations, allStations);
                },
              ),

              // Ficha de detalle de estación: va al final para pintarse
              // por encima de los botones flotantes, la leyenda y el buscador.
              ValueListenableBuilder<ModelStation?>(
                valueListenable: _selectedMarker,
                builder: (context, marker, child) {
                  if (marker == null) return const SizedBox.shrink();
                  return MapCardInfomation(
                    // Sin key, al cambiar de estación con la ficha abierta se
                    // reutilizaba el State y quedaban los datos de la anterior.
                    key: ValueKey(marker.id),
                    stationData: marker,
                    userMarker: LatLng(position.latitude, position.longitude),
                    onClose: () => _selectedMarker.value = null,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _searchArea(
    List<ModelStation> visibleStations,
    List<ModelStation> allStations,
  ) {
    final query = _searchController.text.trim();
    final results =
        query.isEmpty
            ? const <ModelStation>[]
            : visibleStations
                .where((s) => _matchesSearch(s, query))
                .take(8)
                .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 54,
              padding: const EdgeInsets.only(left: 16, right: 7),
              decoration: _floatingDecoration(radius: 18),
              child: Row(
                children: [
                  Icon(Icons.search, color: grayInputColor()),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: (_) => setState(() {}),
                      onTapOutside: (_) => _searchFocus.unfocus(),
                      textInputAction: TextInputAction.search,
                      cursorColor: accentColor(),
                      style: TextStyle(
                        color: whiteColor(),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Buscar estación o dirección',
                        hintStyle: TextStyle(
                          color: grayInputColor(),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  if (query.isNotEmpty)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.close,
                        color: grayInputColor(),
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
                  _filterButton(allStations),
                ],
              ),
            ),

            if (query.isNotEmpty) ...[
              const SizedBox(height: 8),
              _searchResults(results, query),
            ] else if (!_filters.isEmpty && visibleStations.isEmpty) ...[
              const SizedBox(height: 8),
              _noFilterMatches(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterButton(List<ModelStation> stations) {
    final active = _filters.activeCount;

    return Material(
      color: active > 0 ? accentColor() : accentColor().withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openFilters(stations),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.tune,
                  size: 20,
                  color: active > 0 ? primaryColor() : accentColor(),
                ),
              ),
              if (active > 0)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                    width: 15,
                    height: 15,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primaryColor(),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$active',
                      style: TextStyle(
                        color: accentColor(),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchResults(List<ModelStation> results, String query) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: _floatingDecoration(radius: 18),
      child: Material(
        type: MaterialType.transparency,
        child:
            results.isEmpty
                ? Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'No encontramos estaciones para "$query".',
                    style: TextStyle(color: grayInputColor(), fontSize: 13),
                  ),
                )
                : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: results.length,
                  separatorBuilder:
                      (_, __) => Divider(
                        height: 1,
                        indent: 64,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                  itemBuilder: (_, index) {
                    final station = results[index];
                    final color = stationStatusColor(station.status);
                    final city = station.canton?.name ?? '';
                    final subtitle = [
                      if (station.address.isNotEmpty) station.address,
                      if (city.isNotEmpty) _titleCase(city),
                    ].join(' · ');

                    return InkWell(
                      onTap: () => _focusStation(station),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Icon(
                                stationTypePointIcon(station.typePoint ?? ''),
                                color: color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    station.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: whiteColor(),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (subtitle.isNotEmpty)
                                    Text(
                                      subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: grayInputColor(),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: grayInputColor(),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _noFilterMatches() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 14, right: 4),
        decoration: _floatingDecoration(radius: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ninguna estación coincide con los filtros',
              style: TextStyle(color: whiteColor(), fontSize: 13),
            ),
            TextButton(
              onPressed:
                  () => setState(() => _filters = const MapStationFilters()),
              child: Text(
                'Limpiar',
                style: TextStyle(
                  color: accentColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── Helpers ─────────────────

BoxDecoration _floatingDecoration({double radius = 16}) => BoxDecoration(
  color: primaryColor().withValues(alpha: 0.94),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);

// "CUENCA" → "Cuenca"
String _titleCase(String value) => value
    .toLowerCase()
    .split(' ')
    .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
    .join(' ');

// Minúsculas y sin tildes, para que "cuenca" encuentre "CUENCA" y
// "estacion" encuentre "Estación".
String _normalize(String value) {
  const from = 'áéíóúüñÁÉÍÓÚÜÑ';
  const to = 'aeiouunAEIOUUN';
  final buffer = StringBuffer();
  for (final char in value.split('')) {
    final index = from.indexOf(char);
    buffer.write(index == -1 ? char : to[index]);
  }
  return buffer.toString().toLowerCase();
}

bool _matchesSearch(ModelStation station, String query) {
  final needle = _normalize(query);
  return _normalize(station.name).contains(needle) ||
      _normalize(station.address).contains(needle) ||
      _normalize(station.canton?.name ?? '').contains(needle);
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool primary;

  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final decoration =
        primary
            ? BoxDecoration(
              color: accentColor(),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accentColor().withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            )
            : _floatingDecoration();

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: 52,
          height: 52,
          decoration: decoration,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Icon(
              icon,
              color: primary ? primaryColor() : accentColor(),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  final List<ModelStation> stations;

  const _StatusLegend({required this.stations});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: _floatingDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children:
            STATION_STATUS_LIST.map((s) {
              final key = s['key']!;
              final count = stations.where((st) => st.status == key).length;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: stationStatusColor(key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s['label']!,
                      style: TextStyle(color: whiteColor(), fontSize: 11),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$count',
                      style: TextStyle(
                        color: grayInputColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

// ───────────────── Filtros ─────────────────

/// Filtros que se aplican en el cliente sobre las estaciones ya cargadas.
/// Solo incluye lo que trae la lista de estaciones (estado y tipo de lugar):
/// conector y potencia viven en los cargadores, que `GET /station` no
/// devuelve, así que no se pueden filtrar desde aquí.
class MapStationFilters {
  final Set<String> statuses;
  final Set<String> typePoints;

  const MapStationFilters({
    this.statuses = const {},
    this.typePoints = const {},
  });

  bool get isEmpty => statuses.isEmpty && typePoints.isEmpty;

  int get activeCount => statuses.length + typePoints.length;

  bool matches(ModelStation station) =>
      (statuses.isEmpty || statuses.contains(station.status)) &&
      (typePoints.isEmpty || typePoints.contains(station.typePoint));
}

class MapFiltersSheet extends StatefulWidget {
  final MapStationFilters initial;
  final List<ModelStation> stations;

  const MapFiltersSheet({
    super.key,
    required this.initial,
    required this.stations,
  });

  @override
  State<MapFiltersSheet> createState() => _MapFiltersSheetState();
}

class _MapFiltersSheetState extends State<MapFiltersSheet> {
  late Set<String> _statuses;
  late Set<String> _typePoints;

  @override
  void initState() {
    super.initState();
    _statuses = {...widget.initial.statuses};
    _typePoints = {...widget.initial.typePoints};
  }

  MapStationFilters get _current =>
      MapStationFilters(statuses: _statuses, typePoints: _typePoints);

  void _toggle(Set<String> set, String key) {
    setState(() {
      if (!set.remove(key)) set.add(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final resultCount = widget.stations.where(_current.matches).length;

    // Solo los tipos de lugar que existen entre las estaciones cargadas, en
    // el orden de STATION_TYPE_POINTS_LIST.
    final presentTypes = widget.stations.map((s) => s.typePoint).toSet();
    final typeOptions =
        STATION_TYPE_POINTS_LIST
            .where((t) => presentTypes.contains(t['key']))
            .toList();

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
      decoration: BoxDecoration(
        color: primaryColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Material propio para que los efectos de toque no queden tapados
      // por el fondo del Container.
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
                child: Row(
                  children: [
                    Text(
                      'Filtros',
                      style: TextStyle(
                        color: whiteColor(),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed:
                          _current.isEmpty
                              ? null
                              : () => setState(() {
                                _statuses.clear();
                                _typePoints.clear();
                              }),
                      child: Text(
                        'Restablecer',
                        style: TextStyle(
                          color:
                              _current.isEmpty
                                  ? grayInputColor()
                                  : accentColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Estado'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            STATION_STATUS_LIST.map((s) {
                              final key = s['key']!;
                              return _FilterChoice(
                                label: s['label']!,
                                color: stationStatusColor(key),
                                dot: true,
                                selected: _statuses.contains(key),
                                onTap: () => _toggle(_statuses, key),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('Tipo de lugar'),
                      if (typeOptions.isEmpty)
                        Text(
                          'Las estaciones cargadas no tienen tipo de lugar.',
                          style: TextStyle(
                            color: grayInputColor(),
                            fontSize: 13,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              typeOptions.map((t) {
                                final key = t['key']!;
                                return _FilterChoice(
                                  label: stationTypePointLabel(key) ?? key,
                                  color: accentColor(),
                                  icon: stationTypePointIcon(key),
                                  selected: _typePoints.contains(key),
                                  onTap: () => _toggle(_typePoints, key),
                                );
                              }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: SizedBox(
                  height: 56,
                  child: Material(
                    color: accentColor(),
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: () => Navigator.pop(context, _current),
                      child: Center(
                        child: Text(
                          resultCount == 1
                              ? 'Ver 1 estación'
                              : 'Ver $resultCount estaciones',
                          style: TextStyle(
                            color: primaryColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterChoice extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool dot;
  final IconData? icon;

  const _FilterChoice({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    this.dot = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color:
              selected
                  ? color.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dot)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: selected ? color : grayInputColor(),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? whiteColor() : Colors.white70,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:ecored_app/src/core/routes/routes_name.dart';
// import 'package:ecored_app/src/core/utils/utils_index.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:latlong2/latlong.dart';

// import 'package:ecored_app/src/core/theme/theme_index.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';

// import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
// import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';

// class PageMaps extends StatefulWidget {
//   const PageMaps({super.key});

//   @override
//   State<PageMaps> createState() => _PageMapsState();
// }

// class _PageMapsState extends State<PageMaps> {
//   late PermissionGpsProvider _gps;
//   late StationProvider _station;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       _gps = context.read<PermissionGpsProvider>();
//       _station = context.read<StationProvider>();

//       // ⏳ esperar inicialización del provider
//       while (_gps.isLoading) {
//         await Future.delayed(const Duration(milliseconds: 100));
//       }

//       // ❌ permisos o GPS no listos
//       if (!_gps.isAllGranted) {
//         // print('❌ GPS o permisos no listos');
//         return;
//       }

//       // ✅ obtener ubicación
//       final position = await _gps.getCurrentPosition();
//       print('📍 posición actual: $position');
//       await _station.findAllStations({});

//       // 🔄 iniciar tracking
//       _gps.startTracking();
//     });
//   }

//   @override
//   void dispose() {
//     _gps.stopTracking();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor(),
//       body: Consumer2<PermissionGpsProvider, StationProvider>(
//         builder: (context, gps, station, _) {
//           // debugPrint('🔄station ${station.chargers}');
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

//           return Stack(
//             children: [
//               CustomMap(
//                 latLngMarkers: station.stations ?? [],
//                 userMarker: LatLng(position.latitude, position.longitude),
//               ),

//               // CONTROLLER DE POSICIÓN
//               Positioned(
//                 bottom: UtilSize.bottomPadding() + 80,
//                 right: 20,
//                 child: Column(
//                   children: <Widget>[
//                     CustomButtonCircle(
//                       icon: Icons.local_gas_station_sharp,
//                       background: primaryColor(),
//                       onTap: () async {
//                         // print('add new station');
//                         Navigator.pushNamed(context, RouteNames.pageStation);
//                       },
//                     ),
//                     SizedBox(height: 16),
//                     CustomButtonCircle(
//                       icon: Icons.my_location,
//                       background: primaryColor(),
//                       onTap: () async {
//                         final pos = await gps.getCurrentPosition();
//                         // print('📍 posición actual (botón): $pos');
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               if (station.isLoading)
//                 Blur(child: const Center(child: CircularProgressIndicator())),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
