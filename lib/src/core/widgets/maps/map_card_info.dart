import 'package:ecored_app/src/core/adapter/adapter_launcher.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapCardInfomation extends StatefulWidget {
  final ModelStation stationData;
  final LatLng? userMarker;
  final Function()? onClose;

  const MapCardInfomation({
    super.key,
    required this.stationData,
    this.userMarker,
    this.onClose,
  });

  @override
  State<MapCardInfomation> createState() => _MapCardInfomationState();
}

class _MapCardInfomationState extends State<MapCardInfomation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<ModelCharger> chargerData = [];

  // Para el swipe manual
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadMarkers();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // empieza abajo (fuera de pantalla)
      end: Offset.zero, // termina en su lugar
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, // entrada suave
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5), // fade rápido al inicio
      ),
    );

    // Lanzar animación de entrada
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Cierra con animación de salida
  Future<void> _closeWithAnimation() async {
    await _controller.reverse();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          // Solo permite arrastrar hacia abajo
          if (details.delta.dy > 0) {
            setState(() {
              _dragOffset += details.delta.dy;
            });
          }
        },
        onVerticalDragEnd: (details) {
          // Si arrastra más de 120px o con velocidad suficiente → cierra
          if (_dragOffset > 120 || (details.primaryVelocity ?? 0) > 500) {
            _closeWithAnimation();
          } else {
            // Regresa a su lugar con spring
            setState(() => _dragOffset = 0);
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.translate(
              // permite el drag visual en tiempo real
              offset: Offset(0, _dragOffset),
              child: Blur(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor(),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(50),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      height: 700,
                      child: ListView(
                        padding: const EdgeInsets.only(top: 16, bottom: 80),
                        shrinkWrap: true,
                        children: [
                          // 👇 indicador de swipe
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // tu contenido igual que antes...
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelTitle(
                                title: widget.stationData.name,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              (widget.stationData.status ==
                                      ConnectionStatus.AVAILABLE.name)
                                  ? Blur(
                                    blurColor: accentColor(),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      child: LabelTitle(
                                        title: 'Disponible',
                                        textColor: accentColor(),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                  : Blur(
                                    blurColor: errorColor(),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: LabelTitle(
                                        title: 'No Disponible',
                                        textColor: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            ],
                          ),

                          SizedBox(height: 15),
                          CustomAssetImg(
                            imagePath: AssetPaths.charge_station,
                            height: 200,
                            borderRadius: 30,
                            borderColor: accentColor(),
                            borderWidth: 3,
                          ),

                          SizedBox(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomButtonCircle(
                                size: 60,
                                iconSize: 65,
                                asset: AssetPaths.iconPin,
                                background: deepForestGreen(),

                                onTap:
                                    () =>
                                        AdapterLauncher().launchMapsDirections(
                                          latOrigin:
                                              '${widget.userMarker!.latitude}',
                                          lngOrigin:
                                              '${widget.userMarker!.longitude}',
                                          latDestination:
                                              '${widget.stationData.lat}',
                                          lngDestination:
                                              '${widget.stationData.lng}',
                                        ),
                              ),
                              CustomButtonCircle(
                                size: 60,
                                iconSize: 0.65,
                                asset: AssetPaths.iconWhatsApp,
                                background: deepForestGreen(),

                                onTap:
                                    () => AdapterLauncher().launchPhone(
                                      widget.stationData.prefixCode +
                                          widget.stationData.phone,
                                    ),
                              ),
                              CustomButtonCircle(
                                size: 60,
                                iconSize: 65,
                                asset: AssetPaths.iconPhone,
                                background: deepForestGreen(),
                                onTap:
                                    () => AdapterLauncher().launchWhatsApp(
                                      widget.stationData.prefixCode +
                                          widget.stationData.phone,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          LabelTitle(
                            title: 'Descripción',
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                          const SizedBox(height: 12),
                          // LabelTitle(title: ''),
                          Text(
                            widget.stationData.description,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.6,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LabelTitle(
                            title: 'Conectores disponibles',
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),

                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                chargerData
                                    .map((c) => _connectorCard(c))
                                    .toList(),
                          ),
                        ],
                      ),
                    ),

                    // X flotante
                    Positioned(
                      top: 20,
                      right: 20,
                      child: GestureDetector(
                        onTap: _closeWithAnimation,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white12,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _connectorCard(ModelCharger charger) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: deepForestGreen(),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: deepForestGreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CustomButtonSquare(
              asset: AssetPaths.iconTypeC,
              size: 80,
              sizeAsset: 0.80,
              // backgroundColor: Colors.red,
            ),
          ),

          LabelTitle(
            padding: false,
            title: charger.typeConnection,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            textColor: whiteColor(),
            alignment: Alignment.center,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              LabelTitle(
                title: '${charger.powerKw} kW',
                fontSize: 12,
                textColor: whiteColor(),
              ),
              LabelTitle(
                title: charger.typeCharger,
                fontSize: 12,
                textColor: whiteColor(),
              ),
            ],
          ),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: accentColor(),
            ),
            child: LabelTitle(
              alignment: Alignment.topCenter,
              title: "\$0.66 / kWh",
              textColor: primaryColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadMarkers() async {
    final provider = context.read<StationProvider>();
    await provider.findAllChargers({'station': widget.stationData.id});
    chargerData = provider.chargers!;
    print('*************Cargadores encontrados: ${chargerData.length}');
  }
}

// import 'package:ecored_app/src/core/adapter/adapter_launcher.dart';
// import 'package:ecored_app/src/core/theme/theme_index.dart';
// import 'package:ecored_app/src/core/utils/utils_index.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
// import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
// import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:latlong2/latlong.dart';

// import 'package:provider/provider.dart';

// class MapCardInfomation extends StatefulWidget {
//   final ModelStation stationData;
//   final LatLng? userMarker;
//   final Function()? onClose;

//   const MapCardInfomation({
//     super.key,
//     required this.stationData,
//     this.userMarker,
//     this.onClose,
//   });

//   @override
//   State<MapCardInfomation> createState() => _MapCardInfomationState();
// }

// class _MapCardInfomationState extends State<MapCardInfomation> {
//   List<ModelCharger> chargerData = [];

//   @override
//   void initState() {
//     debugPrint(
//       '🔄 Cargando cargadores para estación ${widget.stationData.name}...',
//     );
//     _loadMarkers();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Blur(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             // color: Colors.black.withValues(alpha: 0.8),
//             color: primaryColor(),
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           height: 700,
//           child: ListView(
//             // padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
//             padding: EdgeInsets.only(top: 16, bottom: 80, left: 0, right: 0),
//             shrinkWrap: true,
//             children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     LabelTitle(
              //       title: widget.stationData.name,
              //       fontSize: 25,
              //       fontWeight: FontWeight.bold,
              //     ),

              //     (widget.stationData.status == ConnectionStatus.AVAILABLE.name)
              //         ? Blur(
              //           blurColor: accentColor(),
              //           borderRadius: BorderRadius.circular(20),
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(
              //               horizontal: 8,
              //               vertical: 2,
              //             ),
              //             child: LabelTitle(
              //               title: 'Disponible',
              //               textColor: accentColor(),
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         )
              //         : Blur(
              //           blurColor: errorColor(),
              //           borderRadius: BorderRadius.circular(20),
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(
              //               horizontal: 4,
              //               vertical: 2,
              //             ),
              //             child: LabelTitle(
              //               title: 'No Disponible',
              //               textColor: Colors.red,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ),
              //   ],
              // ),
              // SizedBox(height: 15),
              // CustomAssetImg(
              //   imagePath: AssetPaths.charge_station,
              //   height: 200,
              //   borderRadius: 30,
              //   borderColor: accentColor(),
              //   borderWidth: 3,
              // ),

              // SizedBox(height: 30),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     CustomButtonCircle(
              //       size: 60,
              //       iconSize: 65,
              //       asset: AssetPaths.iconPin,
              //       // background: flatGreen().withValues(alpha: 0.3),
              //       background: refreshingMint().withValues(alpha: 0.15),
              //       onTap:
              //           () => AdapterLauncher().launchMapsDirections(
              //             latOrigin: '${widget.userMarker!.latitude}',
              //             lngOrigin: '${widget.userMarker!.longitude}',
              //             latDestination: '${widget.stationData.lat}',
              //             lngDestination: '${widget.stationData.lng}',
              //           ),
              //     ),
              //     CustomButtonCircle(
              //       size: 60,
              //       iconSize: 65,
              //       asset: AssetPaths.iconCellphone,
              //       background: refreshingMint().withValues(alpha: 0.15),

              //       onTap:
              //           () => AdapterLauncher().launchPhone(
              //             widget.stationData.prefixCode +
              //                 widget.stationData.phone,
              //           ),
              //     ),
              //     CustomButtonCircle(
              //       size: 60,
              //       iconSize: 65,
              //       asset: AssetPaths.iconPhone,
              //       background: refreshingMint().withValues(alpha: 0.15),
              //       onTap:
              //           () => AdapterLauncher().launchWhatsApp(
              //             widget.stationData.prefixCode +
              //                 widget.stationData.phone,
              //           ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 24),
              // LabelTitle(
              //   title: 'Descripción',
              //   fontWeight: FontWeight.bold,
              //   fontSize: 25,
              // ),
              // const SizedBox(height: 12),
              // // LabelTitle(title: ''),
              // Text(
              //   widget.stationData.description,
              //   textAlign: TextAlign.justify,
              //   style: TextStyle(
              //     color: Colors.white70,
              //     height: 1.6,
              //     fontSize: 15,
              //   ),
              // ),
              // const SizedBox(height: 12),
              // LabelTitle(
              //   title: 'Conectores disponibles',
              //   fontWeight: FontWeight.bold,
              //   fontSize: 25,
              // ),

              // Wrap(
              //   spacing: 12,
              //   runSpacing: 12,
              //   children: chargerData.map((c) => _connectorCard(c)).toList(),
              // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _connectorCard(ModelCharger charger) {
//     return Container(
//       width: 150,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: const Color(0xff1B1B1B),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: Colors.white10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: CustomButtonSquare(
//               asset: AssetPaths.iconTypeC,
//               size: 80,
//               sizeAsset: 0.80,
//               // backgroundColor: Colors.red,
//             ),
//           ),

//           LabelTitle(
//             padding: false,
//             title: charger.typeConnection,
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             textColor: whiteColor(),
//             alignment: Alignment.center,
//           ),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               LabelTitle(
//                 title: '${charger.powerKw} kW',
//                 fontSize: 12,
//                 textColor: whiteColor(),
//               ),
//               LabelTitle(
//                 title: charger.typeCharger,
//                 fontSize: 12,
//                 textColor: whiteColor(),
//               ),
//             ],
//           ),

//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(30),
//               color: accentColor(),
//             ),
//             child: LabelTitle(
//               alignment: Alignment.topCenter,
//               title: "\$0.66 / kWh",
//               textColor: primaryColor(),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _loadMarkers() async {
//     final provider = context.read<StationProvider>();
//     await provider.findAllChargers({'station': widget.stationData.id});
//     chargerData = provider.chargers!;
//     print('*************Cargadores encontrados: ${chargerData.length}');
//   }
// }
