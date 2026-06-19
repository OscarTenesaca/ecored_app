import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class CustomInputPhone extends StatefulWidget {
  final TextEditingController controller;
  final ValueNotifier<String> notifier;
  final String? hintText;
  final Color? fillColor;
  final double? fontSize;

  const CustomInputPhone({
    super.key,
    required this.controller,
    required this.notifier,
    this.hintText = '',
    this.fillColor = Colors.transparent,
    this.fontSize = 14,
  });

  @override
  State<CustomInputPhone> createState() => _CustomInputPhoneState();
}

class _CustomInputPhoneState extends State<CustomInputPhone> {
  String initialCountryCode = 'EC';

  @override
  void initState() {
    initialCountryCode =
        countries.firstWhere((element) {
          return element.dialCode == widget.notifier.value.split('+').last;
        }, orElse: () => countries[61]).code;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      disableLengthCheck: true,
      controller: widget.controller,

      onCountryChanged: (phone) {
        widget.notifier.value = "+${phone.dialCode}";
      },
      validator: (value) {
        if (value == null || value.number.trim().isEmpty) {
          return '* Ingrese su número de teléfono';
        }

        final country = PhoneNumber.getCountry(value!.completeNumber);
        if (value.number.startsWith('0')) {
          return 'El número de teléfono no puede comenzar con 0';
        }
        if (value.number.length < country.minLength) {
          return 'El número de teléfono es muy corto';
        }
        if (value.number.length > country.maxLength) {
          return 'El número de teléfono es muy largo';
        }
        return null;
      },
      dropdownDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: greyColorWithTransparency(),
      ),
      flagsButtonMargin: const EdgeInsets.all(5),
      flagsButtonPadding: const EdgeInsets.all(8),
      showDropdownIcon: false,
      cursorColor: accentColor(),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(18),
        ),

        fillColor: widget.fillColor,
        hintText: widget.hintText,

        // fillColor: widget.filledColor,
        filled: true,
        errorStyle: TextStyle(
          fontSize: widget.fontSize,
          color: Colors.red.shade300,
        ),
      ),

      initialCountryCode: initialCountryCode,
      style: TextStyle(
        // fontFamily: 'YaroRg',
        fontSize: widget.fontSize,
      ),
      dropdownTextStyle: TextStyle(
        // fontFamily: 'YaroRg',
        fontSize: widget.fontSize,
      ),
      pickerDialogStyle: PickerDialogStyle(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        countryCodeStyle: TextStyle(
          // fontFamily: 'YaroRg',
          color: whiteColor(),
          fontSize: widget.fontSize,
        ),
        listTileDivider: const SizedBox(height: 5),
        countryNameStyle: TextStyle(
          // fontFamily: 'YaroRg',
          color: whiteColor(),
          fontSize: widget.fontSize,
        ),
        searchFieldInputDecoration: InputDecoration(
          hintText: 'Buscar',
          hintStyle: TextStyle(
            fontFamily: 'YaroRg',
            color: whiteColor(),
            fontSize: widget.fontSize,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: whiteColor()),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: greyColorWithTransparency()),
          ),
        ),
      ),
    );
  }
}
