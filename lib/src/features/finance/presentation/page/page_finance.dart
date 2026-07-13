import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 30),

              /// 🔹 Tarjeta de saldo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [deepForestGreen(), primaryColor().withAlpha(1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor().withValues(alpha: 0.12),
                      blurRadius: 30,
                      spreadRadius: 1,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        LabelTitle(
                          alignment: Alignment.center,
                          title: "Saldo disponible",
                          fontSize: 14,
                          textColor: grayInputColor(),
                        ),

                        const Spacer(),

                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, RouteNames.pagePlan);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accentColor().withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              // Icons.account_balance_wallet_outlined,
                              Icons.add_card_rounded,
                              color: accentColor(),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    LabelTitle(
                      alignment: Alignment.centerLeft,
                      title: "\$ ${provider.financeData?.balance}",
                      fontSize: 35,
                      // fontSize: 48,
                      fontWeight: FontWeight.bold,
                      textColor: accentColor(),
                    ),

                    const SizedBox(height: 20),

                    // CustomButton(
                    //   textButton: '+ Recargar',
                    //   buttonColor: accentColor(),
                    //   textButtonColor: primaryColor(),
                    //   fontWeight: FontWeight.bold,
                    //   onPressed: () {
                    // Navigator.pushNamed(context, RouteNames.pagePlan);
                    //   },
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              const LabelTitle(
                title: 'Movimientos',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),

              const SizedBox(height: 20),

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

                  print(transaction!.toJson().toString());

                  switch (transaction!.type) {
                    case 'RECHARGE':
                      return CardTransaction(
                        title: "Recarga Aplicativo",
                        amount: "+ \$ ${transaction.amount}",
                        date: UtilsDate.formatLocal(
                          transaction.createdAt.toString(),
                        ),
                        positive: true,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.pageRecharge,
                            arguments: transaction,
                          );
                        },
                      );
                    case 'CONSUMPTION':
                      return CardTransaction(
                        title: "Pago Electrolinera",
                        amount: "- \$ ${transaction.amount.toStringAsFixed(2)}",
                        date: UtilsDate.formatLocal(
                          transaction.createdAt.toString(),
                        ),
                        positive: false,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.pageOrder,
                            arguments: transaction,
                          );
                        },
                      );
                    default:
                      return Text('Fuera de opcion');
                  }
                },
              ),

              SizedBox(height: 30),
            ],
          ),
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

// import 'package:ecored_app/src/core/routes/routes_name.dart';
// import 'package:ecored_app/src/core/theme/theme_colors.dart';
// import 'package:ecored_app/src/core/utils/utils_index.dart';
// import 'package:ecored_app/src/core/utils/utils_preferences.dart';
// import 'package:ecored_app/src/core/widgets/cards/card_transaction.dart';
// import 'package:ecored_app/src/core/widgets/labels/label_title.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:ecored_app/src/features/finance/data/models/model_transaction.dart';
// import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

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
//       backgroundColor: accentColor()Color(),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.only(
//           top: UtilSize.appBarHeight() + 5,
//           right: 16,
//           left: 16,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             LabelTitle(
//               title: 'Mi Billetera',
//               alignment: Alignment.center,
//               fontWeight: FontWeight.bold,
//               fontSize: 24,
//             ),

//             /// 🔹 Tarjeta de saldo
//             Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               // color: greyColorWithTransparency(),
//               shadowColor: accentColor(),
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     LabelTitle(
//                       alignment: Alignment.center,
//                       title: "Saldo disponible",
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     const SizedBox(height: 8),
//                     LabelTitle(
//                       alignment: Alignment.center,
//                       title: "\$ ${provider.financeData?.balance}",
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       textColor: accentColor(),
//                     ),

//                     const SizedBox(height: 8),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.pushNamed(context, RouteNames.pagePlan);
//                       },
//                       icon: const Icon(Icons.add_circle),
//                       label: const Text("Recargar"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             /// 🔹 Transacciones
//             const Text(
//               "Transacciones Recientes",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             ListView.separated(
//               padding: EdgeInsets.only(bottom: 16),
//               itemCount: provider.transactionData?.length ?? 0,
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               separatorBuilder: (_, int index) => SizedBox(height: 8),
//               itemBuilder: (BuildContext context, int index) {
//                 // Asegurarse de que no sea null
//                 ModelTransaction? transaction =
//                     provider.transactionData?[index];

//                 return (transaction!.type == 'RECHARGE')
//                     ? CardTransaction(
//                       icon: Icons.attach_money,
//                       title: "+ \$ ${transaction.amount}",
//                       // subtitle: transaction.createdAt.toString(),
//                       subtitle: UtilsDate.formatLocal(
//                         transaction.createdAt.toString(),
//                       ),
//                       onTap: () {
//                         Navigator.pushNamed(
//                           context,
//                           RouteNames.pageRecharge,
//                           arguments: transaction,
//                         );
//                       },
//                     )
//                     : CardTransaction(
//                       icon: Icons.local_gas_station,
//                       iconBgColor: Colors.red,
//                       title: "- \$ ${transaction.amount}",
//                       subtitle: UtilsDate.formatLocal(
//                         transaction.createdAt.toString(),
//                       ),
//                       onTap: () {
//                         Navigator.pushNamed(
//                           context,
//                           RouteNames.pageOrder,
//                           arguments: transaction,
//                         );
//                       },
//                     );
//               },
//             ),
//             Padding(
//               padding: EdgeInsets.only(bottom: UtilSize.bottomPadding() + 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _loadData() async {
//     final provider = context.read<FinanceProvider>();
//     await provider.getWalletData({'user': Preferences().getUser()?.id});
//     await provider.getTransactionData({'user': Preferences().getUser()?.id});
//   }
// }
