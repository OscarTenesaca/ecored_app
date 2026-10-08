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

  Widget _chargerView(List<ModelCharger> chargers, ModelCharger selected) {
    final bool selectedIsOccupied = selected.connectorStatus == 'Charging';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          spacing: 16,
          children: [
            const SizedBox(height: 4),

            _stationStrip(selected, isOnline: isOnline),

            // Solo tiene sentido elegir cuando hay más de un conector.
            if (chargers.length > 1) _connectorSelector(chargers, selected),

            _specsSection(selected),

            Row(
              spacing: 12,
              children: [
                Flexible(
                  child: CustomButton(
                    textButton: 'REESCANEAR',
                    buttonColor: grayInputColor(),
                    textButtonColor: accentColor(),
                    onPressed: () => _scanQr(),
                  ),
                ),
                Flexible(
                  child: CustomButton(
                    textButton: 'INICIAR CARGA',
                    buttonColor: accentColor(),
                    textButtonColor: primaryColor(),
                    onPressed:
                        selectedIsOccupied
                            ? null
                            : () => _createOrder(selected),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= SELECCIÓN DE CONECTOR (pestañas + tarjetas) =================
  Widget _connectorSelector(
    List<ModelCharger> chargers,
    ModelCharger selected,
  ) {
    final available =
        chargers.where((c) => c.connectorStatus != 'Charging').toList();
    final occupied =
        chargers.where((c) => c.connectorStatus == 'Charging').toList();
    final visible = _showOccupied ? occupied : available;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.ev_station_rounded, color: accentColor(), size: 18),
            const SizedBox(width: 8),
            LabelTitle(
              title: 'Selecciona un conector',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              textColor: whiteColor(),
              padding: false,
            ),
          ],
        ),
        const SizedBox(height: 3),
        LabelTitle(
          title: 'Elige el conector que deseas usar para iniciar la carga.',
          fontSize: 11,
          textColor: grayInputColor(),
          padding: false,
        ),
        const SizedBox(height: 10),
        _connectorTabs(available.length, occupied.length),
        const SizedBox(height: 10),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: LabelTitle(
              title:
                  _showOccupied
                      ? 'No hay conectores ocupados.'
                      : 'No hay conectores disponibles en este momento.',
              fontSize: 12,
              textColor: grayInputColor(),
              alignment: Alignment.center,
              padding: false,
            ),
          )
        else
          Column(
            spacing: 10,
            children: visible.map((c) => _connectorCard(c, selected)).toList(),
          ),
      ],
    );
  }

  Widget _connectorTabs(int availableCount, int occupiedCount) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              icon: Icons.ev_station_rounded,
              label: 'Disponibles',
              count: availableCount,
              color: accentColor(),
              selected: !_showOccupied,
              onTap: () => setState(() => _showOccupied = false),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _tabButton(
              icon: Icons.cancel_rounded,
              label: 'Ocupados',
              count: occupiedCount,
              color: errorColor(),
              selected: _showOccupied,
              onTap: () => setState(() => _showOccupied = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color fg = selected ? primaryColor() : grayInputColor();

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color:
                    selected
                        ? primaryColor().withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _connectorCard(ModelCharger charger, ModelCharger selected) {
    final bool isOccupied = charger.connectorStatus == 'Charging';
    final bool isSelected =
        !isOccupied && charger.connectorId == selected.connectorId;
    final Color statusColor = isOccupied ? errorColor() : accentColor();

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? accentColor() : const Color(0xff2A2A2A),
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: accentColor().withValues(alpha: 0.22),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
                : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.electrical_services_rounded,
              color: statusColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelTitle(
                  title: 'Conector ${charger.connectorId}',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  textColor: whiteColor(),
                  padding: false,
                ),
                const SizedBox(height: 3),
                LabelTitle(
                  title: charger.typeConnection,
                  fontSize: 11,
                  textColor: grayInputColor(),
                  padding: false,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // El chevron era puramente decorativo (la tarjeta entera ya es
          // tappeable) — en su lugar va el badge de disponibilidad.
          _connectorStatusBadge(isOccupied),
        ],
      ),
    );

    // Única regla de bloqueo: "Charging". Todo lo demás es seleccionable.
    if (isOccupied) {
      return Opacity(opacity: 0.55, child: card);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selectedConnectorId = charger.connectorId),
      child: card,
    );
  }

  Widget _connectorStatusBadge(bool isOccupied) {
    final color = isOccupied ? errorColor() : accentColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOccupied ? Icons.cancel_rounded : Icons.circle,
            size: isOccupied ? 12 : 8,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            isOccupied ? 'Ocupado' : 'Disponible',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
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

  // ================= ESTACIÓN (tarjeta destacada) =================
  Widget _stationStrip(ModelCharger charger, {bool? isOnline}) {
    final station = charger.station!;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: cardDecoration(shadow: true),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor().withValues(alpha: 0.14),
              border: Border.all(color: accentColor().withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.location_on_rounded,
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
                  title: station.name,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  textColor: whiteColor(),
                  padding: false,
                ),
                const SizedBox(height: 3),
                // station.address y el badge "En línea" van en la misma
                // fila para ahorrar una línea de alto en la tarjeta.
                Row(
                  children: [
                    Icon(
                      Icons.place_rounded,
                      size: 13,
                      color: grayInputColor(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: LabelTitle(
                        title: station.address,
                        fontSize: 12,
                        textColor: grayInputColor(),
                        padding: false,
                        maxLines: 1,
                      ),
                    ),
                    if (isOnline != null) ...[
                      const SizedBox(width: 8),
                      _onlineBadge(isOnline),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _onlineBadge(bool isOnline) {
    final color = isOnline ? accentColor() : errorColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 5),
          Text(
            isOnline ? 'En línea' : 'Fuera de línea',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ESPECIFICACIONES (ficha técnica) =================
  Widget _specsSection(ModelCharger charger) {
    return Container(
      decoration: cardDecoration(shadow: true),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: accentColor(), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: LabelTitle(
                  title: 'Especificaciones',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  textColor: whiteColor(),
                  padding: false,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accentColor().withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'Conector ${charger.connectorId}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor(),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 6),
          _specRow(
            Icons.attach_money,
            'Precio',
            '\$${((charger.priceWithTipeConnector * 100).truncate() / 100).toStringAsFixed(2)}/kWh',
          ),
          // _specRow(Icons.usb, 'Tipo de conexión', charger.typeConnection),
          _specRow(Icons.bolt, 'Potencia', '${charger.powerKw} kW'),
          _specRow(
            Icons.battery_charging_full,
            'Voltaje',
            '${charger.voltage} V',
          ),
          _specRow(Icons.speed, 'Intensidad', '${charger.intensity} A'),
          _specRow(
            Icons.settings,
            'Tipo de cargador',
            charger.typeCharger,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _specRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: isLast ? 0 : 0),
      child: Row(
        children: [
          Icon(icon, color: accentColor(), size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: LabelTitle(
              title: label,
              fontSize: 11,
              textColor: grayInputColor(),
              padding: false,
            ),
          ),

          LabelTitle(
            title: value,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            textColor: whiteColor(),
            padding: false,
          ),
        ],
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
            context.read<ChargerProvider>().getOrderData({
              'status': "PENDING",
            });
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
