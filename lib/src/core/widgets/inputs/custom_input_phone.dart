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

  const CustomInputPhone({
    super.key,
    required this.controller,
    required this.notifier,
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
      cursorColor: whiteColor(),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        fillColor: grayInputColor(),
        filled: true,
        errorStyle: TextStyle(fontSize: 12, color: Colors.red.shade300),
      ),

      initialCountryCode: initialCountryCode,
      style: const TextStyle(
        // fontFamily: 'YaroRg',
        fontSize: 12,
      ),
      dropdownTextStyle: const TextStyle(
        // fontFamily: 'YaroRg',
        fontSize: 12,
      ),
      pickerDialogStyle: PickerDialogStyle(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        countryCodeStyle: TextStyle(
          // fontFamily: 'YaroRg',
          color: whiteColor(),
          fontSize: 12,
        ),
        listTileDivider: const SizedBox(height: 5),
        countryNameStyle: TextStyle(
          // fontFamily: 'YaroRg',
          color: whiteColor(),
          fontSize: 12,
        ),
        searchFieldInputDecoration: InputDecoration(
          hintText: 'Buscar',
          hintStyle: TextStyle(
            fontFamily: 'YaroRg',
            color: whiteColor(),
            fontSize: 12,
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
