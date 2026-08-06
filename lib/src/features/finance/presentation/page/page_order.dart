import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageOrder extends StatefulWidget {
  const PageOrder({super.key});

  @override
  State<PageOrder> createState() => _PageOrderState();
}

class _PageOrderState extends State<PageOrder> {
  @override
  Widget build(BuildContext context) {
    final ModelTransaction args =
        ModalRoute.of(context)?.settings.arguments as ModelTransaction;

    return Scaffold(
      backgroundColor: primaryColor(),
      appBar: AppBar(
        backgroundColor: primaryColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: accentColor()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<ModelOrder>(
        future: _loadData(args),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: accentColor()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: whiteColor().withValues(alpha: 0.5),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No se pudo cargar la orden.',
                    style: TextStyle(
                      color: whiteColor().withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            );
          }

          final order = snapshot.data!;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 16),
                  child: child,
                ),
              );
            },
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(left: 18, right: 18, bottom: 24),
              children: [
                _statusHeader(order),
                const SizedBox(height: 16),
                ..._section(
                  title: 'Resumen',
                  icon: Icons.receipt_long_rounded,
                  rows: _resumenRows(order),
                ),
                ..._section(
                  title: 'Estación',
                  icon: Icons.ev_station_rounded,
                  rows: _estacionRows(order),
                ),
                ..._section(
                  title: 'Cliente',
                  icon: Icons.person_outline_rounded,
                  rows: _clienteRows(order),
                ),
                ..._section(
                  title: 'Carga',
                  icon: Icons.bolt_rounded,
                  rows: _cargaRows(order),
                ),
                ..._section(
                  title: 'Pago',
                  icon: Icons.payments_outlined,
                  rows: _pagoRows(order),
                ),
                _timelineSection(order),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<ModelOrder> _loadData(ModelTransaction args) async {
    final provider = context.read<FinanceProvider>();
    return await provider.getOrderData({'id': args.order});
  }
}

// ==================== ENCABEZADO DE ESTADO ====================

