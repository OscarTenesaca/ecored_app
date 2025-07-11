import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final TextInputType textInputType;
  final double fontSize;
  final String labelText;
  final String hintText;
  final bool? filled;
  final bool readOnly;
  final bool obscured;
  final Color? filledColor;
  final TextEditingController? textEditingController;
  final TextCapitalization textCapitalization;
  final dynamic validator;

  const CustomInput({
    Key? key,
    required this.hintText,
    required this.validator,
    this.labelText = '',
    this.textEditingController,
    this.textCapitalization = TextCapitalization.none,
    this.obscured = false,
    this.readOnly = false,
    this.filled = true,
    this.filledColor = Colors.white,
    this.textInputType = TextInputType.text,
    this.fontSize = 14,
  }) : super(key: key);

  @override
  State<CustomInput> createState() => _InputState();
}

class _InputState extends State<CustomInput> {
  bool _obscured = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        // 20px
        left: sizeWidth(context) * 3 / 100,
        right: sizeWidth(context) * 3 / 100,
        top: sizeHeight(context) * 3 / 100,
      ),
      child: TextFormField(
        validator: widget.validator,
        controller: widget.textEditingController,
        autofocus: false,
        obscureText: _obscured,
        cursorColor: primaryColor(),
        keyboardType: widget.textInputType,
        textCapitalization: widget.textCapitalization,
        readOnly: widget.readOnly,
        style: TextStyle(
          color: primaryColor(),
          // 12px
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
          fillColor: widget.filledColor,

          filled: widget.filled,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: widget.fontSize,
            color: grayInputColor(),
          ),
          //! LINEAL INPUT
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: grayInputColor(),
            fontWeight: FontWeight.bold,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: accentColor()),
          ),
          //! LINEAL INPUT
          suffixIcon: Visibility(
            visible: widget.obscured,
            child: IconButton(
              icon: Icon(
                _obscured ? Icons.visibility : Icons.visibility_off,
                color: grayInputColor(),
                size: widget.fontSize * 1.8,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
          ),
        ),
      ),
    );
  }
}
