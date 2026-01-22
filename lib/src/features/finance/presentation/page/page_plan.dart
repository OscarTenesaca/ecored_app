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
        builder: (_) => PaymentesNuvei(bodyNuvei: body, bodyEcored: bodyEcored),
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
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                        ),
                        prefixText: "\$ ",
                        prefixStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
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
                    title: 'Pagar',
                    onSelected: (method) {
                      print('Método seleccionado: ${method.name}');

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