Widget _statusHeader(ModelOrder order) {
  final opColor = _operationStatusColor(order.operationStatus);

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: glass(deep: true),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${_shortOrderId(order.id)}',
                    style: TextStyle(
                      color: whiteColor().withValues(alpha: 0.55),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Text(
                  //   UtilsDate.formatLocal(order.createdAt),
                  //   style: TextStyle(
                  //     color: whiteColor().withValues(alpha: 0.85),
                  //     fontSize: 14,
                  //   ),
                  // ),
                ],
              ),
            ),
            _statusChip(
              icon: _operationStatusIcon(order.operationStatus),
              color: opColor,
              label: _operationStatusLabel(order.operationStatus),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _paymentStatusBadge(order.status),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _money(order.total),
              style: TextStyle(
                color: errorColor(),
                fontSize: 34,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'total',
                style: TextStyle(
                  color: whiteColor().withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _statusChip({
  required IconData icon,
  required Color color,
  required String label,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: color.withValues(alpha: 0.45)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ],
    ),
  );
}

Widget _paymentStatusBadge(String status) {
  final label = _paymentStatusLabel(status);
  if (label.isEmpty) return const SizedBox.shrink();

  return Text(
    'Pago: $label',
    style: TextStyle(
      color: whiteColor().withValues(alpha: 0.55),
      fontSize: 12.5,
    ),
  );
}

// ==================== SECCIONES ====================

/// Envuelve una sección en `CardTitleDescription` solo si tiene al menos
/// una fila con datos reales — evita mostrar tarjetas vacías cuando el
/// backend no devuelve esa información para esta orden en particular.
List<Widget> _section({
  required String title,
  required IconData icon,
  required List<Widget> rows,
}) {
  if (rows.isEmpty) return const [];
  return [
    CardTitleDescription(
      title: title,
      icon: icon,
      iconColor: accentColor(),
      rows: rows,
    ),
  ];
}

List<Widget> _resumenRows(ModelOrder order) {
  final duration = _sessionDuration(
    order.chargingStartTime,
    order.chargingEndTime,
  );

  return [
    LabelRowText(
      label: 'Precio por kWh',
      value: '${_money(order.pricePerKwh)}/kWh',
    ),
    LabelRowText(
      label: 'Energía consumida',
      value: '${order.kWhDelivered.toStringAsFixed(2)} kWh',
    ),
    if (duration != null)
      LabelRowText(label: 'Duración de sesión', value: duration),
    LabelRowText(label: 'Subtotal', value: _money(order.subtotal)),
    if (order.discountTotal > 0)
      LabelRowText(
        label: 'Descuento',
        value: '-${_money(order.discountTotal)}',
        subtitleColor: successColor(),
      ),
    LabelRowText(label: 'Impuestos', value: _money(order.tax)),
    LabelRowText(
      label: 'Total',
      value: _money(order.total),
      titleColor: whiteColor(),
      subtitleColor: accentColor(),
      fontSize: 15,
      fontSizeValue: 17,
    ),
  ];
}

List<Widget> _estacionRows(ModelOrder order) {
  final phone = '${order.stations.prefixCode} ${order.stations.phone}'.trim();

  return [
    if (order.stations.name.isNotEmpty)
      LabelRowText(label: 'Nombre', value: order.stations.name),
    if (order.stations.address.isNotEmpty)
      LabelRowText(label: 'Dirección', value: order.stations.address),
    if (order.stations.phone.isNotEmpty)
      LabelRowText(label: 'Teléfono', value: phone),
    if (order.charger.typeConnection.isNotEmpty)
      LabelRowText(
        label: 'Tipo de conector',
        value: order.charger.typeConnection,
      ),
    LabelRowText(label: 'Conector', value: '#${order.connectorId}'),
  ];
}

List<Widget> _clienteRows(ModelOrder order) {
  final user = order.user;
  if (user.name.isEmpty) return const [];

  final phone = '${user.prefix} ${user.phone}'.trim();

  return [
    LabelRowText(label: 'Nombre', value: user.name),
    if (user.ci.isNotEmpty) LabelRowText(label: 'Documento', value: user.ci),
    if (user.email.isNotEmpty) LabelRowText(label: 'Correo', value: user.email),
    if (user.phone.isNotEmpty) LabelRowText(label: 'Teléfono', value: phone),
  ];
}

List<Widget> _cargaRows(ModelOrder order) {
  final isActive =
      order.operationStatus == 'CHARGING' ||
      order.operationStatus == 'STARTING';

  return [
    LabelRowText(
      label: 'Energía entregada',
      value: '${order.kWhDelivered.toStringAsFixed(2)} kWh',
    ),
    if (isActive || order.currentPowerKw > 0)
      LabelRowText(
        label: 'Potencia actual',
        value: '${order.currentPowerKw.toStringAsFixed(2)} kW',
      ),
    if (order.batteryCapacityKwh > 0)
      LabelRowText(
        label: 'Capacidad de batería',
        value: '${order.batteryCapacityKwh} kWh',
      ),
    LabelRowText(label: 'SOC inicial', value: _percent(order.socStart)),
    LabelRowText(label: 'SOC final', value: _percent(order.soc)),
    LabelRowText(label: 'Medidor inicial', value: '${order.meterStart} Wh'),
    if (order.meterStop > 0)
      LabelRowText(label: 'Medidor final', value: '${order.meterStop} Wh'),
    if (order.stopReason.isNotEmpty)
      LabelRowText(label: 'Motivo de finalización', value: order.stopReason),
    if (order.ocppTransactionId != 0)
      LabelRowText(
        label: 'OCPP Transaction ID',
        value: '${order.ocppTransactionId}',
      ),
    if (order.idTag.isNotEmpty)
      LabelRowText(label: 'IdTag', value: order.idTag),
  ];
}

List<Widget> _pagoRows(ModelOrder order) {
  return [
    LabelRowText(
      label: 'Método de pago',
      value: order.paymentMethodName ?? 'No disponible',
    ),
    LabelRowText(label: 'Subtotal', value: _money(order.subtotal)),
    LabelRowText(label: 'Impuestos', value: _money(order.tax)),
    if (order.discountTotal > 0)
      LabelRowText(
        label: 'Descuento',
        value: '-${_money(order.discountTotal)}',
        subtitleColor: successColor(),
      ),
    LabelRowText(
      label: 'Total',
      value: _money(order.total),
      titleColor: whiteColor(),
      subtitleColor: accentColor(),
      fontSize: 15,
      fontSizeValue: 17,
    ),
  ];
}

// ==================== CRONOLOGÍA ====================

Widget _timelineSection(ModelOrder order) {
  final points = <_TimelinePoint>[
    if (order.remoteStartRequestedAt != null)
      _TimelinePoint(
        icon: Icons.touch_app_outlined,
        label: 'Carga solicitada',
        time: order.remoteStartRequestedAt!,
      ),
    if (order.chargingStartTime != null)
      _TimelinePoint(
        icon: Icons.play_circle_outline_rounded,
        label: 'Inicio de carga',
        time: order.chargingStartTime!,
      ),
    if (order.chargingEndTime != null)
      _TimelinePoint(
        icon: Icons.stop_circle_outlined,
        label: 'Fin de carga',
        time: order.chargingEndTime!,
      ),
    if (order.finalizedAt != null)
      _TimelinePoint(
        icon: Icons.check_circle_outline_rounded,
        label: 'Orden finalizada',
        time: order.finalizedAt!,
      ),
  ];

  if (points.isEmpty) return const SizedBox.shrink();

  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    decoration: glass(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline_rounded, color: accentColor(), size: 24),
            const SizedBox(width: 10),
            Text(
              'Cronología',
              style: TextStyle(
                color: whiteColor(),
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(color: Colors.white24, thickness: 0.5),
        const SizedBox(height: 14),
        for (int i = 0; i < points.length; i++)
          _timelineEntry(points[i], isLast: i == points.length - 1),
      ],
    ),
  );
}

