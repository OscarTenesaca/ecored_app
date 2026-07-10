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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: selected ? 1.04 : 1.0,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),

            // 🟢 Gradiente lima cuando está seleccionado
            gradient:
                selected
                    ? LinearGradient(
                      colors: [neonGreen, neonGreen.withOpacity(.75)],
                    )
                    : LinearGradient(
                      // colors: [Color(0xff2D2D2D), Color(0xff1C1C1C)],
                      colors: [deepForestGreen(), greyColorWithTransparency()],
                    ),

            border: Border.all(
              color: selected ? Colors.transparent : Colors.white12,
            ),

            // ✨ Glow al seleccionar
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: neonGreen.withOpacity(.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                    : [],
          ),
          child: Stack(
            children: [
              // Badge POPULAR
              if (plan.popular)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "POPULAR",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Check al seleccionar
              Positioned(
                right: 12,
                top: 12,
                child: AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

              // Contenido central
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      color: selected ? Colors.black : neonGreen,
                      size: 32,
                    ),

                    const SizedBox(height: 12),
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: 25,
                        // fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.black : Colors.white,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // const SizedBox(height: 10),
                    Text(
                      "\$${plan.price.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.black : neonGreen,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      plan.benefit,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.black87 : Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:ecored_app/src/core/models/plan_moder.dart';
// import 'package:ecored_app/src/core/theme/theme_index.dart';
// import 'package:flutter/material.dart';

// class CardPlan extends StatelessWidget {
//   final PlanModel plan;
//   final bool selected;
//   final VoidCallback onTap;

//   const CardPlan({
//     super.key,
//     required this.plan,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final neonGreen = accentColor();

//     return AnimatedScale(
//       scale: selected ? 1.07 : 1.0,
//       duration: const Duration(milliseconds: 190),
//       curve: Curves.easeOut,
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 220),
//           padding: const EdgeInsets.all(18),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(22),

//             // 🟢 Borde NEON verde
//             border: Border.all(
//               width: selected ? 2.4 : 1.2,
//               color: selected ? neonGreen : Colors.white12,
//             ),

//             // Fondo futurista oscuro
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors:
//                   selected
//                       ? [const Color(0xFF16200F), const Color(0xFF0E140A)]
//                       : [const Color(0xFF141414), const Color(0xFF0F0F0F)],
//             ),

//             // ✨ Glow verde neon
//             boxShadow:
//                 selected
//                     ? [
//                       BoxShadow(
//                         color: neonGreen.withValues(alpha: 0.55),
//                         blurRadius: 18,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 4),
//                       ),
//                     ]
//                     : [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // 🟢 Badge POPULAR neon
//               if (plan.popular)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         neonGreen.withValues(alpha: 0.9),
//                         neonGreen.withValues(alpha: 0.6),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: neonGreen.withValues(alpha: 0.7),
//                         blurRadius: 12,
//                       ),
//                     ],
//                   ),
//                   child: const Text(
//                     "POPULAR",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),

//               const SizedBox(height: 12),

//               Text(
//                 plan.name,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                   letterSpacing: -0.3,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: 6),

//               Text(
//                 "\$${plan.price.toStringAsFixed(0)}",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: neonGreen,
//                   letterSpacing: -1,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               Text(
//                 plan.benefit,
//                 style: const TextStyle(fontSize: 14, color: Colors.white70),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
