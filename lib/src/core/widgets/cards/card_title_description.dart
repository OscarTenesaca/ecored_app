import 'package:ecored_app/src/core/widgets/background/background_glass.dart';
import 'package:flutter/material.dart';

class CardTitleDescription extends StatelessWidget {
  final String title;
  final Color titleColor;
  final IconData icon;
  final Color iconColor;
  final List<Widget> rows;
  const CardTitleDescription({
    super.key,
    required this.title,
    this.titleColor = Colors.white,
    required this.icon,
    this.iconColor = Colors.white,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: glass(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, thickness: 0.5),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }
}
