import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/cards/card_transaction.dart';
import 'package:ecored_app/src/core/widgets/labels/label_title.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/finance/data/models/model_transaction.dart';
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
                      title: "\$ ${provider.financeData?.balance ?? '0.00'}",
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      textColor: accentColor(),
                    ),

                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle),
                      label: const Text("Recargar"),
                    ),
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

            ListView.separated(
              padding: EdgeInsets.only(bottom: 16),
              itemCount: provider.transactionData?.length ?? 0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (_, int index) => SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                // Asegurarse de que no sea null
                ModelTransaction? transaction =
                    provider.transactionData?[index];

                return (transaction!.type == 'RECHARGE')
                    ? CardTransaction(
                      icon: Icons.attach_money,
                      title: "+ \$ ${transaction.amount}",
                      subtitle: transaction.createdAt.toString(),
                    )
                    : CardTransaction(
                      icon: Icons.local_gas_station,
                      iconBgColor: Colors.red,
                      title: "- \$ ${transaction.amount}",
                      subtitle: transaction.createdAt.toString(),
                    );
              },
            ),
            Padding(
              padding: EdgeInsets.only(bottom: UtilSize.bottomPadding() + 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    final provider = context.read<FinanceProvider>();
    await provider.getWalletData({'user': Preferences().getUser()?.id});
    await provider.getTransactionData({'user': Preferences().getUser()?.id});
  }
}

// import 'package:ecored_app/src/core/utils/utils_preferences.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:ecored_app/src/core/theme/theme_colors.dart';
// import 'package:ecored_app/src/core/utils/utils_index.dart';
// import 'package:ecored_app/src/core/widgets/labels/label_title.dart';
// import 'package:ecored_app/src/features/finance/data/models/model_transaction.dart';
// import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';

// class PageFinance extends StatefulWidget {
//   const PageFinance({super.key});

//   @override
//   State<PageFinance> createState() => _PageFinanceState();
// }

// class _PageFinanceState extends State<PageFinance> {
//   @override
//   void initState() {
//     _loadData();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<FinanceProvider>();
//     return Scaffold(
//       backgroundColor: primaryColor(),
//       appBar: AppBar(
//         title: const Text('Mi Billetera'),
//         backgroundColor: primaryColor(),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 🔹 Tarjeta de saldo
//             _buildBalanceCard(provider),
//             const SizedBox(height: 24),

//             /// 🔹 Transacciones recientes
//             const Text(
//               "Transacciones Recientes",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             _buildTransactionList(provider),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBalanceCard(FinanceProvider provider) {
//     return Card(
//       elevation: 6,
//       shadowColor: accentColor(),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             LabelTitle(
//               alignment: Alignment.center,
//               title: "Saldo disponible",
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//             const SizedBox(height: 8),
//             LabelTitle(
//               alignment: Alignment.center,
//               title: "\$ ${provider.financeData?.balance ?? '0.00'}",
//               fontSize: 30,
//               fontWeight: FontWeight.bold,
//               textColor: accentColor(),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Lógica para recargar saldo
//               },
//               icon: const Icon(Icons.add_circle, size: 24),
//               label: const Text("Recargar", style: TextStyle(fontSize: 16)),
//               style: ElevatedButton.styleFrom(
//                 // primary: accentColor(),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransactionList(FinanceProvider provider) {
//     return ListView.separated(
//       padding: EdgeInsets.zero,
//       itemCount: provider.transactionData?.length ?? 0,
//       shrinkWrap: true,
//       separatorBuilder: (_, int index) => const SizedBox(height: 12),
//       itemBuilder: (BuildContext context, int index) {
//         ModelTransaction? transaction = provider.transactionData?[index];

//         return _buildTransactionItem(transaction!);
//       },
//     );
//   }

//   Widget _buildTransactionItem(ModelTransaction transaction) {
//     final isRecharge = transaction.type == 'RECHARGE';
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.only(bottom: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(
//           vertical: 12,
//           horizontal: 16,
//         ),
//         leading: Icon(
//           isRecharge ? Icons.arrow_downward : Icons.arrow_upward,
//           color: isRecharge ? Colors.green : Colors.red,
//           size: 30,
//         ),
//         title: Text(
//           isRecharge
//               ? "+ \$ ${transaction.amount}"
//               : "- \$ ${transaction.amount}",
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: isRecharge ? Colors.green : Colors.red,
//           ),
//         ),
//         subtitle: Text(
//           transaction.createdAt.toString(),
//           style: const TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//         trailing: const Icon(Icons.chevron_right),
//         onTap: () {
//           // Acción al seleccionar una transacción
//         },
//       ),
//     );
//   }

//   Future<void> _loadData() async {
//     final provider = context.read<FinanceProvider>();
//     await provider.getWalletData({'user': Preferences().getUser()?.id});
//     await provider.getTransactionData({'user': Preferences().getUser()?.id});
//   }
// }
