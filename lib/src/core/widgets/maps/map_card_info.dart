import 'package:ecored_app/src/core/adapter/adapter_launcher.dart';
import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charge_point.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

const Map<String, IconData> _typePointIcons = {
  'PUBLIC': Icons.public,
  'PARKING': Icons.local_parking,
  'AIRPORT': Icons.flight,
  'CAMPING': Icons.park_outlined,
  'HOTEL': Icons.hotel_outlined,
  'PRIVATE': Icons.lock_outline,
  'USER_PRIVATE': Icons.person_outline,
  'RESTAURANT': Icons.restaurant,
  'SHOP': Icons.storefront_outlined,
  'WORKPLACE': Icons.business_outlined,
  'STATION_SERVICE': Icons.local_gas_station_outlined,
  'CONCESSIONAIRE': Icons.store_outlined,
  'SHOPPING_CENTER': Icons.local_mall_outlined,
  'OTHER': Icons.place_outlined,
};

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

  List<ModelChargePoint> chargePointsData = [];
  // Una vez carga el preview, reemplaza a `widget.stationData` como fuente
  // de verdad: trae campos que la lista de estaciones no manda
  // (typePoint, province, canton, tarifas).
  ModelStation? _previewStation;

  final Set<String> _expandedChargePoints = {};

  // Para el swipe manual
  double _dragOffset = 0;

  ModelStation get _station => _previewStation ?? widget.stationData;

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

  Future<void> _loadMarkers() async {
    final provider = context.read<StationProvider>();
    await provider.getStationPreview(widget.stationData.id);
    if (!mounted) return;
    final preview = provider.stationPreview;
    setState(() {
      chargePointsData = preview?.chargePoints ?? [];
      _previewStation = preview?.station;
      _expandedChargePoints
        ..clear()
        ..addAll(chargePointsData.map((cp) => cp.id));
    });
  }

  // ─────────────── Helpers de formato ───────────────

  String _titleCase(String value) => value
      .toLowerCase()
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  // 2.0 → "2", 7.5 → "7.5"
  String _num(double value) =>
      value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toStringAsFixed(1);

  String _money(double value) =>
      '\$${((value * 100).truncate() / 100).toStringAsFixed(2)}';

  int get _totalConnectors =>
      chargePointsData.fold(0, (sum, cp) => sum + cp.connectors.length);

  double get _maxPowerKw => chargePointsData
      .expand((cp) => cp.connectors)
      .fold(0.0, (max, c) => c.powerKw > max ? c.powerKw : max);

  String? get _typePointLabel {
    final typePoint = _station.typePoint;
    if (typePoint == null || typePoint.isEmpty) return null;
    for (final item in STATION_TYPE_POINTS_LIST) {
      if (item['key'] == typePoint) {
        // Las etiquetas traen un emoji al inicio ("✈️ Aeropuerto"); aquí
        // va un ícono Material en su lugar.
        final label = item['label']!;
        final space = label.indexOf(' ');
        return space == -1 ? label : label.substring(space + 1);
      }
    }
    return null;
  }

  String get _locationSummary {
    final parts = <String>[
      if ((_station.canton?.name ?? '').isNotEmpty)
        _titleCase(_station.canton!.name),
      if ((_station.province?.name ?? '').isNotEmpty)
        _titleCase(_station.province!.name),
      if (_station.country.name.isNotEmpty) _titleCase(_station.country.name),
    ];
    final tail = parts.join(', ');
    if (_station.address.isEmpty) return tail;
    if (tail.isEmpty) return _station.address;
    return '${_station.address} · $tail';
  }

  bool get _hasFees =>
      _station.serviceFee != null ||
      _station.parkingBaseFee != null ||
      _station.parkingFeePerMinute != null;

  // ─────────────── Build ───────────────

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
                      height:
                          UtilSize.height(context) < 700
                              ? UtilSize.height(context) * 0.85
                              : 700,
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

                          CustomAssetImg(
                            imagePath: AssetPaths.charge_station,
                            height: 200,
                            borderRadius: 30,
                            borderColor: accentColor(),
                            borderWidth: 3,
                          ),
                          const SizedBox(height: 16),

                          _headerSection(),
                          const SizedBox(height: 20),
                          _actionsRow(),
                          const SizedBox(height: 16),
                          _statsRow(),

                          const SizedBox(height: 24),
                          _sectionTitle('Cargadores'),
                          const SizedBox(height: 12),
                          ...chargePointsData.asMap().entries.map(
                            (entry) =>
                                _chargePointCard(entry.value, entry.key + 1),
                          ),

                          // if (_hasFees) ...[
                          //   const SizedBox(height: 12),
                          //   _sectionTitle('Tarifas de la estación'),
                          //   const SizedBox(height: 12),
                          //   _feesCard(),
                          // ],
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

  // ─────────────── Secciones ───────────────

  Widget _headerSection() {
    final typeLabel = _typePointLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (typeLabel != null) ...[
              _pill(
                label: typeLabel,
                color: grayInputColor(),
                icon:
                    _typePointIcons[_station.typePoint] ?? Icons.place_outlined,
                outlined: true,
              ),
              const SizedBox(width: 8),
            ],
            _pill(
              label:
                  'Estación ${stationStatusLabel(_station.status).toLowerCase()}',
              color: stationStatusColor(_station.status),
              dot: true,
            ),
          ],
        ),
        const SizedBox(height: 12),
        LabelTitle(
          padding: false,
          title: _station.name,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        if (_locationSummary.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: accentColor()),
              const SizedBox(width: 4),
              Expanded(
                child: LabelTitle(
                  padding: false,
                  title: _locationSummary,
                  fontSize: 13,
                  textColor: Colors.white70,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
        if (_station.description.isNotEmpty) ...[
          const SizedBox(height: 10),
          _ExpandableText(
            text: _station.description,
            style: TextStyle(
              color: grayInputColor(),
              height: 1.5,
              fontSize: 12,
            ),
            linkColor: accentColor(),
          ),
        ],
      ],
    );
  }

  Widget _actionsRow() {
    final phone = _station.prefixCode + _station.phone;

    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.near_me_outlined,
            label: 'Cómo llegar',
            filled: true,
            onTap:
                widget.userMarker == null
                    ? null
                    : () => AdapterLauncher().launchMapsDirections(
                      latOrigin: '${widget.userMarker!.latitude}',
                      lngOrigin: '${widget.userMarker!.longitude}',
                      latDestination: _station.lat,
                      lngDestination: _station.lng,
                    ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
            icon: Icons.chat_bubble_outline,
            label: 'WhatsApp',
            onTap: () => AdapterLauncher().launchWhatsApp(phone),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
            icon: Icons.call_outlined,
            label: 'Llamar',
            onTap: () => AdapterLauncher().launchPhone(phone),
          ),
        ),
      ],
    );
  }

  Widget _statsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem('${chargePointsData.length}', 'Cargadores'),
          ),
          _verticalDivider(),
          Expanded(child: _summaryItem('$_totalConnectors', 'Conectores')),
          _verticalDivider(),
          Expanded(
            child: _summaryItem('${_num(_maxPowerKw)} kW', 'Potencia máx.'),
          ),
        ],
      ),
    );
  }

  Widget _chargePointCard(ModelChargePoint chargePoint, int index) {
    final isOnline = chargePoint.connectionStatus == 'CONNECTED';
    final isExpanded = _expandedChargePoints.contains(chargePoint.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedChargePoints.remove(chargePoint.id);
                } else {
                  _expandedChargePoints.add(chargePoint.id);
                }
              });
            },
            child: Row(
              children: [
                _iconBox(
                  child: Icon(
                    Icons.bolt_outlined,
                    color: accentColor(),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelTitle(
                        padding: false,
                        title: 'Cargador $index',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        chargePoint.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: grayInputColor(),
                          fontSize: 11,
                          letterSpacing: 0.5,
                          fontFamily: 'monospace',
                          fontFamilyFallback: const ['Menlo', 'Courier'],
                        ),
                      ),
                    ],
                  ),
                ),
                _pill(
                  label: isOnline ? 'Conectado' : 'Desconectado',
                  color: isOnline ? accentColor() : errorColor(),
                  dot: true,
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: grayInputColor(),
                  ),
                ),
              ],
            ),
          ),

          if (isExpanded) ...[
            const SizedBox(height: 14),
            // if (!isOnline) ...[
            //   _alertBanner(
            //     'Cargador sin conexión. Puedes ver los conectores, pero no '
            //     'iniciar una carga.',
            //   ),
            //   const SizedBox(height: 12),
            // ],
            ...chargePoint.connectors.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _connectorCard(c, chargePointOnline: isOnline),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _connectorCard(
    ModelCharger charger, {
    required bool chargePointOnline,
  }) {
    final String statusLabel =
        chargePointOnline ? stationStatusLabel(charger.status) : 'Sin conexión';
    final Color statusColor =
        chargePointOnline ? stationStatusColor(charger.status) : errorColor();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: _connectorIcon(charger),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelTitle(
                      padding: false,
                      title:
                          charger.connectorType?.name ?? charger.typeConnection,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 2),
                    LabelTitle(
                      padding: false,
                      title:
                          'Conector ${charger.displayLabel ?? '-'} · '
                          'N.° ${charger.connectorId} · ${charger.typeCharger}',
                      fontSize: 11,
                      textColor: grayInputColor(),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _specBox('Potencia', '${_num(charger.powerKw)} kW'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _specBox('Voltaje', '${_num(charger.voltage)} V'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _specBox('Corriente', '${_num(charger.intensity)} A'),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: _money(charger.priceWithTipeConnector),
                      style: TextStyle(
                        color: accentColor(),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' / kWh',
                      style: TextStyle(color: grayInputColor(), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _pill(label: statusLabel, color: statusColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feesCard() {
    final serviceFee = _station.serviceFee ?? 0;
    final parkingBase = _station.parkingBaseFee ?? 0;
    final parkingPerMinute = _station.parkingFeePerMinute ?? 0;
    final baseMinutes = _station.parkingBaseMinutes;

    final rows = <MapEntry<String, String>>[
      MapEntry(
        'Tarifa de servicio',
        serviceFee == 0 ? 'Sin costo' : _money(serviceFee),
      ),
      MapEntry(
        baseMinutes != null
            ? 'Estacionamiento (primeros $baseMinutes min)'
            : 'Estacionamiento base',
        parkingBase == 0 ? 'Gratis' : _money(parkingBase),
      ),
      MapEntry(
        'Estacionamiento adicional',
        parkingPerMinute == 0 ? 'Gratis' : '${_money(parkingPerMinute)} / min',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: LabelTitle(
                      padding: false,
                      title: rows[i].key,
                      fontSize: 12,
                      textColor: grayInputColor(),
                    ),
                  ),
                  LabelTitle(
                    padding: false,
                    title: rows[i].value,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────── Piezas reutilizables ───────────────

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: deepForestGreen(),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
  );

  Widget _sectionTitle(String title) => LabelTitle(
    padding: false,
    title: title,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  Widget _pill({
    required String label,
    required Color color,
    bool dot = false,
    bool outlined = false,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:
            outlined
                ? Colors.white.withValues(alpha: 0.04)
                : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border:
            outlined
                ? Border.all(color: Colors.white.withValues(alpha: 0.12))
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: outlined ? Colors.white70 : color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    bool filled = false,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    final foreground = filled ? primaryColor() : whiteColor();

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: filled ? accentColor() : deepForestGreen(),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border:
                  filled
                      ? null
                      : Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: foreground, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: grayInputColor(), fontSize: 11)),
      ],
    );
  }

  Widget _verticalDivider() =>
      Container(width: 1, height: 32, color: Colors.white12);

  // El backend manda solo el nombre del archivo (ej. "ccs2.png"); se sirve
  // desde /connector-types/icon/:filename. Si no hay icono o falla la
  // descarga, cae al asset local genérico.
  Widget _connectorIcon(ModelCharger charger) {
    final fallback = Image.asset(AssetPaths.iconTypeC);
    final icon = charger.connectorType?.icon ?? '';
    if (icon.isEmpty) return fallback;

    final url =
        icon.startsWith('http')
            ? icon
            : '${Environment.url}/api/v1/connector-types/icon/$icon';

    return Image.network(
      url,
      headers: {
        'Authorization': 'Bearer ${Preferences().getUser()?.token ?? ''}',
      },
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => fallback,
      loadingBuilder:
          (_, child, progress) => progress == null ? child : const SizedBox(),
    );
  }

  Widget _iconBox({required Widget child}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Center(child: child),
    );
  }

  Widget _specBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: grayInputColor(), fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: errorColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: errorColor().withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: errorColor(), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: errorColor().withValues(alpha: 0.9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Texto que se recorta a [maxLines] y muestra "Ver más" / "Ver menos" solo
/// cuando de verdad no cabe en ese número de líneas.
class _ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color linkColor;
  final int maxLines = 3;

  const _ExpandableText({
    required this.text,
    required this.style,
    required this.linkColor,
  });

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: widget.style,
                maxLines: _expanded ? null : widget.maxLines,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            if (overflows)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _expanded ? 'Ver menos' : 'Ver más',
                    style: TextStyle(
                      color: widget.linkColor,
                      fontSize: widget.style.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
