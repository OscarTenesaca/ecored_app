// import 'package:ecored_app/src/core/models/nuvei_model.dart';
// import 'package:ecored_app/src/core/models/payment_model.dart';
// import 'package:ecored_app/src/core/models/plan_moder.dart';
// import 'package:ecored_app/src/core/routes/routes_name.dart';
// import 'package:ecored_app/src/core/services/paymentes_service.dart';
// import 'package:ecored_app/src/core/theme/theme_index.dart';
// import 'package:ecored_app/src/core/utils/utils_preferences.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:flutter/material.dart';

// class PagePlan extends StatefulWidget {
//   const PagePlan({super.key});

//   @override
//   State<PagePlan> createState() => _PagePlanState();
// }

// class _PagePlanState extends State<PagePlan> {
//   double selectedPlan = 0.0;
//   final TextEditingController customAmountController = TextEditingController();

//   final List<PlanModel> plans = [
//     PlanModel(name: 'Combo 1', price: 10, benefit: 'Carga hasta 20 kWh'),
//     PlanModel(
//       name: 'Combo 2',
//       price: 20,
//       benefit: 'Carga hasta 40 kWh',
//       popular: true,
//     ),
//     PlanModel(name: 'Combo 3', price: 30, benefit: 'Carga hasta 60 kWh'),
//     PlanModel(name: 'Combo 4', price: 50, benefit: 'Carga hasta 100 kWh'),
//   ];

//   List<PaymentModel> paymentMethods = [];

//   @override
//   void initState() {
//     _loadPaymentMethods();
//     super.initState();
//   }

//   double get montoActual =>
//       selectedPlan == 0
//           ? double.tryParse(customAmountController.text) ?? 0
//           : selectedPlan;

//   PlanModel? get planActual {
//     for (final p in plans) {
//       if (p.price == selectedPlan) return p;
//     }
//     return null;
//   }

//   void pagar(PaymentModel method) {
//     final monto = montoActual;
//     if (monto == 0) return;

//     final devReference =
//         "REF${Preferences().getUser()!.id}-${DateTime.now().millisecondsSinceEpoch}";

//     final body = ModelNuvei(
//       userId: Preferences().getUser()!.id,
//       email: Preferences().getUser()!.email,
//       phone: Preferences().getUser()!.phone,
//       description: "Recarga de saldo Ecored",
//       amount: monto,
//       vat: 0,
//       devReference: devReference,
//     );

//     final bodyEcored = {
//       "value": monto,
//       "devReference": devReference,
//       "authorizationCode": "",
//       "transactionId": "",
//       "user": Preferences().getUser()!.id,
//       "payment": method.id,
//     };

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (_) => PaymentesNuvei(
//               status: PaymentStatus.recharge,
//               bodyNuvei: body,
//               bodyEcored: bodyEcored,
//             ),
//       ),
//     );
//   }

//   Future<void> _loadPaymentMethods() async {
//     final methods = await PaymentesServiceImpl().getPaymentMethods();
//     setState(() {
//       paymentMethods = methods;
//     });
//   }

//   @override
//   void dispose() {
//     customAmountController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final neonGreen = accentColor();
//     final plan = planActual;

//     return Scaffold(
//       backgroundColor: primaryColor(),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           "Selecciona un plan",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 10),

//             // // Preview del plan / monto seleccionado
//             // AnimatedSwitcher(
//             //   duration: const Duration(milliseconds: 300),
//             //   child: Column(
//             //     key: ValueKey(plan?.price ?? montoActual),
//             //     children: [
//             //       Container(
//             //         width: 64,
//             //         height: 64,
//             //         decoration: BoxDecoration(
//             //           color: neonGreen.withOpacity(.15),
//             //           shape: BoxShape.circle,
//             //         ),
//             //         child: Icon(Icons.bolt, color: neonGreen, size: 36),
//             //       ),
//             //       const SizedBox(height: 14),
//             //       Text(
//             //         plan?.name ?? "Monto personalizado",
//             //         style: const TextStyle(color: Colors.white70, fontSize: 16),
//             //       ),
//             //       const SizedBox(height: 4),
//             //       Text(
//             //         "\$${montoActual.toStringAsFixed(0)}",
//             //         style: const TextStyle(
//             //           color: Colors.white,
//             //           fontWeight: FontWeight.bold,
//             //           fontSize: 38,
//             //         ),
//             //       ),
//             //       if (plan != null) ...[
//             //         const SizedBox(height: 4),
//             //         Text(
//             //           plan.benefit,
//             //           style: TextStyle(color: neonGreen, fontSize: 15),
//             //         ),
//             //       ],
//             //     ],
//             //   ),
//             // ),

//             // const SizedBox(height: 20),
//             Expanded(
//               child: GridView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 18),
//                 itemCount: plans.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 0.90,
//                 ),
//                 itemBuilder: (context, index) {
//                   final p = plans[index];
//                   final selected = selectedPlan == p.price;

//                   return CardPlan(
//                     plan: p,
//                     selected: selected,
//                     onTap: () {
//                       setState(() {
//                         selectedPlan = p.price;
//                         customAmountController.clear();
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 16),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Monto personalizado",
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xff1D1D1D),
//                       borderRadius: BorderRadius.circular(18),
//                       border: Border.all(color: kAccentColor.withOpacity(0.4)),
//                     ),
//                     child: TextField(
//                       controller: customAmountController,
//                       keyboardType: TextInputType.number,
//                       style: const TextStyle(color: Colors.white, fontSize: 18),
//                       onChanged: (_) => setState(() => selectedPlan = 0),
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         prefixIcon: Icon(Icons.attach_money, color: neonGreen),
//                         hintText: "Ingresa tu monto",
//                         hintStyle: TextStyle(
//                           color: Colors.white.withOpacity(0.4),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 58,
//                     child: PaymentSelector(
//                       title: "PAGAR \$${montoActual.toStringAsFixed(0)}",
//                       onSelected: (method) {
//                         switch (method.name.toLowerCase()) {
//                           case 'nuvei':
//                             pagar(method);
//                             break;
//                           default:
//                             showSnackbar(
//                               context,
//                               'Método de pago no reconocido.',
//                               SnackbarStatus.error,
//                             );
//                             break;
//                         }
//                       },
//                     ),
//                   ),

