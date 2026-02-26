// import 'package:flutter/material.dart';

// class PageRecharge extends StatelessWidget {
//   const PageRecharge({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

import 'dart:developer';

import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/utils/utils_date.dart';
import 'package:ecored_app/src/core/utils/utils_size.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageRecharge extends StatefulWidget {
  const PageRecharge({super.key});

  @override
  State<PageRecharge> createState() => _PageRechargeState();
}

class _PageRechargeState extends State<PageRecharge> {
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
    final rechargeData = provider.rechargeData;

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
              status: rechargeData!.status,
              subtitle: '+ \$${rechargeData.value}',
              subtitleColor: Colors.greenAccent,
              leftText: 'Recargado con éxito',
              leftTextColor: grayInputColor(),
              rightText: rechargeData.createdAt,
              // rightText: UtilsDate.formatLocal(
              //   rechargeData.createdAt.toString(),
              // ),
              rightTextColor: Colors.white.withOpacity(0.65),
            ),

            // _mainRechargeSummary(rechargeData),
            const SizedBox(height: 18),

            /// -------- SECCIÓN DETALLES TRANSACCIÓN -----
            CardTitleDescription(
              title: 'Detalles de Transacción',
              icon: Icons.receipt_long,
              rows: [
                LabelRowText(
                  label: "Método de pago",
                  value:
                      (rechargeData.payment.name.toLowerCase() == 'nuvei')
                          ? "Pago con Tarjeta"
                          : rechargeData.payment.name,
                ),
                LabelRowText(
                  label: "Transaction ID",
                  value: rechargeData.transactionId,
                ),
                LabelRowText(
                  label: "Autorización",
                  value: rechargeData.authorizationCode,
                ),
                // LabelRowText(
                //   label: "Referencia",
                //   value: rechargeData.devReference,
                // ),
              ],
            ),

            const SizedBox(height: 8),
            _backButton(context),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white.withOpacity(0.15),
        ),
        child: const Center(
          child: Text(
            "Regresar",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadData(ModelTransaction args) async {
    final provider = context.read<FinanceProvider>();
    await provider.getRechargeData({'id': args.recharge});
  }
}
