import 'package:flutter/material.dart';

// class CustomButtonCircle extends StatelessWidget {
//   final IconData? icon;
//   final Widget? image;
//   final VoidCallback? onTap;
//   final double size;
//   final Color background;
//   final Color borderColor;

//   const CustomButtonCircle({
//     super.key,
//     this.icon,
//     this.image,
//     this.onTap,
//     this.size = 70,
//     this.background = Colors.transparent,
//     this.borderColor = Colors.transparent,
//   }) : assert(icon != null || image != null);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(size / 2),
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: background,
//           border: Border.all(color: borderColor),
//         ),
//         child: Center(
//           child:
//               image ??
//               Icon(icon, color: const Color(0xFFC6FF00), size: size * .45),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class CustomButtonCircle extends StatelessWidget {
  final IconData? icon;
  final String? asset;
  final String? imageUrl;
  final VoidCallback? onTap;

  final double size;
  final Color iconColor;
  final Color background;
  final Color borderColor;
  final double borderWidth;
  final double iconSize;

  const CustomButtonCircle({
    super.key,
    this.icon,
    this.asset,
    this.imageUrl,
    this.onTap,
    this.size = 70,
    this.iconColor = const Color(0xFFC6FF00),
    this.background = Colors.transparent,
    this.borderColor = const Color(0xFFC6FF00),
    this.borderWidth = 1.2,
    this.iconSize = 0.45,
  }) : assert(
         icon != null || asset != null || imageUrl != null,
         'Debes proporcionar un icono, un asset o una URL.',
       );

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (asset != null) {
      child = Image.asset(
        asset!,
        width: size * iconSize,
        height: size * iconSize,
        fit: BoxFit.contain,
      );
    } else if (imageUrl != null) {
      child = Image.network(
        imageUrl!,
        width: size * iconSize,
        height: size * iconSize,
        fit: BoxFit.contain,
      );
    } else {
      child = Icon(icon, color: iconColor, size: size * iconSize);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// class CustomButtonCircle extends StatelessWidget {
//   final IconData? icon;
//   final Widget? image;
//   final Function()? onPressed;

//   final Color background;
//   final double size;

//   const CustomButtonCircle({
//     super.key,
//     required this.icon,
//      this.background,
//     this.onPressed,
//     this.size = 25,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onPressed,
//       borderRadius: BorderRadius.circular(50),
//       child: CircleAvatar(
//         backgroundColor: color.withValues(alpha: 0.2),
//         radius: size,
//         child: Icon(icon, color: color, size: size),
//       ),
//     );
//   }
// }
