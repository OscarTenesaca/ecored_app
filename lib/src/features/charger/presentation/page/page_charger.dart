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
      return Container(
        color: primaryColor(),
        child: Center(child: CircularProgressIndicator(color: accentColor())),
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isChargingNotifier,
      builder: (context, isCharging, _) {
        final level = batteryLevel(order);
        final duration = formattedDuration(order);
        final remaining = remainingTime(order);
        final meta = _operationStatusMeta(order.operationStatus, isCharging);
        final hasConnectorError =
            order.connectorErrorCode != null &&
            order.connectorErrorCode != 'NoError';

        return Scaffold(
          backgroundColor: primaryColor(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              physics: const BouncingScrollPhysics(),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 14),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(meta: meta),

                    if (provider.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _AlertBanner(
                        icon: Icons.wifi_off_rounded,
                        color: errorColor(),
                        message: provider.errorMessage!,
                      ),
                    ],
                    if (hasConnectorError) ...[
                      const SizedBox(height: 12),
                      _AlertBanner(
                        icon: Icons.warning_amber_rounded,
                        color: warningColor(),
                        message:
                            'El cargador reportó un error: ${order.connectorErrorCode}',
                      ),
                    ],

                    const SizedBox(height: 16),

                    /// PROTAGONISTA: anillo + métricas compactas a los lados
                    _RingSection(
                      order: order,
                      isCharging: isCharging,
                      level: level,
                      meta: meta,
                      pulseController: _rotationController,
                      duration: duration,
                      remaining: remaining,
                      currency: currency,
                    ),

                    const SizedBox(height: 26),

                    /// COSTO ESTIMADO (compacto, expandible)
                    _CostCard(order: order, currency: currency),

                    const SizedBox(height: 18),

                    /// CONECTOR / ESTACIÓN / TRANSACCIÓN
                    _SessionDetailCard(order: order),

                    if (_hasCompactTelemetry(order)) ...[
                      const SizedBox(height: 22),
                      _TelemetryStrip(order: order),
                    ],

                    const SizedBox(height: 26),

                    /// ACCIÓN PRINCIPAL
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

                      onPressed:
                          isCharging ? () => toggleCharging(order) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ================= ESTADO: color/ícono/etiqueta según operationStatus =================

class _StatusMeta {
  final String label;
  final String title;
  final Color color;
  final IconData icon;

  const _StatusMeta(this.label, this.title, this.color, this.icon);
}

_StatusMeta _operationStatusMeta(String operationStatus, bool isCharging) {
  switch (operationStatus) {
    case 'STARTING':
      return _StatusMeta(
        'Iniciando',
        'Preparando carga',
        warningColor(),
        Icons.hourglass_top_rounded,
      );
    case 'CHARGING':
      return _StatusMeta(
        'Cargando',
        'Carga en progreso',
        accentColor(),
        Icons.bolt_rounded,
      );
    case 'STOPPING':
      return _StatusMeta(
        'Deteniendo',
        'Finalizando sesión',
        warningColor(),
        Icons.hourglass_bottom_rounded,
      );
    case 'FINISHED':
      return _StatusMeta(
        'Finalizada',
        'Carga finalizada',
        successColor(),
        Icons.check_circle_rounded,
      );
    case 'FAILED':
      return _StatusMeta(
        'Fallida',
        'Carga fallida',
        errorColor(),
        Icons.error_rounded,
      );
    case 'CANCELLED':
      return _StatusMeta(
        'Cancelada',
        'Carga cancelada',
        errorColor(),
        Icons.cancel_rounded,
      );
    case 'PENDING':
    default:
      return isCharging
          ? _StatusMeta(
            'Cargando',
            'Carga en progreso',
            accentColor(),
            Icons.bolt_rounded,
          )
          : _StatusMeta(
            'Pausada',
            'Carga en pausa',
            errorColor(),
            Icons.pause_circle_rounded,
          );
  }
}

// ================= HEADER =================

class _Header extends StatelessWidget {
  final _StatusMeta meta;

  const _Header({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            meta.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: whiteColor(),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: meta.color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: meta.color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(meta.icon, size: 14, color: meta.color),
              const SizedBox(width: 6),
              Text(
                meta.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: meta.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================= ALERTAS =================

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _AlertBanner({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= VALOR ANIMADO (fade+slide al cambiar) =================

class _AnimatedValue extends StatelessWidget {
  final String value;
  final TextStyle style;
  final TextAlign textAlign;

  const _AnimatedValue({
    required this.value,
    required this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        value,
        key: ValueKey(value),
        style: style,
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ================= ANILLO PROTAGONISTA + MÉTRICAS COMPACTAS =================

class _RingSection extends StatelessWidget {
  final ModelOrder order;
  final bool isCharging;
  final double level;
  final _StatusMeta meta;
  final AnimationController pulseController;
  final String duration;
  final String? remaining;
  final NumberFormat currency;

  const _RingSection({
    required this.order,
    required this.isCharging,
    required this.level,
    required this.meta,
    required this.pulseController,
    required this.duration,
    required this.remaining,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _RingMetricColumn(
            alignment: CrossAxisAlignment.start,
            items: [
              _RingMetricItem(
                'Energía entregada',
                '${order.kWhDelivered.toStringAsFixed(2)} kWh',
              ),
              _RingMetricItem('Tiempo de carga', duration),
              _RingMetricItem(
                'Potencia actual',
                '${order.currentPowerKw.toStringAsFixed(1)} kW',
                valueColor: meta.color,
              ),
            ],
          ),
        ),
        _ChargingRing(
          level: level,
          isCharging: isCharging,
          meta: meta,
          pulseController: pulseController,
          kWhDelivered: order.kWhDelivered,
        ),
        Expanded(
          child: _RingMetricColumn(
            alignment: CrossAxisAlignment.end,
            items: [
              _RingMetricItem(
                'Tiempo restante',
                remaining ?? '—',
                textAlign: TextAlign.end,
              ),
              _RingMetricItem(
                'Precio actual',
                '${currency.format(order.pricePerKwh)}/kWh',
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingMetricItem {
  final String label;
  final String value;
  final Color? valueColor;
  final TextAlign textAlign;

  const _RingMetricItem(
    this.label,
    this.value, {
    this.valueColor,
    this.textAlign = TextAlign.start,
  });
}

class _RingMetricColumn extends StatelessWidget {
  final CrossAxisAlignment alignment;
  final List<_RingMetricItem> items;

  const _RingMetricColumn({required this.alignment, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          Text(
            items[i].label,
            style: TextStyle(fontSize: 11, color: grayInputColor()),
            textAlign: items[i].textAlign,
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment:
                items[i].textAlign == TextAlign.end
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
            child: _AnimatedValue(
              value: items[i].value,
              textAlign: items[i].textAlign,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: items[i].valueColor ?? whiteColor(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ================= MAIN RING =================
// Diseño original: círculo sólido con glow, barrido giratorio de acento
// mientras carga y anillo de progreso relleno — sin cambios respecto a
// la versión previa (el usuario pidió mantenerlo tal cual).
class _ChargingRing extends StatelessWidget {
  final double level;
  final bool isCharging;
  final _StatusMeta meta;
  final AnimationController pulseController;
  final double kWhDelivered;

  const _ChargingRing({
    required this.level,
    required this.isCharging,
    required this.meta,
    required this.pulseController,
    required this.kWhDelivered,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      isCharging
                          ? accentColor().withValues(alpha: 0.18)
                          : errorColor().withValues(alpha: 0.12),
                  blurRadius: 24,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),

          if (isCharging)
            AnimatedBuilder(
              animation: pulseController,
              builder: (_, child) {
                return Transform.rotate(
                  angle: pulseController.value * 2 * pi,
                  child: child,
                );
              },
              child: Container(
                width: 132,
                height: 132,
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
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
          ),

          SizedBox(
            width: 115,
            height: 115,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: level),
              duration: const Duration(seconds: 2),
              builder: (_, value, __) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation(
                    isCharging ? accentColor() : errorColor(),
                  ),
                );
              },
            ),
          ),

          Container(
            width: 96,
            height: 96,
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
                size: 18,
              ),
              const SizedBox(height: 3),
              _AnimatedValue(
                value: "${kWhDelivered.toStringAsFixed(1)} kWh",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: whiteColor(),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                isCharging ? "Charging..." : "Paused",
                style: TextStyle(
                  fontSize: 9.5,
                  color: whiteColor().withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= COSTO ESTIMADO (compacto, expandible) =================

class _CostCard extends StatefulWidget {
  final ModelOrder order;
  final NumberFormat currency;

  const _CostCard({required this.order, required this.currency});

  @override
  State<_CostCard> createState() => _CostCardState();
}

class _CostCardState extends State<_CostCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final currency = widget.currency;

    return Container(
      width: double.infinity,
      decoration: cardDecoration(shadow: true),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Costo estimado',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: whiteColor(),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Precio incluye IVA',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: grayInputColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _AnimatedValue(
                    value: currency.format(order.total),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: accentColor(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: grayInputColor(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                children: [
                  Divider(
                    color: Colors.white.withValues(alpha: 0.08),
                    height: 1,
                  ),
                  const SizedBox(height: 10),
                  LabelRowText(
                    label: 'Energía',
                    value: currency.format(order.subtotal),
                    fontSize: 13,
                    titleColor: grayInputColor(),
                  ),
                  LabelRowText(
                    label: 'IVA',
                    value: currency.format(order.tax),
                    fontSize: 13,
                    titleColor: grayInputColor(),
                  ),
                  LabelRowText(
                    label: 'Total',
                    value: currency.format(order.total),
                    fontSize: 14,
                    fontSizeValue: 16,
                    subtitleColor: accentColor(),
                  ),
                ],
              ),
            ),
            crossFadeState:
                _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ================= DETALLE DE LA SESIÓN (conector / estación / transacción) =================

class _SessionDetailCard extends StatelessWidget {
  final ModelOrder order;

  const _SessionDetailCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(shadow: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalle de la sesión',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: whiteColor(),
            ),
          ),
          const SizedBox(height: 18),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SessionDetailItem(
                    icon: Icons.ev_station_rounded,
                    label: 'Conector',
                    value: 'Conector ${order.connectorId}',
                    subtitle: order.charger.typeConnection,
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _SessionDetailItem(
                    icon: Icons.location_on_rounded,
                    label: 'Estación',
                    value: order.stations.name,
                    subtitle: order.stations.address,
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _SessionDetailItem(
                    icon: Icons.confirmation_number_rounded,
                    label: 'Transacción',
                    value: '#${order.ocppTransactionId}',
                    subtitle: order.platformBuy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: VerticalDivider(
        color: Colors.white.withValues(alpha: 0.08),
        width: 1,
        thickness: 1,
      ),
    );
  }
}

class _SessionDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  const _SessionDetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accentColor().withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: accentColor()),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: grayInputColor()),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: whiteColor(),
          ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10.5, color: grayInputColor()),
        ),
      ],
    );
  }
}

// ================= TELEMETRÍA (bloque horizontal compacto) =================
// Solo se muestra lo que el cargador efectivamente reporta por
// MeterValues — nunca se inventan valores.

bool _hasCompactTelemetry(ModelOrder order) {
  return order.voltageL1 != null ||
      order.voltageL2 != null ||
      order.voltageL3 != null ||
      order.currentL1 != null ||
      order.currentTotalA != null ||
      order.temperatureC != null;
}

class _TelemetryStrip extends StatelessWidget {
  final ModelOrder order;

  const _TelemetryStrip({required this.order});

  @override
  Widget build(BuildContext context) {
    final voltage = order.voltageL1 ?? order.voltageL2 ?? order.voltageL3;
    final current = order.currentTotalA ?? order.currentL1;

    final items = <_TelemetryItem>[
      if (voltage != null)
        _TelemetryItem(
          Icons.bolt_rounded,
          '${voltage.toStringAsFixed(0)} V',
          'Voltaje',
        ),
      if (current != null)
        _TelemetryItem(
          Icons.electric_bolt_rounded,
          '${current.toStringAsFixed(1)} A',
          'Corriente',
        ),
      _TelemetryItem(
        Icons.speed_rounded,
        '${order.currentPowerKw.toStringAsFixed(1)} kW',
        'Potencia',
      ),
      if (order.temperatureC != null)
        _TelemetryItem(
          Icons.thermostat_rounded,
          '${order.temperatureC!.toStringAsFixed(0)} °C',
          'Temperatura',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Telemetría en tiempo real',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: grayInputColor(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final item in items)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: accentColor().withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(item.icon, size: 17, color: accentColor()),
                    ),
                    const SizedBox(height: 8),
                    _AnimatedValue(
                      value: item.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: whiteColor(),
                      ),
                    ),
                    Text(
                      item.label,
                      style: TextStyle(fontSize: 10.5, color: grayInputColor()),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TelemetryItem {
  final IconData icon;
  final String value;
  final String label;

  const _TelemetryItem(this.icon, this.value, this.label);
}
