import 'package:ecored_app/src/core/models/nuvei_model.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/labels/label_title.dart';
import 'package:ecored_app/src/core/widgets/paymentes/paymentes_nuvei.dart';
import 'package:flutter/material.dart';

class PlanModel {
  final String name;
  final double price;
  final String benefit;
  final bool popular;

  PlanModel({
    required this.name,
    required this.price,
    required this.benefit,
    this.popular = false,
  });
}

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

  void pagar() {
    final monto =
        selectedPlan == 0
            ? double.tryParse(customAmountController.text) ?? 0
            : selectedPlan;

    if (monto == 0) return;

    final body = ModelNuvei(
      userId: Preferences().getUser()!.id,
      email: Preferences().getUser()!.email,
      description: "Recarga de saldo Ecored",
      amount: monto,
      vat: 0,
      devReference:
          "REF${Preferences().getUser()!.id} ${DateTime.now().millisecondsSinceEpoch}",
    );

    Navigator.pushNamed(
      context,
      RouteNames.pagePaymentesNuvei,
      arguments: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
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

                    return NeonPlanCard(
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

                  ElevatedButton(
                    onPressed: pagar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Pagar", style: TextStyle(fontSize: 17)),
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

class NeonPlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool selected;
  final VoidCallback onTap;

  const NeonPlanCard({
    super.key,
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neonGreen = accentColor();

    return AnimatedScale(
      scale: selected ? 1.07 : 1.0,
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),

            // 🟢 Borde NEON verde
            border: Border.all(
              width: selected ? 2.4 : 1.2,
              color: selected ? neonGreen : Colors.white12,
            ),

            // Fondo futurista oscuro
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  selected
                      ? [const Color(0xFF16200F), const Color(0xFF0E140A)]
                      : [const Color(0xFF141414), const Color(0xFF0F0F0F)],
            ),

            // ✨ Glow verde neon
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: neonGreen.withValues(alpha: 0.55),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🟢 Badge POPULAR neon
              if (plan.popular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        neonGreen.withValues(alpha: 0.9),
                        neonGreen.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: neonGreen.withValues(alpha: 0.7),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Text(
                    "POPULAR",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              Text(
                plan.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              Text(
                "\$${plan.price.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: neonGreen,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                plan.benefit,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
