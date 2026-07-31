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
              child: Text(
                'No se pudo cargar la orden.',
                style: TextStyle(color: whiteColor().withValues(alpha: 0.8)),
              ),
            );
          }

          final orderData = snapshot.data!;

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
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: UtilSize.appBarHeight() + 50,
                left: 18,
                right: 18,
              ),
              children: [
                CardSummary(
                  titleColor: grayInputColor(),
                  status: orderData.status,
                  subtitle: '- \$${orderData.total.toStringAsFixed(2)}',
                  subtitleColor: errorColor(),
                  leftText: orderData.country.name,
                  leftTextColor: grayInputColor(),
                  rightText: orderData.createdAt,
                  rightTextColor: whiteColor().withValues(alpha: 0.65),
                ),

                const SizedBox(height: 18),

                _infoGrid(orderData),

                const SizedBox(height: 4),

                CardTitleDescription(
                  title: 'Estación',
                  icon: Icons.ev_station_rounded,
                  iconColor: accentColor(),
                  rows: [
                    LabelRowText(
                      label: "Nombre",
                      value: orderData.stations.name,
                    ),
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
      // _infoCard(
      //   Icons.charging_station_rounded,
      //   "Carga",
      //   "${order.kWhCharged} kWh",
      // ),
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
        Icon(icon, color: accentColor(), size: 25),
        const SizedBox(height: 14),
        Text(
          value,
          style: TextStyle(
            color: whiteColor(),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: whiteColor().withValues(alpha: 0.6),
            fontSize: 13.5,
          ),
        ),
      ],
    ),
  );
}
