import 'package:ecored_app/src/core/models/nuvei_model.dart';
import 'package:ecored_app/src/core/models/payment_model.dart';
import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PageScanQr extends StatefulWidget {
  const PageScanQr({super.key});

  @override
  State<PageScanQr> createState() => _PageScanQrState();
}

class _PageScanQrState extends State<PageScanQr> {
  ModelCharger? charger;
  PaymentModel? paymentesMethod;

  final double tax = 1.5;
  final TextEditingController kWhCtrl = TextEditingController();
  final TextEditingController cashCtrl = TextEditingController(text: "5");
  final ValueNotifier<String> qrCodeNotifier = ValueNotifier<String>('');

  // ==================== CÁLCULOS ====================
  double get kWh {
    final kwh = double.tryParse(kWhCtrl.text) ?? 0;
    return kwh;
  }

  double get dinero {
    final dinero = double.tryParse(cashCtrl.text) ?? 5;
    return dinero;
  }

  double get subtotal {
    if (dinero > 0) return dinero;
    return charger != null ? kWh * charger!.priceWithTipeConnector : 0;
  }

  double get total => subtotal + tax;

  double get kWhFromDinero {
    return charger != null && charger!.priceWithTipeConnector > 0
        ? dinero / charger!.priceWithTipeConnector
        : 0;
  }

  double get dineroFromKWh {
    return charger != null ? kWh * charger!.priceWithTipeConnector : 0;
  }

  bool get recargaMinimaValida => dineroFromKWh >= 4.99;

