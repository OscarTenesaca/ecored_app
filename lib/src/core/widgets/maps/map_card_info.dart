import 'package:ecored_app/src/core/adapter/adapter_launcher.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/blur/blur.dart';
import 'package:ecored_app/src/core/widgets/buttons/custom_button_circle.dart';
import 'package:ecored_app/src/core/widgets/labels/label_icon_title.dart';
import 'package:ecored_app/src/core/widgets/labels/label_title.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';

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

class _MapCardInfomationState extends State<MapCardInfomation> {
  List<ModelCharger> chargerData = [];

  @override
  void initState() {
    _loadMarkers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 10,
      right: 10,
      child: Blur(
        child: Container(
          padding: EdgeInsets.only(
            bottom: UtilSize.bottomPadding() + 16,
            top: 0,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 10),
                  (widget.stationData.status == ConnectionStatus.AVAILABLE.name)
                      ? Blur(
                        blurColor: Colors.green,
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
                        blurColor: Colors.red,
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

                  InkWell(
                    onTap: () => widget.onClose?.call(),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      child: Icon(
                        CupertinoIcons.xmark,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              // 🔹 Nombre Estación
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.bolt_circle_fill,
                    color: Colors.greenAccent,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  LabelTitle(
                    title: widget.stationData.name,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 🔹 Dirección
              LabelIconTitle(
                icon: CupertinoIcons.location_solid,
                iconColor: Colors.grey.shade400,
                title: widget.stationData.address,
                textColor: grayInputColor(),
              ),
              const SizedBox(height: 16),

              // 🔹 Acciones principales
              _actionButtons(context),

              const Divider(color: Colors.white24, height: 32),

              // 🔹 Descripción
              LabelTitle(
                title: 'Descripción',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),

              const SizedBox(height: 6),

              Text(
                widget.stationData.description,
                style: TextStyle(color: grayInputColor(), fontSize: 14),
              ),

              const Divider(color: Colors.white24, height: 32),

              // 🔹 Conectores
              LabelTitle(
                title: 'Conectores disponibles',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: chargerData.map((c) => _chargerChip(c)).toList(),
              ),

              // LabelTitle(
              //   title: 'Precios por kWh',
              //   fontSize: 16,
              //   fontWeight: FontWeight.bold,
              // ),
              // const SizedBox(height: 10),
              // GridView.builder(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   itemCount: priceWithTipeConnector.length,
              //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: 2,
              //     childAspectRatio: 3.5,
              //     crossAxisSpacing: 10,
              //     mainAxisSpacing: 10,
              //   ),
              //   itemBuilder: (context, index) {
              //     final key = priceWithTipeConnector.keys.elementAt(index);
              //     final value = priceWithTipeConnector[key]!;
              //     return Container(
              //       padding: const EdgeInsets.symmetric(
              //         vertical: 6,
              //         horizontal: 10,
              //       ),
              //       decoration: BoxDecoration(
              //         color: Colors.white.withOpacity(0.08),
              //         borderRadius: BorderRadius.circular(12),
              //         border: Border.all(color: Colors.white24, width: 1),
              //       ),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             key,
              //             style: const TextStyle(
              //               fontWeight: FontWeight.w600,
              //               color: Colors.white,
              //             ),
              //           ),
              //           Text(
              //             "\$${value.toStringAsFixed(2)}",
              //             style: const TextStyle(color: Colors.greenAccent),
              //           ),
              //         ],
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Botones de acción
  Widget _actionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomButtonCircle(
          icon: CupertinoIcons.location_solid,
          color: Colors.blueAccent,
          onPressed: () {
            AdapterLauncher().launchMapsDirections(
              latOrigin: '${widget.userMarker!.latitude}',
              lngOrigin: '${widget.userMarker!.longitude}',
              latDestination: '${widget.stationData.lat}',
              lngDestination: '${widget.stationData.lng}',
            );
          },
        ),

        CustomButtonCircle(
          icon: CupertinoIcons.phone_fill,
          color: Colors.cyan,
          onPressed: () {
            AdapterLauncher().launchPhone(
              widget.stationData.prefixCode + widget.stationData.phone,
            );
          },
        ),

        CustomButtonCircle(
          icon: CupertinoIcons.device_phone_portrait,
          color: Colors.greenAccent,
          onPressed: () {
            AdapterLauncher().launchWhatsApp(
              widget.stationData.prefixCode + widget.stationData.phone,
            );
          },
        ),
      ],
    );
  }

  /// 🔹 Tarjeta de conector
  ///
  Widget _chargerChip(ModelCharger charger) {
    final bool isAvailable = charger.status == ConnectionStatus.AVAILABLE.name;
    final Color statusColor =
        isAvailable ? Colors.greenAccent : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(12),
      width: 130,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.8),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelTitle(
            padding: false,
            title: charger.typeConnection,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            textColor: isAvailable ? Colors.green : Colors.red,
            alignment: Alignment.center,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                CupertinoIcons.bolt_fill,
                size: 14,
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
              LabelTitle(
                title: '${charger.powerKw} kW',
                fontSize: 12,
                textColor: whiteColor(),
              ),
              const SizedBox(width: 15),
              LabelTitle(
                title: charger.typeCharger,
                fontSize: 12,
                textColor: whiteColor(),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Card(
            color: statusColor.withValues(alpha: 0.15),
            child: LabelTitle(
              title:
                  '\$${charger.priceWithTipeConnector.toStringAsFixed(2)} / kWh',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              textColor: whiteColor(),
              alignment: Alignment.center,
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
  }
}
