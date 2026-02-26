import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:flutter/material.dart';

class CustomInputLocation extends StatefulWidget {
  final List<LocationModel> locations;
  final String? title;
  final ValueNotifier<String> locationNotifier;
  final String? initialCountry; // ✅ ID del país por defecto

  const CustomInputLocation({
    super.key,
    required this.locations,
    required this.locationNotifier,
    this.title = 'Selecciona una ubicación',
    this.initialCountry = '',
  });

  @override
  State<CustomInputLocation> createState() => _CustomInputLocationState();
}

class _CustomInputLocationState extends State<CustomInputLocation> {
  LocationModel? selectedCountry;
  List<LocationModel> filteredCountries = [];

  @override
  void initState() {
    super.initState();
    filteredCountries = widget.locations;
  }

  @override
  void didUpdateWidget(covariant CustomInputLocation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialCountry!.isNotEmpty && widget.locations.isNotEmpty) {
      selectedCountry = widget.locations.firstWhere(
        (country) =>
            country.name.toUpperCase() == widget.initialCountry!.toUpperCase(),
      );

      // ⚡️ Diferir la actualización
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.locationNotifier.value = selectedCountry!.id;
      });
    }

    if (oldWidget.locations != widget.locations) {
      setState(() {
        filteredCountries = widget.locations;
      });
    }
  }

  void _openCountryPicker() {
    filteredCountries = widget.locations; // ✅ resetear al abrir

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          // 👈 esto permite setState dentro del modal
          builder: (context, setModalState) {
            void filterInModal(String query) {
              setModalState(() {
                if (query.isEmpty) {
                  filteredCountries = widget.locations;
                } else {
                  filteredCountries =
                      widget.locations.where((country) {
                        final name = country.name.toLowerCase();
                        return name.contains(query.toLowerCase());
                      }).toList();
                }
              });
            }

            return SafeArea(
              child: SizedBox(
                height: UtilSize.height(context) * 0.85, // 👈 altura 80%
                child: Column(
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

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        autofocus: true, // 👈 abre con teclado listo
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Buscar ubicación",
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade800,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: filterInModal,
                      ),
                    ),

                    Expanded(
                      child:
                          filteredCountries.isEmpty
                              ? const Center(
                                child: Text(
                                  "No se encontraron resultados",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                              : ListView.builder(
                                itemCount: filteredCountries.length,
                                itemBuilder: (context, index) {
                                  LocationModel country =
                                      filteredCountries[index];
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedCountry = country;
                                        widget.locationNotifier.value =
                                            country.id;
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
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
            if (selectedCountry != null)
              Text(
                selectedCountry!.flag,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
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
