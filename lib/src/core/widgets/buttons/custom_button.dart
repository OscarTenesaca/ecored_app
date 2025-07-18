import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final double fontSize;
  final String textButton;
  final Color buttonColor;
  final Color textButtonColor;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final bool space;
  final bool? haveMargin;

  final Function()? onPressed;

  const CustomButton({
    super.key,
    required this.textButton,
    required this.buttonColor,
    required this.textButtonColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.bold,
    this.padding = EdgeInsets.zero,
    this.space = true,
    this.onPressed,
    this.haveMargin = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          haveMargin != null && haveMargin == true
              ? EdgeInsets.all(UtilSize.width(context) * 5 / 100)
              : EdgeInsets.symmetric(
                horizontal: UtilSize.width(context) * 5 / 100,
              ),
      child: ElevatedButton(
        onPressed: () {
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          padding: padding,
          minimumSize:
              (space) ? Size(UtilSize.sizeMiddle(context), fontSize * 4) : null,
          backgroundColor: buttonColor,
          foregroundColor: textButtonColor,
          side: BorderSide(color: textButtonColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            letterSpacing: 1,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
        child: Text(textButton),
      ),
    );
  }
}
