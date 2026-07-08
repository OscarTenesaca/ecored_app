import 'package:flutter/material.dart';

class CustomButtonSquare extends StatelessWidget {
  final double size;
  final Color backgroundColor;

  final IconData? icon;
  final String? asset;
  final String? imageUrl;

  final Color iconColor;
  final VoidCallback? onTap;
  final double borderRadius;
  final double sizeAsset;

  const CustomButtonSquare({
    super.key,
    this.size = 54,
    this.icon,
    this.asset,
    this.imageUrl,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.transparent,
    this.onTap,
    this.borderRadius = 18,
    this.sizeAsset = 0.45,
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
        width: size * sizeAsset,
        height: size * sizeAsset,
        fit: BoxFit.contain,
      );
    } else if (imageUrl != null) {
      child = Image.network(
        imageUrl!,
        width: size * sizeAsset,
        height: size * sizeAsset,
        fit: BoxFit.contain,
      );
    } else {
      child = Icon(icon, color: iconColor, size: size * sizeAsset);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(child: child),
      ),
    );
  }
}
