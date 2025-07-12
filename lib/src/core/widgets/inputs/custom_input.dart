import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final TextInputType textInputType;
  final String hintText;
  final bool? filled;
  final bool obscured;
  final Color? filledColor;
  final TextEditingController? textEditingController;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final Function? onEditingComplete;
  final int? maxLines;

  const CustomInput({
    super.key,
    required this.hintText,
    this.textEditingController,
    required this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.obscured = false,
    this.textInputType = TextInputType.text,
    this.filled = true,
    this.filledColor = const Color.fromARGB(255, 130, 130, 130),
    this.onEditingComplete,
    this.maxLines,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscured;
  }

  void _toggleVisibility() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines ?? 1,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      validator: widget.validator,
      onEditingComplete: () => widget.onEditingComplete?.call(),
      controller: widget.textEditingController,
      autofocus: false,
      obscureText: widget.obscured ? _obscured : false,
      cursorColor: accentColor(),
      keyboardType: widget.textInputType,
      textCapitalization: widget.textCapitalization,
      style: TextStyle(
        color: whiteColor(),
        fontSize: 14,
        fontWeight: FontWeight.w300,
      ),
      decoration: InputDecoration(
        fillColor: widget.filledColor,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        filled: widget.filled,
        hintText: widget.hintText,
        suffixIcon:
            widget.obscured
                ? IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: _toggleVisibility,
                )
                : null,
      ),
    );
  }
}
