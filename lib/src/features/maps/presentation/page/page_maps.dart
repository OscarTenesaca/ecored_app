import 'dart:ui';

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
        // print('❌ GPS o permisos no listos');
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
          // debugPrint('🔄station ${station.chargers}');
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

              /// Buscador
              // const _TopSearch(),

              // const _TopHeader(),
              // CONTROLLER DE POSICIÓN
              // Positioned(
              //   bottom: UtilSize.bottomPadding() + 80,
              //   right: 20,
              //   child: Column(
              //     children: <Widget>[
              //       CustomButtonCircle(
              //         size: 54,
              //         icon: Icons.ev_station,
              //         background: primaryColor(),
              //         onTap: () async {
              //           // print('add new station');
              //           Navigator.pushNamed(context, RouteNames.pageStation);
              //         },
              //       ),

              //       SizedBox(height: 14),
              //       CustomButtonCircle(
              //         size: 54,
              //         icon: Icons.my_location,
              //         background: primaryColor(),
              //         onTap: () async {
              //           final pos = await gps.getCurrentPosition();
              //           print('📍 posición actual (botón): $pos');
              //         },
              //       ),
              //     ],
              //   ),
              // ),
              if (station.isLoading)
                Blur(child: const Center(child: CircularProgressIndicator())),
            ],
          );
        },
      ),
    );
  }
}

class _TopSearch extends StatelessWidget {
  const _TopSearch();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: primaryColor(),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor()),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),

                  Icon(Icons.search, color: Colors.white),

                  SizedBox(width: 12),

                  Text(
                    "Buscar estación",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(right: 6),
                    child: CustomButtonSquare(
                      size: 42,
                      icon: Icons.tune,
                      backgroundColor: accentColor().withValues(alpha: .15),
                      iconColor: accentColor(),
                      onTap: () {
                        // mostrar filtro
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const MapFiltersSheet(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MapFiltersSheet extends StatefulWidget {
  const MapFiltersSheet({super.key});

  @override
  State<MapFiltersSheet> createState() => _MapFiltersSheetState();
}

enum SearchType { station, charger }

class _MapFiltersSheetState extends State<MapFiltersSheet> {
  SearchType searchType = SearchType.station;

  double power = 22;

  bool onlyAvailable = true;
  bool showPrivate = false;

  final List<String> connectors = ["CCS", "CCS2", "Type 2", "CHAdeMO", "GB/T"];

  final Set<String> selectedConnectors = {"CCS2"};

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .82,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: primaryColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(30),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Text(
                "Filtros",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    searchType = SearchType.station;
                    power = 22;
                    onlyAvailable = true;
                    showPrivate = false;
                    selectedConnectors.clear();
                  });
                },
                child: Text(
                  "Restablecer",
                  style: TextStyle(color: accentColor()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Buscar por",
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),

          const SizedBox(height: 10),

          SegmentedButton<SearchType>(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return accentColor();
                }
                return Colors.transparent;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? Colors.black
                    : Colors.white;
              }),
            ),
            segments: const [
              ButtonSegment(
                value: SearchType.station,
                label: Text("Estación"),
                icon: Icon(Icons.ev_station),
              ),
              ButtonSegment(
                value: SearchType.charger,
                label: Text("Cargador"),
                icon: Icon(Icons.electric_bolt),
              ),
            ],
            selected: {searchType},
            onSelectionChanged: (value) {
              setState(() {
                searchType = value.first;
              });
            },
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              const Text(
                "Potencia mínima",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const Spacer(),
              Text(
                "${power.round()} kW",
                style: TextStyle(
                  color: accentColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          Slider(
            value: power,
            min: 3,
            max: 200,
            activeColor: accentColor(),
            inactiveColor: Colors.white12,
            onChanged: (value) {
              setState(() {
                power = value;
              });
            },
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Conectores",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                connectors.map((connector) {
                  final selected = selectedConnectors.contains(connector);

                  return FilterChip(
                    label: Text(connector),
                    selected: selected,
                    checkmarkColor: Colors.black,
                    selectedColor: accentColor(),
                    backgroundColor: Colors.white10,
                    labelStyle: TextStyle(
                      color: selected ? Colors.black : Colors.white,
                    ),
                    onSelected: (_) {
                      setState(() {
                        if (selected) {
                          selectedConnectors.remove(connector);
                        } else {
                          selectedConnectors.add(connector);
                        }
                      });
                    },
                  );
                }).toList(),
          ),

          const SizedBox(height: 24),

          SwitchListTile(
            title: const Text(
              "Solo disponibles",
              style: TextStyle(color: Colors.white),
            ),
            value: onlyAvailable,
            activeColor: accentColor(),
            onChanged: (value) {
              setState(() {
                onlyAvailable = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text(
              "Mostrar privadas",
              style: TextStyle(color: Colors.white),
            ),
            value: showPrivate,
            activeColor: accentColor(),
            onChanged: (value) {
              setState(() {
                showPrivate = value;
              });
            },
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: accentColor(),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  "searchType": searchType,
                  "power": power,
                  "onlyAvailable": onlyAvailable,
                  "showPrivate": showPrivate,
                  "connectors": selectedConnectors.toList(),
                });
              },
              child: const Text(
                "Aplicar filtros",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
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
