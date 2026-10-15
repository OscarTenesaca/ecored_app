import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/charger/presentation/provider/charger_provider.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PageScanQr extends StatefulWidget {
  final ValueListenable<int>? tabIndexNotifier;
  final int? ownTabIndex;

  const PageScanQr({super.key, this.tabIndexNotifier, this.ownTabIndex});

  @override
  State<PageScanQr> createState() => _PageScanQrState();
}

class _PageScanQrState extends State<PageScanQr> {
  // variables
  bool _hasOpenedScanner = false;
  int MIN_RECHARGE_AMOUNT = 1;
  final ValueNotifier<String> qrCodeNotifier = ValueNotifier<String>('');

  int? _selectedConnectorId;
  bool _showOccupied = false;

  @override
  void initState() {
    super.initState();
    widget.tabIndexNotifier?.addListener(_onTabIndexChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🔥 se ejecuta una sola vez
    if (!_hasOpenedScanner) {
      _hasOpenedScanner = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanQr();
      });
    }
  }

  // Esta pestaña se mantiene montada dentro del IndexedStack de
  // PageAccess para no perder estado/red al navegar entre tabs, así que
  // dispose() nunca se dispara solo por cambiar de pestaña. Escuchamos
  // el índice activo para limpiar el QR/cargador escaneados apenas el
  // usuario sale de la pestaña "Cargar", sin esperar a que la pantalla
  // se destruya de verdad.
  void _onTabIndexChanged() {
    if (widget.tabIndexNotifier == null || widget.ownTabIndex == null) return;
    final isActive = widget.tabIndexNotifier!.value == widget.ownTabIndex;
    if (!isActive) {
      _resetScanState();
    }
  }

  void _resetScanState() {
    if (!mounted) return;
    qrCodeNotifier.value = '';
    _selectedConnectorId = null;
    _showOccupied = false;
    context.read<FinanceProvider>().clearChargerData();
  }

  @override
  void dispose() {
    widget.tabIndexNotifier?.removeListener(_onTabIndexChanged);
    qrCodeNotifier.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final financeProvider = context.read<FinanceProvider>(); // 👈 aquí
    await financeProvider.clearChargerData();

    if (!mounted) return;

    qrCodeNotifier.value = '';
    // qrCodeNotifier.value = 'http://159.223.127.104:3005/scanner/CHGN1J5LTP0HD';

    try {
      final result = await showPopUpWithChildren(
        context: context,
        title: 'Sigue estos pasos para iniciar la recarga',
        subTitle:
            '• Conecta el cargador a tu vehículo\n'
            '• Escanea el código QR\n'
            '• Presiona "Iniciar carga"',
        textButton: 'Cancelar',
        children: [BarCodeScanner(qrCode: qrCodeNotifier)],
      );

      qrCodeNotifier.value = result ?? '';
    } on PlatformException {
      qrCodeNotifier.value = 'Error al escanear';
    }

    if (!mounted) return;

    if (qrCodeNotifier.value.isNotEmpty) {
      debugPrint('QR escaneado: ${qrCodeNotifier.value}');
      final scannedData = qrCodeNotifier.value;

      if (!scannedData.contains('/scanner/')) {
        showSnackbar(
          context,
          'Este código QR no pertenece a EcoRed.',
          SnackbarStatus.error,
        );
        return;
      }

      final chargeCode = scannedData.split('/scanner/').last.trim();

      await financeProvider.findChargersByCode(chargeCode);

      if (!mounted) return;

      final fetchedChargers = financeProvider.chargerData;
      if (fetchedChargers == null || fetchedChargers.isEmpty) {
        showSnackbar(
          context,
          financeProvider.errorMessage ??
              'No se pudo obtener la información del cargador.',
          SnackbarStatus.error,
        );
      } else if (fetchedChargers.first.station == null) {
        showSnackbar(
          context,
          'La estación asociada a este cargador ya no está disponible.',
          SnackbarStatus.error,
        );
      } else {
        // Selección por defecto: el primer conector que no esté "Charging".
        // Si todos están ocupados, igual se selecciona el primero de la
        // lista (el usuario lo ve bloqueado y puede elegir otro si hay).
        final defaultCharger = fetchedChargers.firstWhere(
          (c) => c.connectorStatus != 'Charging',
          orElse: () => fetchedChargers.first,
        );
        setState(() {
          _selectedConnectorId = defaultCharger.connectorId;
          _showOccupied = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = context.watch<FinanceProvider>();
    final List<ModelCharger>? chargers = financeProvider.chargerData;

    return Scaffold(
      backgroundColor: primaryColor(),
      body: SafeArea(
        child: ValueListenableBuilder<String>(
          valueListenable: qrCodeNotifier,
          builder: (context, qrValue, _) {
            // 🟡 Mientras abre el scanner o está vacío
            if (qrValue.isEmpty) {
              return openScanner();
            }

            if (financeProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: accentColor()),
              );
            }

            if (chargers == null ||
                chargers.isEmpty ||
                chargers.first.station == null) {
              //mostrar la pantalla para escanear el QR
              return openScanner();
            }

            final selectedCharger = chargers.firstWhere(
              (c) => c.connectorId == _selectedConnectorId,
              orElse: () => chargers.first,
            );

            // 🟢 Mostrar resultado
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 400),
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
              child: _chargerView(chargers, selectedCharger),
            );
          },
        ),
      ),
    );
  }

  // Única regla de bloqueo: "Charging". Todo lo demás es seleccionable.
  bool _isOccupied(ModelCharger charger) =>
      charger.connectorStatus == 'Charging';

  // `typeConnection` ya no viene en la respuesta: el nombre sale del
  // catálogo (`connectorType`).
  String _typeName(ModelCharger charger) =>
      charger.connectorType?.name ?? charger.typeConnection;

  // Texto visible: la etiqueta del conector ("A", "B"...) en vez del número
  // OCPP. La selección y la orden siguen usando `connectorId`.
  String _connectorLabel(ModelCharger charger) {
    final label = charger.displayLabel?.trim() ?? '';
    return 'Conector ${label.isNotEmpty ? label : charger.connectorId}';
  }

  String _price(ModelCharger charger) =>
      '\$${((charger.priceWithTipeConnector * 100).truncate() / 100).toStringAsFixed(2)}';

  Widget _chargerView(List<ModelCharger> chargers, ModelCharger selected) {
    final bool selectedIsOccupied = _isOccupied(selected);

    // "En línea" se calcula sobre TODOS los conectores de la estación (no
    // solo el seleccionado): si al menos uno está CONNECTED, la estación
    // está en línea. Si el backend no manda connectionStatus para ninguno,
    // no se muestra el badge en vez de inventar un estado.
    final knownConnections =
        chargers.map((c) => c.connectionStatus).whereType<String>();
    final bool? isOnline =
        knownConnections.isEmpty
            ? null
            : knownConnections.any((s) => s == 'CONNECTED');

    final occupiedCount = chargers.where(_isOccupied).length;

    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            children: [
              _stationCard(
                selected,
                isOnline: isOnline,
                total: chargers.length,
                available: chargers.length - occupiedCount,
                occupied: occupiedCount,
              ),
              const SizedBox(height: 28),
              Text(
                'Conectores',
                style: TextStyle(
                  color: whiteColor(),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ...chargers.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _connectorCard(c, selected),
                ),
              ),
            ],
          ),
        ),
        _actionsBar(selected, selectedIsOccupied),
      ],
    );
  }

  // ================= ESTACIÓN (tarjeta destacada) =================
  Widget _stationCard(
    ModelCharger charger, {
    required bool? isOnline,
    required int total,
    required int available,
    required int occupied,
  }) {
    final station = charger.station!;
    final radius = BorderRadius.circular(28);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(deepForestGreen(), accentColor(), 0.1)!,
            deepForestGreen(),
          ],
        ),
        border: Border.all(color: accentColor().withValues(alpha: 0.25)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _ArcsPainter(color: accentColor())),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: accentColor(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.ev_station_outlined,
                          color: primaryColor(),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESTACIÓN',
                              style: TextStyle(
                                color: accentColor(),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              station.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: whiteColor(),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: grayInputColor(),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    station.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: grayInputColor(),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isOnline != null) ...[
                        const SizedBox(width: 8),
                        _onlineBadge(isOnline),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _stationStat(
                            '$total',
                            total == 1 ? 'Conector' : 'Conectores',
                            whiteColor(),
                          ),
                        ),
                        _statDivider(),
                        Expanded(
                          child: _stationStat(
                            '$available',
                            available == 1 ? 'Disponible' : 'Disponibles',
                            accentColor(),
                          ),
                        ),
                        _statDivider(),
                        Expanded(
                          child: _stationStat(
                            '$occupied',
                            occupied == 1 ? 'Ocupado' : 'Ocupados',
                            errorColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stationStat(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: grayInputColor(), fontSize: 13)),
      ],
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 34, color: Colors.white12);

  Widget _onlineBadge(bool isOnline) {
    final color = isOnline ? accentColor() : errorColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'En línea' : 'Fuera de línea',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= CONECTORES =================
  Widget _connectorCard(ModelCharger charger, ModelCharger selected) {
    final bool isOccupied = _isOccupied(charger);
    final bool isSelected =
        !isOccupied && charger.connectorId == selected.connectorId;
    final Color statusColor = isOccupied ? errorColor() : accentColor();
    final radius = BorderRadius.circular(22);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: radius,
        color:
            isOccupied
                ? errorColor().withValues(alpha: 0.08)
                : isSelected
                ? accentColor().withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.03),
        border: Border.all(
          color:
              isOccupied
                  ? errorColor().withValues(alpha: 0.3)
                  : isSelected
                  ? accentColor()
                  : Colors.white.withValues(alpha: 0.08),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: accentColor().withValues(alpha: 0.18),
                    blurRadius: 18,
                  ),
                ]
                : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap:
                isOccupied
                    ? null
                    : () => setState(
                      () => _selectedConnectorId = charger.connectorId,
                    ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color:
                              isOccupied
                                  ? errorColor().withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: ConnectorTypeIcon(
                            icon: charger.connectorType?.icon,
                            color: statusColor,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _connectorLabel(charger),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    isOccupied
                                        ? Color.lerp(
                                          whiteColor(),
                                          errorColor(),
                                          0.25,
                                        )
                                        : whiteColor(),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _typeName(charger),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: grayInputColor(),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _price(charger),
                            style: TextStyle(
                              color:
                                  isOccupied
                                      ? errorColor().withValues(alpha: 0.6)
                                      : accentColor(),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/ kWh',
                            style: TextStyle(
                              color: grayInputColor(),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      _connectorIndicator(
                        isOccupied: isOccupied,
                        isSelected: isSelected,
                      ),
                    ],
                  ),

                  // Ficha técnica solo del conector elegido.
                  if (isSelected) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _specBox(
                            'Potencia',
                            '${charger.powerKw.toStringAsFixed(1)} kW',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _specBox(
                            'Voltaje',
                            '${charger.voltage.toStringAsFixed(1)} V',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _specBox(
                            'Corriente',
                            '${charger.intensity.toStringAsFixed(1)} A',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _specBox('Cargador', charger.typeCharger),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _connectorIndicator({
    required bool isOccupied,
    required bool isSelected,
  }) {
    if (isOccupied) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: errorColor().withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.lock_outline, color: errorColor(), size: 18),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? accentColor() : Colors.transparent,
        border: Border.all(
          color: isSelected ? accentColor() : Colors.white24,
          width: 1.5,
        ),
      ),
      child:
          isSelected
              ? Icon(Icons.check, color: primaryColor(), size: 18)
              : null,
    );
  }

  Widget _specBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: grayInputColor(), fontSize: 12),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: whiteColor(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ACCIONES =================
  Widget _actionsBar(ModelCharger selected, bool selectedIsOccupied) {
    final summaryColor = selectedIsOccupied ? errorColor() : grayInputColor();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selectedIsOccupied ? Icons.lock_outline : Icons.bolt,
                color: selectedIsOccupied ? errorColor() : accentColor(),
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  selectedIsOccupied
                      ? '${_connectorLabel(selected)} ocupado'
                      : '${_connectorLabel(selected)} · '
                          '${_typeName(selected)} · ${_price(selected)} / kWh',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: summaryColor, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _actionPill(
                  label: 'Reescanear',
                  icon: Icons.qr_code_scanner,
                  filled: false,
                  onTap: () => _scanQr(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: _actionPill(
                  label: 'Iniciar carga',
                  icon: Icons.bolt,
                  filled: true,
                  onTap:
                      selectedIsOccupied ? null : () => _createOrder(selected),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionPill({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    final Color background =
        filled
            ? (enabled ? accentColor() : Colors.white.withValues(alpha: 0.08))
            : Colors.transparent;
    final Color foreground =
        filled ? (enabled ? primaryColor() : grayInputColor()) : whiteColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow:
            filled && enabled
                ? [
                  BoxShadow(
                    color: accentColor().withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: background,
        shape: StadiumBorder(
          side:
              filled
                  ? BorderSide.none
                  : BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: filled ? foreground : accentColor(),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //? ================= WIDGETS =================
  Widget openScanner() {
    return InkWell(
      onTap: _scanQr,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔵 Marco de escaneo con ícono principal
              _ScanFrame(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: deepForestGreen(),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor().withValues(alpha: 0.28),
                        blurRadius: 26,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 54,
                    color: accentColor(),
                  ),
                ),
              ),

              const SizedBox(height: 28),
              // 📝 Título
              LabelTitle(
                title: 'Escanea un código QR',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                textColor: whiteColor(),
                alignment: Alignment.center,
              ),

              const SizedBox(height: 8),

              // 🧾 Subtexto
              LabelTitle(
                title: 'Escanea el código QR de la estacion de carga',
                fontSize: 13,
                textColor: grayInputColor(),
                alignment: Alignment.center,
              ),

              const SizedBox(height: 32),

              // 🔘 Botón mejorado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: deepForestGreen(),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: accentColor().withValues(alpha: 0.35),
                  ),
                ),
                child: LabelIconTitle(
                  icon: Icons.camera_alt_outlined,
                  title: 'Abrir cámara',
                  alignment: Alignment.center,
                  fontSize: 14,
                  iconColor: accentColor(),
                  textColor: accentColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= METHODS =================
  bool isValidMongoId(String id) {
    final regex = RegExp(r'^[a-fA-F0-9]{24}$');
    return regex.hasMatch(id);
  }

  Future<void> _createOrder(ModelCharger charger) async {
    final provider = context.read<FinanceProvider>();

    Map<String, dynamic> order = {
      "platformBuy": "APP",
      "pricePerKwh": double.parse(
        charger.priceWithTipeConnector.toStringAsFixed(2),
      ),
      "kWhCharged": 0,
      "tax": 0,
      "subtotal": 0,
      "total": 0,
      "meterStart": 0,
      "meterStop": 0,
      "kWhDelivered": 0,
      "user": Preferences().getUser()?.id,
      "stations": charger.station!.id,
      "charger": charger.id,
      "cpId": charger.code,
      "connectorId": charger.connectorId,
      "country": charger.station!.country.id,
      "administrator": charger.station!.administrator,
    };

    final (statusCode, orderId) = await provider.postOrder(order);

    if (statusCode == 201) {
      if (!mounted) return;
      showPopUpWithChildren(
        context: context,
        title: 'Pago exitoso',
        subTitle: 'Su pago ha sido procesado correctamente.',
        textButton: 'Aceptar',
        onSubmit: () {
          // Al presionar "Aceptar": carga la orden activa. PageOptCharger
          // (que envuelve esta pantalla en la pestaña "Cargar") lo
          // detecta y cambia automáticamente de PageScanQr a PageCharger
          // — el mismo mecanismo reactivo que ya se usa para volver a
          // PageScanQr cuando la carga finaliza.
          //
          // Se usa directo el _id que ya devolvió el POST /orders (orderId)
          // en vez de "adivinar" con status: PENDING — sin ninguna ventana
          // de carrera posible (antes, si find/one llegaba a no encontrar
          // nada todavía, se volvía en silencio al escáner sin conectar
          // el socket). Si por algún motivo no vino orderId, se cae al
          // comportamiento anterior como respaldo.
          if (orderId != null) {
            context.read<ChargerProvider>().getOrderData({'id': orderId});
          } else {
            context.read<ChargerProvider>().getOrderData({'status': "PENDING"});
          }
        },
      );
    } else {
      if (!mounted) return;
      String errorMsj = '';

      switch (statusCode) {
        case -1:
          errorMsj = 'Ya se está procesando su solicitud, espere un momento.';
          break;
        case 400:
          errorMsj = 'No se encontro su billetera virtual.';
          break;
        case 409:
          errorMsj = 'No tiene saldo suficiente en su billetera virtual.';
          break;
        case 403:
          errorMsj = 'La estacion de carga no está disponible.';
          break;
        case 404:
          errorMsj = 'No se encontro la estacion de carga.';
          break;
        case 410:
          errorMsj =
              'El saldo de la billetera virtual es insuficiente para esta recarga.';
          break;
        case 500:
          errorMsj =
              'Error del servidor. Por favor, inténtelo de nuevo más tarde.';
          break;
        case 503:
          errorMsj =
              'El cargador no respondió a tiempo al iniciar la carga. '
              'Verifica que esté bien conectado e inténtalo de nuevo.';
          break;
        default:
          errorMsj =
              errorMsj =
                  'La estacion de carga no esta conectado al vehículo o hubo un error en el proceso de recarga.';
      }

      showSnackbar(context, errorMsj, SnackbarStatus.error);
    }
  }
}

/// Marco decorativo tipo "escáner" (4 esquinas resaltadas en el color de
/// acento) alrededor del ícono central de `openScanner()`. Puramente
/// visual — no agrega gestos ni lógica propia, así que no interfiere con
/// el `InkWell` que ya maneja el tap en el widget padre.
class _ScanFrame extends StatelessWidget {
  final Widget child;

  const _ScanFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    final color = accentColor().withValues(alpha: 0.6);
    const double size = 156;
    const double corner = 30;
    const double thickness = 3;
    const double radius = 16;

    Widget bracket({required bool top, required bool left}) {
      return Positioned(
        top: top ? 0 : null,
        bottom: top ? null : 0,
        left: left ? 0 : null,
        right: left ? null : 0,
        child: Container(
          width: corner,
          height: corner,
          decoration: BoxDecoration(
            border: Border(
              top:
                  top
                      ? BorderSide(color: color, width: thickness)
                      : BorderSide.none,
              bottom:
                  !top
                      ? BorderSide(color: color, width: thickness)
                      : BorderSide.none,
              left:
                  left
                      ? BorderSide(color: color, width: thickness)
                      : BorderSide.none,
              right:
                  !left
                      ? BorderSide(color: color, width: thickness)
                      : BorderSide.none,
            ),
            borderRadius: BorderRadius.only(
              topLeft:
                  top && left ? const Radius.circular(radius) : Radius.zero,
              topRight:
                  top && !left ? const Radius.circular(radius) : Radius.zero,
              bottomLeft:
                  !top && left ? const Radius.circular(radius) : Radius.zero,
              bottomRight:
                  !top && !left ? const Radius.circular(radius) : Radius.zero,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          bracket(top: true, left: true),
          bracket(top: true, left: false),
          bracket(top: false, left: true),
          bracket(top: false, left: false),
        ],
      ),
    );
  }
}

/// Arcos concéntricos decorativos desde la esquina inferior derecha.
class _ArcsPainter extends CustomPainter {
  final Color color;

  const _ArcsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = color.withValues(alpha: 0.12);

    final center = Offset(size.width, size.height);
    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, size.height * 0.3 * i, paint);
    }
  }

  @override
  bool shouldRepaint(_ArcsPainter oldDelegate) => oldDelegate.color != color;
}
