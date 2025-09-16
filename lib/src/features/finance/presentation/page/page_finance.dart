import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/labels/label_title.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageFinance extends StatefulWidget {
  const PageFinance({super.key});

  @override
  State<PageFinance> createState() => _PageFinanceState();
}

class _PageFinanceState extends State<PageFinance> {
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();

    return Scaffold(
      backgroundColor: primaryColor(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: UtilSize.appBarHeight() + 5,
          right: 16,
          left: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelTitle(
              title: 'Mi Billetera',
              alignment: Alignment.center,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),

            /// 🔹 Tarjeta de saldo
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              // color: greyColorWithTransparency(),
              shadowColor: accentColor(),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    LabelTitle(
                      alignment: Alignment.center,
                      title: "Saldo disponible",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 8),
                    LabelTitle(
                      alignment: Alignment.center,
                      title: "\$ ${provider.financeData?.totalRecharges}",
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      textColor: accentColor(),
                    ),

                    // const SizedBox(height: 8),
                    // ElevatedButton.icon(
                    //   onPressed: () {},
                    //   icon: const Icon(Icons.add_circle),
                    //   label: const Text("Recargar"),
                    // ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// 🔹 Transacciones
            const Text(
              "Transacciones Recientes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.green),
              title: Text("+ \$ 12.00"),
              subtitle: Text("Fecha: 21/02/2023"),
            ),
            ListTile(
              leading: const Icon(Icons.local_gas_station, color: Colors.red),
              title: Text("- \$ 10.00"),
              subtitle: Text("Estación Sur • 21/02/2023"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    final provider = context.read<FinanceProvider>();
    await provider.getWalletData({'user': Preferences().getUser()?.id});
    // Logger.logDev(provider.financeData.toString());
  }
}
