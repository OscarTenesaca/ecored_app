import 'package:ecored_app/src/core/models/plan_moder.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/material.dart';

class CardPlan extends StatelessWidget {
  final PlanModel plan;
  final bool selected;
  final VoidCallback onTap;

  const CardPlan({
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