class _TimelinePoint {
  final IconData icon;
  final String label;
  final String time;

  _TimelinePoint({required this.icon, required this.label, required this.time});
}

Widget _timelineEntry(_TimelinePoint point, {required bool isLast}) {
  final color = accentColor();

  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.14),
                border: Border.all(color: color, width: 1.4),
              ),
              child: Icon(point.icon, color: color, size: 15),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  color: color.withValues(alpha: 0.25),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.label,
                  style: TextStyle(
                    color: whiteColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  UtilsDate.formatLocal(point.time),
                  style: TextStyle(
                    color: whiteColor().withValues(alpha: 0.55),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ==================== HELPERS ====================

String _shortOrderId(String id) {
  if (id.length <= 8) return id.toUpperCase();
  return id.substring(id.length - 8).toUpperCase();
}

String _money(num value) => '\$${value.toStringAsFixed(2)}';

String _percent(num value) => '${value.toStringAsFixed(0)}%';

/// Calcula la duración entre el inicio y fin de una sesión de carga.
/// Devuelve `null` si falta alguna marca de tiempo o si el resultado no
/// tiene sentido (fin antes que inicio), para que la fila se oculte.
String? _sessionDuration(String? start, String? end) {
  if (start == null || start.isEmpty || end == null || end.isEmpty) {
    return null;
  }

  try {
    final startTime = UtilsDate.toLocal(start);
    final endTime = UtilsDate.toLocal(end);
    final diff = endTime.difference(startTime);
    if (diff.isNegative) return null;

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';

    final seconds = diff.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  } catch (_) {
    return null;
  }
}

Color _operationStatusColor(String status) {
  switch (status) {
    case 'PENDING':
      return warningColor();
    case 'STARTING':
      return infoColor();
    case 'CHARGING':
      return accentColor();
    case 'STOPPING':
      return warningColor();
    case 'FINISHED':
      return successColor();
    case 'FAILED':
      return errorColor();
    case 'CANCELLED':
      return grayInputColor();
    default:
      return grayInputColor();
  }
}

IconData _operationStatusIcon(String status) {
  switch (status) {
    case 'PENDING':
      return Icons.hourglass_empty_rounded;
    case 'STARTING':
      return Icons.play_circle_outline_rounded;
    case 'CHARGING':
      return Icons.bolt_rounded;
    case 'STOPPING':
      return Icons.pause_circle_outline_rounded;
    case 'FINISHED':
      return Icons.check_circle_rounded;
    case 'FAILED':
      return Icons.error_outline_rounded;
    case 'CANCELLED':
      return Icons.cancel_outlined;
    default:
      return Icons.info_outline_rounded;
  }
}

String _operationStatusLabel(String status) {
  switch (status) {
    case 'PENDING':
      return 'Pendiente';
    case 'STARTING':
      return 'Iniciando';
    case 'CHARGING':
      return 'Cargando';
    case 'STOPPING':
      return 'Deteniendo';
    case 'FINISHED':
      return 'Finalizado';
    case 'FAILED':
      return 'Fallido';
    case 'CANCELLED':
      return 'Cancelado';
    default:
      return status;
  }
}

String _paymentStatusLabel(String status) {
  switch (status) {
    case 'DONE':
      return 'Pagado';
    case 'PENDING':
      return 'Pendiente de pago';
    case 'REFUND':
      return 'Reembolsado';
    case 'DELETED':
      return 'Eliminado';
    case 'EXPIRED':
      return 'Expirado';
    default:
      return '';
  }
}
