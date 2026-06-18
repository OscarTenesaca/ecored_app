import 'dart:async';
import 'dart:math';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/charger/presentation/provider/charger_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';

class PageCharger extends StatefulWidget {
  const PageCharger({super.key});

  @override
  State<PageCharger> createState() => _PageChargerState();
}

class _PageChargerState extends State<PageCharger>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  final ValueNotifier<bool> isChargingNotifier = ValueNotifier(true);
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startPolling();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    isChargingNotifier.dispose();
    stopPolling();
    super.dispose();
  }

  // void toggleCharging() {
  //   isChargingNotifier.value = !isChargingNotifier.value;

  //   if (isChargingNotifier.value) {
  //     _rotationController.repeat();
  //   } else {
  //     _rotationController.stop();
  //   }
  // }

  void toggleCharging(ModelOrder order) async {
    isChargingNotifier.value = !isChargingNotifier.value;

    final provider = context.read<ChargerProvider>();
    final stopData = await provider.deleteStopCharger({
      "cpId": order.charger.code,
      "transactionId": order.ocppTransactionId,
    });

    if (stopData == 200) {
      // popup: se detuvo correctamente
    } else {
      // error
    }
  }

  double batteryLevel(ModelOrder order) {
    if (order.batteryCapacityKwh == 0) return 0;
    return order.kWhDelivered / order.batteryCapacityKwh;
  }

  String formattedDuration(ModelOrder order) {
    // Ajusta el parse si tu fecha no es ISO
    final format = DateFormat("dd/MM/yyyy HH:mm:ss");
    final startedAt = format.parse(order.createdAt);
    final duration = DateTime.now().difference(startedAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: "\$", decimalDigits: 2);
    final provider = context.watch<ChargerProvider>();
    final order = provider.orderData;

    if (order == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isChargingNotifier,
      builder: (context, isCharging, _) {
        final level = batteryLevel(order);
        final duration = formattedDuration(order);

        return Scaffold(
          backgroundColor: primaryColor(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const LabelTitle(
                        title: "Charging Session",
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isCharging
                                  ? accentColor().withValues(alpha: 0.10)
                                  : errorColor().withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color:
                                isCharging
                                    ? accentColor().withValues(alpha: 0.25)
                                    : errorColor().withValues(alpha: 0.25),
                          ),
                        ),
                        child: LabelIconTitle(
                          icon: isCharging ? Icons.bolt : Icons.pause,
                          iconColor: isCharging ? accentColor() : errorColor(),
                          title: isCharging ? "Cargando" : "Pausado",
                          textColor: isCharging ? accentColor() : errorColor(),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// MAIN RING
                  SizedBox(
                    width: 230,
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    isCharging
                                        ? accentColor().withValues(alpha: 0.18)
                                        : errorColor().withValues(alpha: 0.12),
                                blurRadius: 35,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        if (isCharging)
                          AnimatedBuilder(
                            animation: _rotationController,
                            builder: (_, child) {
                              return Transform.rotate(
                                angle: _rotationController.value * 2 * pi,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    accentColor().withValues(alpha: 0.0),
                                    accentColor().withValues(alpha: 0.8),
                                    accentColor().withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        Container(
                          width: 165,
                          height: 165,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white12),
                          ),
                        ),

                        SizedBox(
                          width: 165,
                          height: 165,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: level),
                            duration: const Duration(seconds: 2),
                            builder: (_, value, __) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 8,
                                backgroundColor: Colors.white10,
                                valueColor: AlwaysStoppedAnimation(
                                  isCharging ? accentColor() : errorColor(),
                                ),
                              );
                            },
                          ),
                        ),

                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A1D25), Color(0xFF111318)],
                            ),
                          ),
                        ),

                        // CENTER TEXT
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: isCharging ? accentColor() : errorColor(),
                              size: 26,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${(level * 100).toInt()}%",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color:
                                    isCharging ? accentColor() : errorColor(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${order.kWhDelivered.toStringAsFixed(1)} kWh",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: whiteColor(),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isCharging ? "Charging..." : "Paused",
                              style: TextStyle(
                                fontSize: 11,
                                color: whiteColor().withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// INFO GRID
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.bolt,
                          title: "${order.kWhDelivered.toStringAsFixed(1)} kWh",
                          subtitle: "Energy Delivered",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.attach_money,
                          title: currency.format(order.total),
                          subtitle: "Current Total",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.schedule,
                          title: duration,
                          subtitle: "Charging Time",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.local_gas_station,
                          title: "${currency.format(order.pricePerKwh)}/kWh",
                          subtitle: "Energy Price",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// BILLING
                  _buildSectionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Billing Summary",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LabelRowText(
                          label: 'Energia',
                          value: currency.format(order.subtotal),
                          fontSize: 14,
                        ),
                        LabelRowText(
                          label: 'IVA',
                          value: currency.format(order.tax),
                          fontSize: 14,
                        ),
                        const Divider(color: Colors.white12, height: 28),
                        LabelRowText(
                          label: 'Total',
                          value: currency.format(order.total),
                          fontSize: 16,
                          fontSizeValue: 22,
                          subtitleColor: accentColor(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// SESSION INFO
                  _buildSectionContainer(
                    child: Column(
                      children: [
                        LabelRowText(
                          label: "Transacción",
                          value: "#${order.ocppTransactionId}",
                          fontSize: 13,
                        ),
                        const SizedBox(height: 10),
                        LabelRowText(
                          label: "Connector",
                          value: "Connector ${order.connectorId}",
                          fontSize: 13,
                        ),
                        const SizedBox(height: 10),
                        LabelRowText(
                          label: "Platform",
                          value: order.platformBuy,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// BUTTON
                  CustomButtonAnimated(
                    isChargingNotifier: isChargingNotifier,
                    titleA: 'Detener Carga',
                    backgroundColorA: const Color(0xFF2A1616),
                    textColorA: Colors.redAccent,
                    shadowColorA: errorColor().withValues(alpha: 0.20),
                    borderColorA: errorColor().withValues(alpha: 0.4),

                    titleB: 'Reanudar Carga',
                    backgroundColorB: accentColor(),
                    textColorB: primaryColor(),
                    shadowColorB: accentColor().withValues(alpha: 0.25),
                    borderColorB: accentColor().withValues(alpha: 0.5),

                    onPressed: () => toggleCharging(order),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF181B22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor().withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181B22),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor(), size: 18),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: whiteColor().withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  void startPolling() {
    final provider = context.read<ChargerProvider>();

    // Primera carga inmediata
    provider.getOrderData({'status': "PENDING", "operationStatus": "CHARGING"});

    // Luego cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await provider.getOrderData({
        'status': "PENDING",
        "operationStatus": "CHARGING",
      });
    });
  }

  void stopPolling() => _timer?.cancel();
}

// import 'dart:async';
// import 'dart:math';
// import 'package:ecored_app/src/core/theme/theme_index.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:ecored_app/src/features/charger/presentation/provider/charger_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class PageCharger extends StatefulWidget {
//   const PageCharger({super.key});

//   @override
//   State<PageCharger> createState() => _PageChargerState();
// }

// class _PageChargerState extends State<PageCharger>
//     with SingleTickerProviderStateMixin {
//   Timer? _timer; //after remove for socket

//   final ValueNotifier<bool> isChargingNotifier = ValueNotifier(true);

//   late AnimationController _rotationController;

//   final double pricePerKwh = 0.28;
//   final double tax = 2.57;
//   final double subtotal = 17.17;
//   final double total = 19.75;

//   final double kwhDelivered = 61.341;
//   final double batteryCapacity = 100;

//   final DateTime startedAt = DateTime.now().subtract(
//     const Duration(hours: 2, minutes: 14),
//   );

//   final int ocppTransactionId = 1778779048;

//   double get batteryLevel => kwhDelivered / batteryCapacity;

//   String get formattedDuration {
//     final duration = DateTime.now().difference(startedAt);
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes % 60;
//     return "${hours}h ${minutes}m";
//   }

//   @override
//   void initState() {
//     super.initState();
//     startPolling();
//     _rotationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 6),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _rotationController.dispose();
//     isChargingNotifier.dispose();
//     super.dispose();
//   }

//   void toggleCharging() {
//     isChargingNotifier.value = !isChargingNotifier.value;

//     if (isChargingNotifier.value) {
//       _rotationController.repeat();
//     } else {
//       _rotationController.stop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currency = NumberFormat.currency(symbol: "\$", decimalDigits: 2);
//     final provider = context.watch<ChargerProvider>();
//     final order = provider.orderData;

//     if (order == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return ValueListenableBuilder<bool>(
//       valueListenable: isChargingNotifier,
//       builder: (context, isCharging, _) {
//         return Scaffold(
//           backgroundColor: primaryColor(),
//           body: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(18),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 10),

//                   /// HEADER
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const LabelTitle(
//                         title: "Charging Session",
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color:
//                               isCharging
//                                   ? accentColor().withValues(alpha: 0.10)
//                                   : errorColor().withValues(alpha: 0.10),
//                           borderRadius: BorderRadius.circular(30),
//                           border: Border.all(
//                             color:
//                                 isCharging
//                                     ? accentColor().withValues(alpha: 0.25)
//                                     : errorColor().withValues(alpha: 0.25),
//                           ),
//                         ),
//                         child: LabelIconTitle(
//                           icon: isCharging ? Icons.bolt : Icons.pause,
//                           iconColor: isCharging ? accentColor() : errorColor(),
//                           title: isCharging ? "Cargando" : "Pausado",
//                           textColor: isCharging ? accentColor() : errorColor(),
//                           fontWeight: FontWeight.w600,
//                           fontSize: 11,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 18),

//                   /// 🔵 MAIN RING
//                   SizedBox(
//                     width: 230,
//                     height: 230,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         AnimatedContainer(
//                           duration: const Duration(milliseconds: 600),
//                           width: 170,
//                           height: 170,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color:
//                                     isCharging
//                                         ? accentColor().withValues(alpha: 0.18)
//                                         : errorColor().withValues(alpha: 0.12),
//                                 blurRadius: 35,
//                                 spreadRadius: 4,
//                               ),
//                             ],
//                           ),
//                         ),

//                         if (isCharging)
//                           AnimatedBuilder(
//                             animation: _rotationController,
//                             builder: (_, child) {
//                               return Transform.rotate(
//                                 angle: _rotationController.value * 2 * pi,
//                                 child: child,
//                               );
//                             },
//                             child: Container(
//                               width: 190,
//                               height: 190,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: SweepGradient(
//                                   colors: [
//                                     accentColor().withValues(alpha: 0.0),
//                                     accentColor().withValues(alpha: 0.8),
//                                     accentColor().withValues(alpha: 0.0),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),

//                         Container(
//                           width: 165,
//                           height: 165,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white12),
//                           ),
//                         ),

//                         SizedBox(
//                           width: 165,
//                           height: 165,
//                           child: TweenAnimationBuilder<double>(
//                             tween: Tween(begin: 0, end: batteryLevel),
//                             duration: const Duration(seconds: 2),
//                             builder: (_, value, __) {
//                               return CircularProgressIndicator(
//                                 value: value,
//                                 strokeWidth: 8,
//                                 backgroundColor: Colors.white10,
//                                 valueColor: AlwaysStoppedAnimation(
//                                   isCharging ? accentColor() : errorColor(),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),

//                         Container(
//                           width: 140,
//                           height: 140,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF1A1D25), Color(0xFF111318)],
//                             ),
//                           ),
//                         ),

//                         /// CENTER TEXT
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.bolt_rounded,
//                               color: isCharging ? accentColor() : errorColor(),
//                               size: 26,
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               "${(batteryLevel * 100).toInt()}%",
//                               style: TextStyle(
//                                 fontSize: 34,
//                                 fontWeight: FontWeight.bold,
//                                 color:
//                                     isCharging ? accentColor() : errorColor(),
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               "${kwhDelivered.toStringAsFixed(1)} kWh",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: whiteColor(),
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               isCharging ? "Charging..." : "Paused",
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: whiteColor().withValues(alpha: 0.55),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   /// INFO GRID
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildInfoCard(
//                           icon: Icons.bolt,
//                           title: "${kwhDelivered.toStringAsFixed(1)} kWh",
//                           subtitle: "Energy Delivered",
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: _buildInfoCard(
//                           icon: Icons.attach_money,
//                           title: currency.format(total),
//                           subtitle: "Current Total",
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 16),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildInfoCard(
//                           icon: Icons.schedule,
//                           title: formattedDuration,
//                           subtitle: "Charging Time",
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: _buildInfoCard(
//                           icon: Icons.local_gas_station,
//                           title: "${currency.format(pricePerKwh)}/kWh",
//                           subtitle: "Energy Price",
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 24),

//                   /// BILLING
//                   _buildSectionContainer(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Billing Summary",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         LabelRowText(
//                           label: 'Energia',
//                           value: currency.format(subtotal),
//                           fontSize: 14,
//                         ),
//                         LabelRowText(
//                           label: 'IVA',
//                           value: currency.format(tax),
//                           fontSize: 14,
//                         ),

//                         const Divider(color: Colors.white12, height: 28),

//                         LabelRowText(
//                           label: 'Total',
//                           value: currency.format(total),
//                           fontSize: 16,
//                           fontSizeValue: 22,
//                           subtitleColor: accentColor(),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 18),

//                   /// SESSION
//                   _buildSectionContainer(
//                     child: Column(
//                       children: [
//                         LabelRowText(
//                           label: "Transacción",
//                           value: "#$ocppTransactionId",
//                           fontSize: 13,
//                         ),
//                         const SizedBox(height: 10),
//                         LabelRowText(
//                           label: "Connector",
//                           value: "Connector 1",
//                           fontSize: 13,
//                         ),
//                         const SizedBox(height: 10),
//                         LabelRowText(
//                           label: "Platform",
//                           value: "APP",
//                           fontSize: 13,
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 22),

//                   /// BUTTON
//                   /// BUTTON
//                   CustomButtonAnimated(
//                     isChargingNotifier: isChargingNotifier,
//                     titleA: 'Detener Carga',
//                     backgroundColorA: const Color(0xFF2A1616),
//                     textColorA: Colors.redAccent,
//                     shadowColorA: errorColor().withValues(alpha: 0.20),
//                     borderColorA: errorColor().withValues(alpha: 0.4),

//                     titleB: 'Reanudar Carga',
//                     backgroundColorB: accentColor(),
//                     textColorB: primaryColor(),
//                     shadowColorB: accentColor().withValues(alpha: 0.25),
//                     borderColorB: accentColor().withValues(alpha: 0.5),

//                     onPressed: toggleCharging,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSectionContainer({required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         color: const Color(0xFF181B22),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: accentColor().withValues(alpha: 0.08)),
//       ),
//       child: child,
//     );
//   }

//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF181B22),
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: accentColor(), size: 18),
//           const SizedBox(height: 10),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             subtitle,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 11,
//               color: whiteColor().withValues(alpha: 0.55),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Charger

//   void startPolling() async {
//     _timer = Timer.periodic(Duration(seconds: 5), (_) async {
//       print('llega*******');
//       final provider = context.read<ChargerProvider>(); // ✅ usa read aquí
//       await provider.getOrderData({
//         'status': "PENDING",
//         "operationStatus": "CHARGING",
//       });
//     });
//   }

//   void stopPolling() => _timer?.cancel();
// }