//                   const SizedBox(height: 14),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:ecored_app/src/core/models/nuvei_model.dart';
import 'package:ecored_app/src/core/models/payment_model.dart';
import 'package:ecored_app/src/core/models/plan_moder.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/services/paymentes_service.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:flutter/material.dart';

class PagePlan extends StatefulWidget {
  const PagePlan({super.key});

  @override
  State<PagePlan> createState() => _PagePlanState();
}

class _PagePlanState extends State<PagePlan> {
  double selectedPlan = 0.0;
  final TextEditingController customAmountController = TextEditingController();

  final List<PlanModel> plans = [
    PlanModel(name: 'Combo 1', price: 10, benefit: 'Carga hasta 20 kWh'),
    PlanModel(
      name: 'Combo 2',
      price: 20,
      benefit: 'Carga hasta 40 kWh',
      popular: true,
    ),
    PlanModel(name: 'Combo 3', price: 30, benefit: 'Carga hasta 60 kWh'),
    PlanModel(name: 'Combo 4', price: 50, benefit: 'Carga hasta 100 kWh'),
  ];

  List<PaymentModel> paymentMethods = [];

  @override
  void initState() {
    _loadPaymentMethods();
    super.initState();
  }

  void pagar(PaymentModel method) {
    final monto =
        selectedPlan == 0
            ? double.tryParse(customAmountController.text) ?? 0
            : selectedPlan;

    if (monto == 0) return;

    //********* body the nuvei *********

    final devReference =
        "REF${Preferences().getUser()!.id}-${DateTime.now().millisecondsSinceEpoch}";

    final body = ModelNuvei(
      userId: Preferences().getUser()!.id,
      email: Preferences().getUser()!.email,
      phone: Preferences().getUser()!.phone,
      description: "Recarga de saldo Ecored",
      amount: monto,
      vat: 0,
      devReference: devReference,
    );

    //******  body the ecored *******
    final bodyEcored = {
      "value": monto,
      "devReference": devReference,
      "authorizationCode": "",
      "transactionId": "",
      "user": Preferences().getUser()!.id,
      "payment": method.id,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PaymentesNuvei(
              status: PaymentStatus.recharge,
              bodyNuvei: body,
              bodyEcored: bodyEcored,
            ),
      ),
    );
  }

  Future<void> _loadPaymentMethods() async {
    final methods = await PaymentesServiceImpl().getPaymentMethods();
    setState(() {
      paymentMethods = methods;
    });
  }

  @override
  Widget build(BuildContext context) {
    final monto =
        selectedPlan == 0
            ? (double.tryParse(customAmountController.text) ?? 0)
            : selectedPlan;
    return Scaffold(
      backgroundColor: primaryColor(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelTitle(
                title: "Elige un plan",
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  itemCount: plans.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (_, i) {
                    final plan = plans[i];
                    final isSelected = selectedPlan == plan.price;

                    return CardPlan(
                      plan: plan,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedPlan = plan.price;
                          customAmountController.clear();
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // PaymentMethodSelector(amount: 1, onSelected: (method) {}),
              LabelTitle(
                title: 'Monto personalizado',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customAmountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Ingresa tu monto",
                        hintStyle: TextStyle(color: grayInputColor()),
                        prefixText: "\$ ",
                        prefixStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: deepForestGreen(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: kAccentColor.withOpacity(0.4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: kAccentColor, width: 2),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() => selectedPlan = 0);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  PaymentSelector(
                    title:
                        monto > 0
                            ? 'Pagar \$${monto.toStringAsFixed(2)}'
                            : 'Pagar',

                    onSelected: (method) {
                      switch (method.name.toLowerCase()) {
                        case 'nuvei':
                          pagar(method);
                          break;

                        default:
                          showSnackbar(
                            context,
                            'Método de pago no reconocido.',
                            SnackbarStatus.error,
                          );
                          break;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
