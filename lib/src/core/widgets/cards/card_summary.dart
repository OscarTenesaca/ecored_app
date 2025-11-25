import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:flutter/material.dart';

class CardSummary extends StatelessWidget {
  final String title;
  final Color titleColor;
  final String status;
  final String subtitle;
  final Color subtitleColor;
  final String leftText;
  final Color leftTextColor;
  final String rightText;
  final Color rightTextColor;
  const CardSummary({
    super.key,
    this.title = 'Total a pagar',
    this.titleColor = Colors.grey,
    required this.status,
    required this.subtitle,
    required this.subtitleColor,
    required this.leftText,
    this.leftTextColor = Colors.grey,
    required this.rightText,
    this.rightTextColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = status == "DONE";
    final color = isDone ? Colors.greenAccent : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: glass(deep: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LabelTitle(title: title, fontSize: 15, textColor: titleColor),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: color.withOpacity(0.40)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          LabelTitle(
            title: subtitle,
            fontSize: 36,
            textColor: subtitleColor,
            fontWeight: FontWeight.bold,
          ),

          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LabelTitle(
                title: leftText,
                fontSize: 15,
                textColor: leftTextColor,
              ),
              LabelTitle(
                title: rightText,
                fontSize: 15,
                textColor: rightTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
