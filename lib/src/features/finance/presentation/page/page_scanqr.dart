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

      final scannedId = scannedData.split('/scanner/').last.trim();

      await financeProvider.findOneCharger(scannedId);

      if (!mounted) return;

      final fetchedCharger = financeProvider.chargerData;
      if (fetchedCharger == null) {
        showSnackbar(
          context,
          financeProvider.errorMessage ??
              'No se pudo obtener la información del cargador.',
          SnackbarStatus.error,
        );
      } else if (fetchedCharger.station == null) {
        showSnackbar(
          context,
          'La estación asociada a este cargador ya no está disponible.',
          SnackbarStatus.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = context.watch<FinanceProvider>();
    final ModelCharger? charger = financeProvider.chargerData;

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

            if (charger == null || charger.station == null) {
              //mostrar la pantalla para escanear el QR
              return openScanner();
            }

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    spacing: 16,
                    children: [
                      const SizedBox(height: 4),

                      // Momento "hero": lo primero que se ve es el cargador
                      // escaneado, con su estado y precio como protagonistas.
                      _heroSummary(charger),

                      _stationStrip(charger),

                      _specsSection(charger),

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
                              onPressed: () => _createOrder(charger),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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

  // ================= HERO: cargador escaneado =================
  // Tarjeta protagonista con degradado, ícono circular con glow, estado
  // y precio en grande — el "momento" principal de la pantalla.
  Widget _heroSummary(ModelCharger charger) {
    final statusColor = stationStatusColor(charger.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [deepForestGreen(), primaryColor()],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor().withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor().withValues(alpha: 0.14),
              border: Border.all(color: accentColor(), width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: accentColor().withValues(alpha: 0.3),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.ev_station_rounded,
              color: accentColor(),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelTitle(
                  title: charger.code,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  textColor: whiteColor(),
                  padding: false,
                ),
                const SizedBox(height: 6),
                _statusPill(charger.status, statusColor),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              LabelTitle(
                title: "\$${charger.priceWithTipeConnector.toStringAsFixed(2)}",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                textColor: accentColor(),
                padding: false,
              ),
              LabelTitle(
                title: '/kWh',
                fontSize: 11,
                textColor: grayInputColor(),
                padding: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          LabelTitle(
            title: stationStatusLabel(status),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            textColor: color,
            padding: false,
          ),
        ],
      ),
    );
  }

  // ================= ESTACIÓN (franja compacta) =================
  Widget _stationStrip(ModelCharger charger) {
    final station = charger.station!;
    final phone = '${station.prefixCode} ${station.phone}'.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(shadow: true),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor().withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.location_on, color: accentColor(), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelTitle(
                  title: station.name,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  textColor: whiteColor(),
                  padding: false,
                ),
                const SizedBox(height: 2),
                LabelTitle(
                  title: station.address,
                  fontSize: 12,
                  textColor: grayInputColor(),
                  padding: false,
                ),
                if (station.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  LabelTitle(
                    title: phone,
                    fontSize: 12,
                    textColor: grayInputColor(),
                    padding: false,
                  ),
                ],
              ],
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: accentColor(), size: 20),
              const SizedBox(width: 8),
              LabelTitle(
                title: 'Especificaciones',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                textColor: whiteColor(),
                padding: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 6),
          _specRow(Icons.power, 'Conector', '#${charger.connectorId}'),
          _specRow(Icons.usb, 'Tipo de conexión', charger.typeConnection),
          _specRow(Icons.bolt, 'Potencia', '${charger.powerKw} kW'),
          _specRow(
            Icons.battery_charging_full,
            'Voltaje',
            '${charger.voltage} V',
          ),
          _specRow(Icons.speed, 'Intensidad', '${charger.intensity} A'),
          _specRow(Icons.settings, 'Tipo de cargador', charger.typeCharger),
          _specRow(Icons.cable, 'Formato', charger.format, isLast: true),
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
              fontSize: 13,
              textColor: grayInputColor(),
              padding: false,
            ),
          ),
          LabelTitle(
            title: value,
            fontSize: 13,
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

    final response = await provider.postOrder(order);

    if (response == 201) {
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
          context.read<ChargerProvider>().getOrderData({
            'status': "PENDING",
            "operationStatus": "CHARGING",
          });
        },
      );
    } else {
      if (!mounted) return;
      String errorMsj = '';

      switch (response) {
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
