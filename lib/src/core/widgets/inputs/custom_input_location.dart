import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/material.dart';

class CustomInputLocation extends StatefulWidget {
  final List locations;
  final String? title;
  final ValueNotifier<String> locationNotifier;

  const CustomInputLocation({
    super.key,
    required this.locations,
    required this.locationNotifier,
    this.title = 'Selecciona una ubicación',
  });

  @override
  State<CustomInputLocation> createState() => _CustomInputLocationState();
}

class _CustomInputLocationState extends State<CustomInputLocation> {
  LocationModel? selectedCountry;
  List filteredCountries = [];
  @override
  void initState() {
    super.initState();
    filteredCountries = widget.locations;
  }

  // void _filterCountries(String query) {
  //   final results =
  //       widget.locations.where((country) {
  //         final name = country.name!.toLowerCase();
  //         return name.startsWith(query.toLowerCase());
  //       }).toList();

  //   setState(() {
  //     filteredCountries = results;
  //     if (results.isNotEmpty) {
  //       selectedCountry = results.first;
  //       widget.locationNotifier.value = selectedCountry!.id;
  //     } else {
  //       selectedCountry = null;
  //       widget.locationNotifier.value = '';
  //     }
  //   });
  // }

  void _openCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: grayInputColor(),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            // Padding(
            //   padding: const EdgeInsets.all(12.0),
            //   child: TextField(
            //     style: const TextStyle(color: Colors.white),
            //     decoration: InputDecoration(
            //       hintText: "Buscar país",
            //       hintStyle: const TextStyle(color: Colors.white70),
            //       prefixIcon: const Icon(Icons.search, color: Colors.white),
            //       filled: true,
            //       fillColor: Colors.grey.shade800,
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //         borderSide: BorderSide.none,
            //       ),
            //     ),
            //     // onChanged: _filterCountries, // 🔑 cada vez que escriba, filtra
            //   ),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.locations.length,
                itemBuilder: (context, index) {
                  LocationModel country = widget.locations[index];
                  return ListTile(
                    leading:
                        (country.flag != '')
                            ? Text(
                              country.flag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            )
                            : null,
                    title: Text(
                      country.name,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    onTap: () {
                      setState(() {
                        selectedCountry = country;
                        widget.locationNotifier.value = country.id;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openCountryPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: grayInputColor(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            (selectedCountry != null)
                ? Text(
                  selectedCountry!.flag,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                )
                : const SizedBox(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCountry != null ? selectedCountry!.name : widget.title!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
