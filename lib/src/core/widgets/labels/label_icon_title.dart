import 'package:flutter/material.dart';

class LabelIconTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool reverse;
  final int maxLines;
  final bool padding;
  final double fontSize;
  final Color textColor;
  final Color iconColor;
  final FontStyle fontStyle;
  final FontWeight fontWeight;
  final TextOverflow overflow;
  final AlignmentGeometry alignment;
  final TextAlign textAlign;
  final String fontFamily;

  const LabelIconTitle({
    super.key,
    required this.icon,
    required this.title,
    this.reverse = false,
    this.maxLines = 2,
    this.padding = true,
    this.fontSize = 12,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.overflow = TextOverflow.ellipsis,
    this.alignment = Alignment.centerLeft,
    this.textAlign = TextAlign.justify,
    this.fontFamily = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding:
          (padding)
              // ? EdgeInsets.symmetric(vertical: 4, horizontal: 8)
              ? EdgeInsets.symmetric(vertical: 4)
              : EdgeInsets.zero,
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        textDirection: (reverse) ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(icon, size: fontSize * 1.8, color: iconColor),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontStyle: fontStyle,
              fontWeight: fontWeight,
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
          ),
        ],
      ),
    );
  }
}
