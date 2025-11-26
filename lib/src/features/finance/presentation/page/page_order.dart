import 'dart:developer';

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
  void initState() {
    Future.delayed(Duration.zero, () {
      final ModelTransaction args =
          ModalRoute.of(context)?.settings.arguments as ModelTransaction;
      _loadData(args);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final ModelOrder? orderData = provider.orderData;
    log('orderData: ${orderData!.toJson().toString()}');

    return Scaffold(
      // backgroundColor: const Color(0xFF0A0A0A),
      backgroundColor: primaryColor(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: UtilSize.appBarHeight() + 50,
          left: 18,
          right: 18,
        ),
        child: Column(
          children: [
            /// -------- CARD PRINCIPAL -----------
            CardSummary(
              titleColor: grayInputColor(),
              status: orderData.status,
              subtitle: '- \$${orderData.total}',
              subtitleColor: Colors.red,
              leftText: orderData.country.name,
              leftTextColor: grayInputColor(),
              rightText: orderData.createdAt,
              rightTextColor: Colors.white.withOpacity(0.65),
            ),

            /// -------- GRID DE INFORMACIÓN ------
            _infoGrid(orderData),

            CardTitleDescription(
              title: 'Estación',
              icon: Icons.ev_station_rounded,
              rows: [
                LabelRowText(label: "Nombre", value: orderData.stations.name),
                LabelRowText(
                  label: "Dirección",
                  value: orderData.stations.address,
                ),
                LabelRowText(
                  label: "Teléfono",
                  value:
                      '${orderData.stations.prefixCode} ${orderData.stations.phone}',
                ),
              ],
            ),

            CardTitleDescription(
              title: 'Pago',
              icon: Icons.credit_card_rounded,
              rows: [
                LabelRowText(
                  label: "Método",
                  value:
                      (orderData.payment.name.toLowerCase() == 'nuvei')
                          ? 'Pago con tarjeta'
                          : orderData.payment.name,
                ),
                LabelRowText(
                  label: "Subtotal",
                  value: "\$${orderData.subtotal}",
                ),
                LabelRowText(label: "Impuesto", value: "\$${orderData.tax}"),
                LabelRowText(
                  label: "Descuento",
                  value: "\$${orderData.discount}",
                ),
                LabelRowText(
                  label: "Total",
                  value:
                      "\$${(orderData.discount == 0) ? orderData.total : orderData.discountTotal}",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData(ModelTransaction args) async {
    final provider = context.read<FinanceProvider>();
    await provider.getOrderData({'id': args.order});
  }
}

//
// ---------------- GRID PRINCIPAL ----------------
//
Widget _infoGrid(ModelOrder order) {
  return GridView.count(
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 14,
    mainAxisSpacing: 14,
    shrinkWrap: true,
    childAspectRatio: 1.35,
    children: [
      _infoCard(
        Icons.charging_station_rounded,
        "Carga",
        "${order.kWhCharged} kWh",
      ),
      _infoCard(
        Icons.electric_bolt_rounded,
        "Tipo conector",
        order.charger.typeConnection,
      ),
      _infoCard(Icons.phone_android, "Plataforma", order.platformBuy),
      _infoCard(Icons.location_on, "Pais", order.country.code),
    ],
  );
}

//
// ----------- TARJETA PEQUEÑA DE GRID -----------
//
Widget _infoCard(IconData icon, String label, String value) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: glass(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 14),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13.5,
          ),
        ),
      ],
    ),
  );
}
