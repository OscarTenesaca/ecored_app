import 'package:flutter/material.dart';

class LabelRowText extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final String label;
  final String value;
  final Color titleColor;
  final Color subtitleColor;

  const LabelRowText({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    required this.label,
    required this.value,
    this.titleColor = Colors.white,
    this.subtitleColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Text(
            label,
            style: TextStyle(
              color: titleColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
