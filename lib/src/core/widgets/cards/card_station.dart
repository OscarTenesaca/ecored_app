import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/widgets/background/background_glass.dart';
import 'package:ecored_app/src/core/widgets/labels/label_title.dart';
import 'package:flutter/material.dart';

class CardStation extends StatelessWidget {
  final String title;
  final List<String> details;

  const CardStation({super.key, required this.title, required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(shadow: true),
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.location_on, color: accentColor(), size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelTitle(
                  title: title,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),

                // Lista de detalles generada automáticamente
                ...details.map(
                  (detail) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: LabelTitle(
                      padding: false,
                      title: detail,
                      textColor: grayInputColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
