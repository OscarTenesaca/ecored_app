import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/material.dart';

class CardTransaction extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final bool positive;
  final Function()? onTap; // Acción al
  final Color titleColor; // Color del título
  final Color amountColor; // Color del subtítulo

  const CardTransaction({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.positive,
    this.titleColor = Colors.white,
    this.amountColor = Colors.grey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor(),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .05)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color:
                    positive
                        ? accentColor().withValues(alpha: .10)
                        : errorColor().withValues(alpha: .08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                positive
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: positive ? accentColor() : errorColor(),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: whiteColor(),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    date,
                    style: TextStyle(color: amountColor, fontSize: 11),
                  ),
                ],
              ),
            ),

            Text(
              amount,
              style: TextStyle(
                color: positive ? accentColor() : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class CardTransaction extends StatelessWidget {
//   final IconData icon; // Ícono de la transacción
//   final Color iconBgColor; // Color de fondo del ícono
//   final String title; // Título de la transacción (monto)
//   final Color titleColor; // Color del título
//   final String subtitle; // Subtítulo (fecha de la transacción)
//   final Color subtitleColor; // Color del subtítulo
//   final Function()? onTap; // Acción al

//   const CardTransaction({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     this.titleColor = Colors.white,
//     this.iconBgColor = Colors.green,
//     this.subtitleColor = Colors.grey,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.only(bottom: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(
//           vertical: 12,
//           horizontal: 16,
//         ),
//         leading: Container(
//           decoration: BoxDecoration(
//             color: iconBgColor, // Color de fondo del ícono
//             borderRadius: BorderRadius.circular(12), // Bordes redondeados
//           ),
//           padding: const EdgeInsets.all(8),
//           child: Icon(
//             icon, // Ícono de la transacción
//             color: Colors.white,
//             size: 30, // Tamaño del ícono
//           ),
//         ),
//         title: Text(
//           title, // Monto de la transacción
//           style: TextStyle(
//             color: titleColor, // Color del título (por ejemplo, monto)
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//         subtitle: Text(
//           subtitle, // Fecha de la transacción
//           style: TextStyle(
//             color: subtitleColor, // Color del subtítulo (fecha)
//             fontSize: 14,
//           ),
//         ),
//         trailing: const Icon(Icons.chevron_right), // Icono de flecha al final
//         onTap: onTap,
//       ),
//     );
//   }
// }
