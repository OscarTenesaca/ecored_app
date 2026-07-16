import 'package:flutter/material.dart';

class CardTutorial extends StatelessWidget {
  final String? image;
  final String title;
  final Color titleColor;
  final String subtitle;
  final Color subtitleColor;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  const CardTutorial({
    super.key,
    this.image,
    required this.title,
    required this.subtitle,
    this.titleColor = Colors.white,
    this.subtitleColor = Colors.white70,
    this.backgroundColor = Colors.transparent,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: .05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null) ...[
              Center(
                child: Image.asset(image!, height: 80, fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
            ],

            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Spacer(),
            const SizedBox(height: 20),
            // Flexible(fit: FlexFit.tight, child: SizedBox()),
            Text(
              subtitle,
              style: TextStyle(color: subtitleColor, fontSize: 14),
            ),

            const SizedBox(height: 8),

            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.arrow_outward_rounded,
                color: Colors.white30,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// class CardTutorial extends StatelessWidget {
//   final String? image;
//   final String title;
//   final Color titleColor;
//   final String subtitle;
//   final Color subtitleColor;
//   final Function()? onPressed;

//   const CardTutorial({
//     this.image,
//     required this.title,
//     required this.subtitle,
//     this.titleColor = Colors.white,
//     this.subtitleColor = Colors.white70,
//     this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         // width: 220,
//         margin: const EdgeInsets.only(right: 15),
//         decoration: BoxDecoration(
//           color: Colors.grey[900],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 21,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const Spacer(),
//             Text(
//               subtitle,
//               style: const TextStyle(color: Colors.white54, fontSize: 14),
//             ),
//             const SizedBox(height: 8),

//             // Imagen superior
//             // ClipRRect(
//             //   borderRadius: const BorderRadius.vertical(
//             //     top: Radius.circular(12),
//             //   ),
//             //   child: Image.asset(
//             //     image,
//             //     width: 220,
//             //     height: 80,
//             //     fit: BoxFit.cover,
//             //   ),
//             // ),

//             // Padding(
//             //   padding: const EdgeInsets.all(10),
//             //   child: Column(
//             //     crossAxisAlignment: CrossAxisAlignment.start,
//             //     children: [
//             //       Text(
//             //         title,
//             //         style: TextStyle(
//             //           color: titleColor,
//             //           fontWeight: FontWeight.bold,
//             //           fontSize: 11,
//             //         ),
//             //       ),
//             //       const SizedBox(height: 5),
//             //       Text(
//             //         subtitle,
//             //         style: TextStyle(
//             //           color: subtitleColor,
//             //           fontSize: 10,
//             //           overflow: TextOverflow.ellipsis,
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
