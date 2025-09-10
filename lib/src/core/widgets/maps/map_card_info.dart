import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/blur/blur.dart';
import 'package:ecored_app/src/core/widgets/labels/label_icon_title.dart';
import 'package:ecored_app/src/core/widgets/labels/label_title.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MapCardInfomation extends StatelessWidget {
  final ModelStation stationData;
  final Function()? onClose;
  const MapCardInfomation({super.key, required this.stationData, this.onClose});

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
            color: Colors.black.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
                  (stationData.status == ConnectionStatus.AVAILABLE.name)
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
                    onTap: () => onClose?.call(),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey.withOpacity(0.15),
                      child: Icon(
                        CupertinoIcons.xmark,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              // Align(
              //   alignment: Alignment.topRight,
              //   child: InkWell(
              //     onTap: () => onClose?.call(),
              //     child: CircleAvatar(
              //       radius: 22,
              //       backgroundColor: Colors.grey.withOpacity(0.15),
              //       child: Icon(
              //         CupertinoIcons.xmark,
              //         color: Colors.grey,
              //         size: 20,
              //       ),
              //     ),
              //   ),
              // ),

              // 🔹 Nombre Estación
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.bolt_circle_fill,
                    color: Colors.greenAccent,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  LabelTitle(
                    title: stationData.name,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // 🔹 Dirección
              LabelIconTitle(
                icon: CupertinoIcons.location_solid,
                iconColor: Colors.grey.shade400,
                title: stationData.address,
                textColor: grayInputColor(),
              ),
              const SizedBox(height: 16),

              // 🔹 Acciones principales
              _actionButtons(),

              const Divider(color: Colors.white24, height: 32),

              // 🔹 Descripción
              LabelTitle(
                title: 'Descripción',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 6),
              Text(
                'ElectroGasolinera con múltiples conectores rápidos y seguros. Abierto las 24 horas.',
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
                children:
                    stationData.chargers.map((c) => _chargerChip(c)).toList(),
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

              //!opt 2
              LabelTitle(
                title: 'Precios por kWh',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              Column(
                children:
                    stationData.priceWithTipeConnector.entries.map((e) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          CupertinoIcons.bolt_fill,
                          color: Colors.amber,
                        ),
                        title: Text(
                          e.key,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          "\$${e.value.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Botones de acción
  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionItem(CupertinoIcons.map, 'Cómo llegar', Colors.blue, () {
          // Handle "Cómo llegar" tap
        }),
        _actionItem(CupertinoIcons.phone, 'Contactar', Colors.green, () {
          // Handle "Contactar" tap
        }),
        _actionItem(CupertinoIcons.heart, 'Favorito', Colors.red, () {
          // Handle "Favorito" tap
        }),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label, Color color, Function onTap) {
    return InkWell(
      onTap: onTap(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 22),
          ),
          Visibility(
            visible: label.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                label,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Tarjeta de conector
  Widget _chargerChip(Charger charger) {
    final isAvailable = charger.status == ConnectionStatus.AVAILABLE.name;
    return Container(
      padding: const EdgeInsets.all(12),
      width: 110,
      decoration: BoxDecoration(
        color:
            isAvailable
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? Colors.green : Colors.red,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            charger.typeConnection,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAvailable ? Colors.green : Colors.red,
            ),
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
              Text(
                '${charger.powerKw} kW',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            charger.typeCharger,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// import 'package:ecored_app/src/core/theme/theme_index.dart';
// import 'package:ecored_app/src/core/utils/utils_index.dart';
// import 'package:ecored_app/src/core/widgets/blur/blur.dart';
// import 'package:ecored_app/src/core/widgets/labels/label_icon_title.dart';
// import 'package:ecored_app/src/core/widgets/labels/label_title.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class MapCardInfomation extends StatelessWidget {
//   const MapCardInfomation({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final chargers = [
//       {
//         "_id": "68955d22fc2dedae08b1f855",
//         "typeConnection": "TYPE_1",
//         "powerKw": 22,
//         "status": "AVAILABLE",
//         "typeCharger": "DC",
//       },
//       {
//         "_id": "68955d29fc2dedae08b1f858",
//         "typeConnection": "TYPE_2",
//         "powerKw": 22,
//         "status": "AVAILABLE",
//         "typeCharger": "DC",
//       },
//       {
//         "_id": "68955d33fc2dedae08b1f85b",
//         "typeConnection": "TYPE_1",
//         "powerKw": 22,
//         "status": "AVAILABLE",
//         "typeCharger": "AC",
//       },
//     ];

//     final chargesWidget =
//         chargers.map((charger) {
//           return Column(
//             children: [
//               LabelTitle(
//                 title: 'Conector ${charger["typeConnection"]}',
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//               LabelIconTitle(
//                 icon: CupertinoIcons.bolt,
//                 iconColor: Colors.amber,
//                 title: '${charger["powerKw"]} kW',
//                 textColor: grayInputColor(),
//               ),
//               LabelIconTitle(
//                 icon:
//                     (charger["status"] == 'AVAILABLE')
//                         ? CupertinoIcons.check_mark
//                         : CupertinoIcons.xmark,
//                 iconColor:
//                     (charger["status"] == 'AVAILABLE')
//                         ? Colors.green
//                         : Colors.red,
//                 title:
//                     (charger["status"] == 'AVAILABLE')
//                         ? 'Disponible'
//                         : 'No disponible',
//                 textColor: grayInputColor(),
//               ),

//               LabelIconTitle(
//                 icon: CupertinoIcons.star_lefthalf_fill,
//                 iconColor: Colors.blue,
//                 title: '${charger["typeCharger"]}',
//                 textColor: grayInputColor(),
//               ),
//             ],
//           );
//         }).toList();

//     return Positioned(
//       bottom: 0,
//       left: 10,
//       right: 10, // 👈 agrega esto

//       child: Blur(
//         child: Container(
//           padding: EdgeInsets.only(
//             bottom: UtilSize.bottomPadding() + 50,
//             top: 20,
//             left: 10,
//             right: 10,
//           ),
//           color: Colors.black.withOpacity(0.8),
//           width: double.infinity,
//           height: 500,
//           child: ListView(
//             shrinkWrap: true,
//             children: [
//               LabelTitle(
//                 title: 'Gasolinera 1',
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),

//               LabelIconTitle(
//                 icon: CupertinoIcons.location_solid,
//                 iconColor: grayInputColor(),
//                 title: 'Av. Amazonas y Naciones Unidas',
//                 textColor: grayInputColor(),
//               ),

//               containAtions(),

//               LabelTitle(
//                 title: 'Descripción',
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),

//               Container(
//                 padding: EdgeInsets.all(10),
//                 child: Text(
//                   'Esta es una descripción de la gasolinera 1. Aquí se puede incluir información adicional sobre los servicios que ofrece, horarios, etc.',
//                   style: TextStyle(color: grayInputColor(), fontSize: 14),
//                 ),
//               ),

//               //ccconectores
//               // LabelTitle(
//               //   title: 'Conectores',
//               //   fontSize: 16,
//               //   fontWeight: FontWeight.bold,
//               // ),
//               ...chargesWidget,
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget containAtions() {
//     return Container(
//       width: double.infinity,
//       height: 60,
//       margin: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: greyColorWithTransparency(),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [Text('Como llegar '), Text('Contactar')],
//       ),
//     );
//   }
// }