  bool isValidMongoId(String id) {
    final regex = RegExp(r'^[a-fA-F0-9]{24}$');
    return regex.hasMatch(id);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      paymentesMethod = null;
      final financeProvider = context.read<FinanceProvider>();
      financeProvider.clearChargerData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = context.watch<FinanceProvider>();

    return Scaffold(
      backgroundColor: primaryColor(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: UtilSize.bottomPadding(),
          ),
          child: Column(
            children: [
              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LabelTitle(
                    title: 'Nueva recarga',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: accentColor(),
                      size: 28,
                    ),
                    onPressed: () async {
                      qrCodeNotifier.value = '';

                      try {
                        qrCodeNotifier.value = await showPopUpWithChildren(
                          context: context,
                          title: 'Scanner QR',
                          subTitle:
                              'Escanea el código QR para verificar el ticket',
                          textButton: 'Cancelar',
                          children: [BarCodeScanner(qrCode: qrCodeNotifier)],
                        );
                      } on PlatformException {
                        qrCodeNotifier.value =
                            'Failed to get platform version.';
                      }
                      if (!mounted) return;

                      if (qrCodeNotifier.value.isNotEmpty) {
                        final scannedData = qrCodeNotifier.value;
                        final scannedId =
                            scannedData.split('/scanner/').last.trim();

                        if (!isValidMongoId(scannedId)) {
                          showSnackbar(
                            context,
                            'Código QR inválido. Asegúrate de escanear un código válido.',
                            SnackbarStatus.error,
                          );
                          return;
                        }

                        await financeProvider.findOneCharger(scannedId);

                        if (financeProvider.chargerData != null) {
                          charger = financeProvider.chargerData!;

                          // Calculamos kWh automáticamente con el monto por defecto
                          final defaultAmount =
                              double.tryParse(cashCtrl.text) ?? 5;
                          kWhCtrl.text = (defaultAmount /
                                  charger!.priceWithTipeConnector)
                              .toStringAsFixed(2);

                          Logger.logDev(
                            'Charger encontrado: ${charger!.toJson()}',
                          );
                        } else {
                          qrCodeNotifier.value = '';
                          financeProvider.chargerData = null;
                          showSnackbar(
                            context,
                            'El cargador no existe',
                            SnackbarStatus.error,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),

              // ================= INSTRUCCIONES =================
              if (qrCodeNotifier.value.isEmpty ||
                  financeProvider.chargerData == null ||
                  financeProvider.errorMessage != null)
                Card(
                  color: Colors.white.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Para realizar una recarga, primero escanea el código QR del cargador. '
                      'Después de escanear, se mostrará la información del cargador y podrás proceder a recargar. '
                      'El monto mínimo permitido es de 5 dólares. Asegúrate de tener fondos suficientes.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

              // ================= CONTENIDO =================
              if (financeProvider.chargerData != null && charger != null)
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      spacing: 16,
                      children: [
                        SizedBox(height: 4),
                        CardStation(
                          title: charger!.station!.name,
                          details: [charger!.station!.address],
                        ),
                        _chargerCard(),
                        _energyInput(),
                        _summaryCard(),
                        PaymentSelector(
                          title: 'Seleccione método de pago',
                          type: PaymentSelectorType.card,
                          onSelected: (payment) {
                            paymentesMethod = payment;
                          },
                        ),
                        CustomButton(
                          textButton: 'Confirmar Recarga',
                          buttonColor: accentColor(),
                          textButtonColor: primaryColor(),
                          onPressed: () => _createOrder(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CHARGER CARD =================
  Widget _chargerCard() {
    return Container(
      decoration: cardDecoration(shadow: true),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: accentColor().withValues(alpha: 0.2),
                child: Icon(Icons.flash_on, color: accentColor(), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  charger!.code,
                  style: TextStyle(
                    color: kWhiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: LabelTitle(
                  title: "\$${charger!.priceWithTipeConnector}/kWh",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  textColor: kAccentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 1,
            crossAxisSpacing: 12,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 4.2,
            children: [
              LabelIconTitle(
                padding: false,
                textAlign: TextAlign.center,
                icon: Icons.bolt,
                iconColor: accentColor(),
                title: 'Potencia: ${charger!.powerKw} kW',
                textColor: whiteColor(),
                fontWeight: FontWeight.bold,
              ),
              LabelIconTitle(
                padding: false,
                textAlign: TextAlign.center,
                icon: Icons.usb,
                iconColor: accentColor(),
                title: 'Conexión: ${charger!.typeConnection}',
                textColor: whiteColor(),
                fontWeight: FontWeight.bold,
              ),
              LabelIconTitle(
                padding: false,
                textAlign: TextAlign.center,
                icon: Icons.battery_charging_full,
                iconColor: accentColor(),
                title: 'Voltaje: ${charger!.voltage} V',
                textColor: whiteColor(),
                fontWeight: FontWeight.bold,
              ),
              LabelIconTitle(
                padding: false,
                textAlign: TextAlign.center,
                icon: Icons.speed,
                iconColor: accentColor(),
                title: 'Intensidad: ${charger!.intensity} A',
                textColor: whiteColor(),
                fontWeight: FontWeight.bold,
              ),
              LabelIconTitle(
                padding: false,
                textAlign: TextAlign.center,
                icon: Icons.settings,
                iconColor: accentColor(),
                title: 'Tipo: ${charger!.typeCharger}',
                textColor: whiteColor(),
                fontWeight: FontWeight.bold,
              ),
              LabelIconTitle(
                padding: false,
                textAlign: TextAlign.center,
                icon: Icons.cable,
                iconColor: accentColor(),
                title: 'Formato: ${charger!.format}',
                textColor: whiteColor(),
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= INPUT =================
  Widget _energyInput() {
    return Container(
      decoration: cardDecoration(shadow: true),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: CustomInput(
                  hintText: 'Monto',
                  textEditingController: cashCtrl,
                  textInputType: TextInputType.number,
                  filledColor: greyColorWithTransparency(),
                  borderColor: Colors.transparent,
                  validator: null,
                  onChanged: (val) {
                    setState(() {
                      if (val.isNotEmpty && charger != null) {
                        final d = double.tryParse(val) ?? 0;
                        kWhCtrl.text = (d / charger!.priceWithTipeConnector)
                            .toStringAsFixed(2);
                      } else {
                        kWhCtrl.text = '';
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: CustomInput(
                  hintText: 'kWh',
                  textEditingController: kWhCtrl,
                  textInputType: TextInputType.number,
                  filledColor: greyColorWithTransparency(),
                  validator: null,
                  onChanged: (val) {
                    setState(() {
                      if (val.isNotEmpty && charger != null) {
                        final k = double.tryParse(val) ?? 0;
                        cashCtrl.text = (k * charger!.priceWithTipeConnector)
                            .toStringAsFixed(2);
                      } else {
                        cashCtrl.text = '';
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!recargaMinimaValida)
            Text(
              "La recarga mínima es \$5",
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      decoration: cardDecoration(shadow: true),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LabelRowText(label: 'Subtotal', value: subtotal.toStringAsFixed(2)),
          LabelRowText(label: 'Impuestos', value: tax.toStringAsFixed(2)),
          Divider(color: greyColorWithTransparency(), height: 32),
          LabelRowText(
            label: 'TOTAL',
            value: total.toStringAsFixed(2),
            fontSize: 18,
            titleColor: accentColor(),
            subtitleColor: accentColor(),
          ),
        ],
      ),
    );
  }

  Future<void> _createOrder() async {
    final provider = context.read<FinanceProvider>();

    if (paymentesMethod == null) {
      showSnackbar(
        context,
        'Seleccione un método de pago',
        SnackbarStatus.waiting,
      );
      return;
    }

    Map<String, dynamic> order = {
      "platformBuy": "APP",
      "kWhCharged": kWh,
      "tax": tax,
      "subtotal": subtotal,
      "total": total,
      "user": Preferences().getUser()?.id,
      "stations": charger?.station!.id,
      "charger": charger?.id,
      "cpId": charger?.code,
      "connectorId": charger?.connectorId,
      "payment": paymentesMethod?.id,
      "country": charger?.station!.country!.id,
      "administrator": charger?.station!.administrator,
    };

    switch (paymentesMethod?.name.toUpperCase()) {
      case 'NUVEI':
        final devReference =
            "REF${Preferences().getUser()!.id}-${DateTime.now().millisecondsSinceEpoch}";
        final body = ModelNuvei(
          userId: Preferences().getUser()!.id,
          email: Preferences().getUser()!.email,
          phone: Preferences().getUser()!.phone,
          description: "Recarga de saldo Ecored",
          amount: total,
          vat: 0,
          devReference: devReference,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => PaymentesNuvei(
                  status: PaymentStatus.order,
                  bodyNuvei: body,
                  bodyEcored: order,
                ),
          ),
        );
        break;
      case "WALLET":
        await provider.getWalletData({'user': Preferences().getUser()?.id});
        final walletBalance = provider.financeData;
        if (walletBalance == null) {
          showSnackbar(
            context,
            'No se pudo obtener el balance de la wallet',
            SnackbarStatus.error,
          );
        } else if (walletBalance.balance >= total) {
          final response = await provider.postOrder(order);
          if (response == 201) {
            if (!mounted) return;
            showPopUpWithChildren(
              context: context,
              title: 'Pago exitoso',
              subTitle: 'Su pago ha sido procesado correctamente.',
              textButton: 'Aceptar',
              onSubmit: () {
                Navigator.pop(context, true);
                final provider = context.read<FinanceProvider>();
                provider.getWalletData({'user': Preferences().getUser()?.id});
                provider.getTransactionData({
                  'user': Preferences().getUser()?.id,
                });
              },
            );
          } else {
            showSnackbar(
              context,
              'Pago aprobado, pero falló Ecored. Código de respuesta: $response',
              SnackbarStatus.error,
            );
          }
        } else {
          showSnackbar(
            context,
            'Fondos insuficientes en tu billetera virtual',
            SnackbarStatus.waiting,
          );
        }
        break;
      default:
        debugPrint('método de pago no soportado');
    }
  }
}

/*
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class PageScanQr extends StatefulWidget {
  const PageScanQr({super.key});

  @override
  State<PageScanQr> createState() => _PageScanQrState();
}

class _PageScanQrState extends State<PageScanQr> {
  final Map<String, dynamic> charger = {
    "_id": "696aed28e2e674004780a7dc",
    "status": "AVAILABLE",
    "code": "AC1-1768615208178-74004780A7D8",
    "typeConnection": "CCS2",
    "powerKw": 24,
    "intensity": 5,
    "voltage": 12,
    "format": "CABLE",
    "typeCharger": "AC1",
    "priceWithTipeConnector": 0.33,
    "station": {
      "_id": "696aed28e2e674004780a7d8",
      "name": "Estación Central",
      "location": "Calle Falsa 123",
    },
  };

  final TextEditingController kWhCtrl = TextEditingController(text: "5");
  final TextEditingController dineroCtrl = TextEditingController();

  final double tax = 1.5;

  // Colores locales
  static const Color _cardColor = Color(0xff111111);
  static const Color _borderColor = Color(0xff2A2A2A);
  static const Color _textSecondary = Color(0xffB0B0B0);
  static const Color _inputColor = Color(0xff1C1C1C);

  // ==================== CÁLCULOS ====================
  double get kWh {
    final kwh = double.tryParse(kWhCtrl.text) ?? 0;
    return kwh;
  }

  double get dinero {
    final dinero = double.tryParse(dineroCtrl.text) ?? 0;
    return dinero;
  }

  double get subtotal {
    if (dinero > 0) return dinero;
    return kWh * charger["priceWithTipeConnector"];
  }

  double get total => subtotal + tax;

  double get kWhFromDinero {
    return charger["priceWithTipeConnector"] > 0
        ? dinero / charger["priceWithTipeConnector"]
        : 0;
  }

  double get dineroFromKWh {
    return kWh * charger["priceWithTipeConnector"];
  }

  bool get recargaMinimaValida => dineroFromKWh >= 5;

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _stationCard(),
                    const SizedBox(height: 16),
                    _chargerCard(),
                    const SizedBox(height: 20),
                    _energyInput(),
                    const SizedBox(height: 20),
                    _summaryCard(),
                    const SizedBox(height: 32),
                    _confirmButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nueva recarga",
                style: TextStyle(
                  color: kWhiteColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.ev_station, color: kAccentColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    charger["status"],
                    style: TextStyle(
                      color: kAccentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.qr_code_scanner, color: kAccentColor, size: 28),
        ],
      ),
    );
  }

  // ================= STATION CARD =================
  Widget _stationCard() {
    final station = charger["station"];
    return Container(
      decoration: _cardDecoration(shadow: true),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.location_on, color: kAccentColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station["name"],
                  style: TextStyle(
                    color: kWhiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  station["location"],
                  style: TextStyle(color: _textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= CHARGER CARD =================
  Widget _chargerCard() {
    return Container(
      decoration: _cardDecoration(shadow: true),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: kAccentColor.withOpacity(0.2),
                child: Icon(Icons.flash_on, color: kAccentColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  charger["code"],
                  style: TextStyle(
                    color: kWhiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                "\$${charger["priceWithTipeConnector"]}/kWh",
                style: TextStyle(
                  color: kAccentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 3.2,
            children: [
              _modernInfoCard(
                Icons.bolt,
                "Potencia",
                "${charger["powerKw"]} kW",
              ),
              _modernInfoCard(Icons.usb, "Conexión", charger["typeConnection"]),
              _modernInfoCard(
                Icons.battery_charging_full,
                "Voltaje",
                "${charger["voltage"]} V",
              ),
              _modernInfoCard(
                Icons.speed,
                "Intensidad",
                "${charger["intensity"]} A",
              ),
              _modernInfoCard(Icons.settings, "Tipo", charger["typeCharger"]),
              _modernInfoCard(Icons.cable, "Formato", charger["format"]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modernInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _inputColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: kAccentColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(
                color: kWhiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INPUT =================
  Widget _energyInput() {
    return Container(
      decoration: _cardDecoration(shadow: true),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Campo kWh
          TextField(
            controller: kWhCtrl,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              setState(() {
                if (val.isNotEmpty) {
                  final k = double.tryParse(val) ?? 0;
                  dineroCtrl.text = (k * charger["priceWithTipeConnector"])
                      .toStringAsFixed(2);
                } else {
                  dineroCtrl.text = '';
                }
              });
            },
            style: TextStyle(color: kWhiteColor),
            decoration: InputDecoration(
              labelText: "Energía a cargar",
              labelStyle: TextStyle(color: _textSecondary),
              suffixText: "kWh",
              suffixStyle: TextStyle(color: _textSecondary),
              prefixIcon: Icon(Icons.bolt, color: kAccentColor),
              filled: true,
              fillColor: _inputColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (!recargaMinimaValida)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "La recarga mínima es \$5",
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),

          const SizedBox(height: 12),

          // Campo dinero
          TextField(
            controller: dineroCtrl,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              setState(() {
                if (val.isNotEmpty) {
                  final d = double.tryParse(val) ?? 0;
                  kWhCtrl.text = (d / charger["priceWithTipeConnector"])
                      .toStringAsFixed(2);
                } else {
                  kWhCtrl.text = '';
                }
              });
            },
            style: TextStyle(color: kWhiteColor),
            decoration: InputDecoration(
              labelText: "Monto a recargar",
              labelStyle: TextStyle(color: _textSecondary),
              suffixText: "\$",
              suffixStyle: TextStyle(color: _textSecondary),
              prefixIcon: Icon(Icons.attach_money, color: kAccentColor),
              filled: true,
              fillColor: _inputColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summaryCard() {
    return Container(
      decoration: _cardDecoration(shadow: true),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _row("Subtotal", subtotal),
          _row("Impuestos", tax),
          Divider(color: _borderColor, height: 32),
          _row("TOTAL", total, isTotal: true),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? kWhiteColor : _textSecondary,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            "\$${value.toStringAsFixed(2)}",
            style: TextStyle(
              color: isTotal ? kAccentColor : kWhiteColor,
              fontSize: isTotal ? 20 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _confirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentColor,
          foregroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          if (!recargaMinimaValida) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text(
                  "La recarga mínima es \$5",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
            return;
          }
          _createOrder();
        },
        child: const Text(
          "CONFIRMAR RECARGA",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ================= HELPERS =================
  BoxDecoration _cardDecoration({bool shadow = false}) {
    return BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _borderColor),
      boxShadow:
          shadow
              ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ]
              : null,
    );
  }

  Future<void> _createOrder() async {
    final provider = context.read<FinanceProvider>();

    Map<String, dynamic> order = {
      "platformBuy": "APP",
      "kWhCharged": kWh,
      "tax": tax,
      "subtotal": subtotal,
      "total": total,
      "user": Preferences().getUser()?.id,
      "stations": charger["station"]["_id"],
      "charger": charger["_id"],
      "country": "689543d901241bbba2d6e8e6",
      "payment": "689a67ef29035fc0c5fe5acc",
      "administrator": "688fd96fd9b0281c0160f8e2",
      "recharge": "6971ae69c195a239d2dca1f8",
    };

    debugPrint("ORDER JSON:");
    debugPrint(order.toString());

    final response = await provider.postOrder(order);

    if (response == 201) {
      if (!mounted) return;
      showPopUpWithChildren(
        context: context,
        title: 'Pago exitoso',
        subTitle: 'Su pago ha sido procesado correctamente.',
        textButton: 'Aceptar',
        onSubmit: () {
          Navigator.pop(context, true); // Retorna al screen anterior

          // Refresca los datos de la wallet y transacciones
          final provider = context.read<FinanceProvider>();
          provider.getWalletData({'user': Preferences().getUser()?.id});
          provider.getTransactionData({'user': Preferences().getUser()?.id});
        },
      );
    } else {
      showSnackbar(
        context,
        'Pago aprobado, pero falló Ecored. Código de respuesta: $response',
        SnackbarStatus.error,
      );
    }
  }
}

*/
