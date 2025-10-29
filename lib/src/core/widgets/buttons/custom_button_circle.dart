import 'package:flutter/material.dart';

class CustomButtonCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Function()? onPressed;

  const CustomButtonCircle({
    super.key,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        radius: 28,
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
