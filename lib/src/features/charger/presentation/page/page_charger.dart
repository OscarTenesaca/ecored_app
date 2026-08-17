import 'dart:math';

import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/charger/presentation/provider/charger_provider.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PageCharger extends StatefulWidget {
  const PageCharger({super.key});

  @override
  State<PageCharger> createState() => _PageChargerState();
}

// Estados terminales de OperationStatus (ver también charger_provider.dart):
// al llegar cualquiera de estos, la sesión de carga ya no está activa.
const List<String> _terminalOperationStatuses = [
  'FINISHED',
  'FAILED',
  'CANCELLED',
];

class _PageChargerState extends State<PageCharger>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> isChargingNotifier = ValueNotifier(true);
  late AnimationController _rotationController;

  // Evita programar la salida más de una vez si llegan varias
  // actualizaciones con estado terminal seguidas.
  bool _exitScheduled = false;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChargerProvider>();
      // Ya hay una orden activa (page_opt_charger.dart la cargó antes de
      // mostrar esta pantalla): conecta el socket para recibir su
      // progreso en tiempo real. Si ya estaba conectado, no hace nada.
      provider.connectChargeSocket();
      // Refleja en el botón/anillo el estado real que reporta el
      // servidor (además del flujo manual de "Detener Carga").
      provider.addListener(_syncChargingStateFromOrder);
      _syncChargingStateFromOrder();
    });
  }

  @override
  void dispose() {
    context.read<ChargerProvider>().removeListener(_syncChargingStateFromOrder);
    // Se sale de la pantalla de carga: cierra el socket y quita sus
    // listeners para no dejar fugas de memoria ni seguir recibiendo
    // eventos que ya nadie va a mostrar.
    context.read<ChargerProvider>().disconnectChargeSocket();
    _rotationController.dispose();
    isChargingNotifier.dispose();
    super.dispose();
  }

  void _syncChargingStateFromOrder() {
    final provider = context.read<ChargerProvider>();
    final order = provider.orderData;
    if (order == null) return;

    final bool isTerminal = _terminalOperationStatuses.contains(
      order.operationStatus,
    );
    final bool stillCharging = !isTerminal;

    if (isChargingNotifier.value != stillCharging) {
      isChargingNotifier.value = stillCharging;
    }

    // El backend confirmó que la sesión realmente terminó (no la mera
    // aceptación del RemoteStop, sino el operationStatus final que llega
    // por socket tras el StopTransaction). Se espera un margen de
    // cortesía en la UI y luego se limpia la orden: PageOptCharger
    // reacciona solo y vuelve a mostrar PageScanQr.
    if (isTerminal && !_exitScheduled) {
      _exitScheduled = true;
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        context.read<ChargerProvider>().clearOrderData();
      });
    }
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
    // El backend no expone un endpoint para reanudar una carga detenida,
    // solo para detenerla (DELETE /orders/stop) o crear una orden nueva
    // (POST /orders). Por eso este botón solo actúa mientras se está
    // cargando; una vez detenida queda deshabilitado (ver onPressed en build()).
    if (!isChargingNotifier.value) return;

    final provider = context.read<ChargerProvider>();
    final stopData = await provider.deleteStopCharger({
      "cpId": order.charger.code,
      "transactionId": order.ocppTransactionId,
    });

    if (stopData == 200) {
      isChargingNotifier.value = false;

      // El 200 solo confirma que el backend envió el RemoteStop al
      // cargador, no que la sesión ya terminó realmente (el backend
      // recién marca la orden STOPPING y espera el StopTransaction; si
      // nunca llega, su propia reconciliación la fuerza a FINISHED en
      // segundo plano, hasta ~90s después). Esperar esa confirmación en
      // pantalla dejaba al usuario "atascado" viendo la sesión en pausa.
      // Por eso, al pedir detener, se sale de inmediato a PageScanQr:
      // primero se desconecta el socket (con el id de la orden todavía
      // disponible) y luego se limpia la orden para que PageOptCharger
      // vuelva a mostrar el escáner.
      if (!mounted) return;
      final provider = context.read<ChargerProvider>();
      provider.disconnectChargeSocket();
      provider.clearOrderData();
    } else {
      // La carga no se detuvo en el backend: no se cambia el estado local.
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

  /// Estimado a partir de la potencia actual reportada por el socket.
  /// Devuelve null si no hay suficiente información para calcularlo
  /// (potencia en 0 o batería ya llena) — no se muestra en ese caso.
  String? remainingTime(ModelOrder order) {
    if (order.currentPowerKw <= 0 || order.batteryCapacityKwh <= 0) {
      return null;
    }

    final remainingKwh = order.batteryCapacityKwh - order.kWhDelivered;
    if (remainingKwh <= 0) return null;

    final totalMinutes = (remainingKwh / order.currentPowerKw * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
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

                            // Text( remove
                            //   "${(level * 100).toInt()}%",
                            //   style: TextStyle(
                            //     fontSize: 34,
                            //     fontWeight: FontWeight.bold,
                            //     color:
                            //         isCharging ? accentColor() : errorColor(),
                            //   ),
                            // ),
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

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.flash_on,
                          title:
                              "${order.currentPowerKw.toStringAsFixed(1)} kW",
                          subtitle: "Potencia actual",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.hourglass_bottom,
                          title: remainingTime(order) ?? "--",
                          subtitle: "Tiempo restante",
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

                  if (_hasTelemetry(order)) ...[
                    const SizedBox(height: 18),

                    /// TELEMETRÍA (voltaje/corriente/temperatura/etc. del
                    /// cargador — solo se muestra lo que el cargador
                    /// efectivamente reporta por MeterValues).
                    _buildSectionContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Telemetría",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._telemetryRows(order),
                        ],
                      ),
                    ),
                  ],

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

                    onPressed: isCharging ? () => toggleCharging(order) : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _hasTelemetry(ModelOrder order) {
    return order.voltageL1 != null ||
        order.voltageL2 != null ||
        order.voltageL3 != null ||
        order.currentL1 != null ||
        order.currentL2 != null ||
        order.currentL3 != null ||
        order.currentTotalA != null ||
        order.temperatureC != null ||
        order.frequencyHz != null ||
        order.meterReportedSoc != null ||
        order.connectorStatus != null ||
        order.connectorErrorCode != null;
  }

  List<Widget> _telemetryRows(ModelOrder order) {
    final rows = <MapEntry<String, String>>[];

    if (order.connectorStatus != null) {
      rows.add(MapEntry('Estado conector', order.connectorStatus!));
    }
    if (order.connectorErrorCode != null &&
        order.connectorErrorCode != 'NoError') {
      rows.add(MapEntry('Error conector', order.connectorErrorCode!));
    }
    if (order.meterReportedSoc != null) {
      rows.add(
        MapEntry(
          'SoC (medidor)',
          '${order.meterReportedSoc!.toStringAsFixed(0)}%',
        ),
      );
    }
    if (order.temperatureC != null) {
      rows.add(
        MapEntry(
          'Temperatura',
          '${order.temperatureC!.toStringAsFixed(1)} °C',
        ),
      );
    }
    if (order.frequencyHz != null) {
      rows.add(
        MapEntry('Frecuencia', '${order.frequencyHz!.toStringAsFixed(1)} Hz'),
      );
    }
    if (order.voltageL1 != null ||
        order.voltageL2 != null ||
        order.voltageL3 != null) {
      final parts = [order.voltageL1, order.voltageL2, order.voltageL3]
          .where((v) => v != null)
          .map((v) => v!.toStringAsFixed(0))
          .join(' / ');
      rows.add(MapEntry('Voltaje (L1/L2/L3)', '$parts V'));
    }
    if (order.currentL1 != null ||
        order.currentL2 != null ||
        order.currentL3 != null) {
      final parts = [order.currentL1, order.currentL2, order.currentL3]
          .where((v) => v != null)
          .map((v) => v!.toStringAsFixed(1))
          .join(' / ');
      rows.add(MapEntry('Corriente (L1/L2/L3)', '$parts A'));
    } else if (order.currentTotalA != null) {
      rows.add(
        MapEntry(
          'Corriente total',
          '${order.currentTotalA!.toStringAsFixed(1)} A',
        ),
      );
    }

    return [
      for (int i = 0; i < rows.length; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        LabelRowText(label: rows[i].key, value: rows[i].value, fontSize: 13),
      ],
    ];
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
