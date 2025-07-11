// import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class LabelTitle extends StatelessWidget {
  final String title;
  final int maxLines;
  final bool padding;
  final double fontSize;
  final Color textColor;
  final FontStyle fontStyle;
  final FontWeight fontWeight;
  final TextOverflow overflow;
  final AlignmentGeometry alignment;
  final TextAlign textAlign;
  final String fontFamily;

  const LabelTitle({
    super.key,
    required this.title,
    this.maxLines = 2,
    this.padding = true,
    this.fontSize = 12,
    this.textColor = Colors.white,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.overflow = TextOverflow.ellipsis,
    this.alignment = Alignment.centerLeft,
    this.textAlign = TextAlign.justify,
    this.fontFamily = '',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          alignment: alignment,
          padding:
              (padding)
                  // ? EdgeInsets.symmetric(vertical: 4, horizontal: 8)
                  ? EdgeInsets.symmetric(vertical: 4)
                  : EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          child: Text(
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
            // minFontSize: 10,
            // textScaleFactor: constraints.maxWidth / 100 * (0.9 / 3),
          ),
        );
      },
    );
  }
}
