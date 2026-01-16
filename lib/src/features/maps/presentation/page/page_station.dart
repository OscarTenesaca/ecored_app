import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
import 'package:ecored_app/src/core/services/location_service.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';
import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class PageStation extends StatefulWidget {
  const PageStation({super.key});

  @override
  State<PageStation> createState() => _PageStationState();
}

class _PageStationState extends State<PageStation> {
  // ───────────────── PAGE CONTROL ─────────────────
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // ───────────────── STEP 1 ─────────────────
  final ValueNotifier<String> prefixNotifier = ValueNotifier('+593');
  final ValueNotifier<Map<String, String>> stTypePnNotifier = ValueNotifier({});
  final ValueNotifier<Map<String, String>> stStatusNotifier = ValueNotifier({});
  final _basicFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ───────────────── STEP 2 ─────────────────
  final _locationFormKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final ValueNotifier<Map<String, String>> stLatLngNotifier = ValueNotifier({});
  final ValueNotifier<String> countryNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> provinceNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> cantonNotifier = ValueNotifier<String>('');

  // ───────────────── STEP 3 (CHARGERS) ─────────────────
  List<Map<String, dynamic>> chargers = [];

  final String msgValidation =
      'Faltan campos por completar. Revise la información e intente nuevamente.';

  @override
  void initState() {
    super.initState();
    _addCharger(); // al menos uno por defecto
  }

  void _addCharger() {
    chargers.add({
      // VALUE NOTIFIERS
      "typeConnection": ValueNotifier<Map<String, String>?>(null),
      "status": ValueNotifier<Map<String, String>?>(null),
      "format": ValueNotifier<Map<String, String>?>(null),
      "typeCharger": ValueNotifier<Map<String, String>?>(null),
      "powerKw": TextEditingController(),
      "intensity": TextEditingController(),
      "voltage": TextEditingController(),
      "priceWithTipeConnector": TextEditingController(),
    });
    setState(() {});
  }

  void _removeCharger(int index) {
    if (chargers.length == 1) return;
    chargers.removeAt(index);
    setState(() {});
  }

  // ───────────────── NAVIGATION ─────────────────
  void _next() {
    bool isValidNotifyStep1 =
        prefixNotifier.value.isNotEmpty &&
        stTypePnNotifier.value.isNotEmpty &&
        stStatusNotifier.value.isNotEmpty;

    if (_currentStep == 0 && !_basicFormKey.currentState!.validate()) return;
    if (_currentStep == 0 && !isValidNotifyStep1) {
      showSnackbar(context, msgValidation, SnackbarStatus.waiting);
      return;
    }

    if (_currentStep == 1 && !_locationFormKey.currentState!.validate()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ───────────────── SUBMIT ─────────────────
  void _submit() async {
    final stationProvider = context.read<StationProvider>();

    /// 1️⃣ BODY DE LA STATION
    final bodyStation = {
      "user": Preferences().getUser()!.id,
      "name": _nameController.text,
      "prefixCode": prefixNotifier.value,
      "phone": _phoneController.text,
      "description": _descriptionController.text,
      "status": stStatusNotifier.value['key'],
      "typePoint": stTypePnNotifier.value['key'],
      "address": _addressController.text,
      "country": countryNotifier.value,
      "province": provinceNotifier.value,
      "canton": cantonNotifier.value,
      "location": {
        "type": "Point",
        "coordinates": [
          stLatLngNotifier.value['lng'] ?? 0,
          stLatLngNotifier.value['lat'] ?? 0,
        ],
      },
    };

    late ModelStation station;

    /// 2️⃣ CREAR STATION
    try {
      station = await stationProvider.createStation(bodyStation);
      debugPrint('Station creada: ${station.toJson()}');
    } catch (e) {
      debugPrint('Error creating station: $e');
      showPopUpWithChildren(
        context: context,
        title: 'No se pudo completar la acción',
        subTitle:
            'No pudimos crear la estación en este momento.\nInténtalo de nuevo.',
        textButton: 'Aceptar',
      );
      return;
    }

    /// 3️⃣ BODY DE LOS CHARGERS
    final List<Map<String, dynamic>> bodyChargers =
        chargers.map((c) {
          return {
            "station": station.id,
            "typeConnection": c["typeConnection"]!.value['key'],
            "status": c["status"]!.value['key'],
            "format": c["format"]!.value['key'],
            "typeCharger": c["typeCharger"]!.value['key'],
            "powerKw": c["powerKw"]!.text,
            "intensity": c["intensity"]!.text,
            "voltage": c["voltage"]!.text,
            "priceWithTipeConnector": c["priceWithTipeConnector"]!.text,
          };
        }).toList();

    /// 4️⃣ CREAR CHARGERS 1 x 1
    int successCount = 0;

    for (final charger in bodyChargers) {
      try {
        final statusCode = await stationProvider.createCharger(charger);
        if (statusCode == 201) {
          successCount++;
        }
      } catch (e) {
        debugPrint('Error creando charger: $e');
      }
    }

    /// 5️⃣ RESULTADO FINAL
    if (successCount == bodyChargers.length) {
      showPopUpWithChildren(
        context: context,
        title: '¡Estación creada!',
        subTitle:
            'La estación y todos sus cargadores han sido creados exitosamente.',
        textButton: 'Aceptar',
        // onSubmit: () {
        //   Navigator.pop(context);
        // },
      );
    } else {
      showPopUpWithChildren(
        context: context,
        title: 'Estación creada con errores',
        subTitle:
            'La estación fue creada, pero algunos cargadores no pudieron ser añadidos.\nInténtalo de nuevo.',
        textButton: 'Aceptar',
        // onSubmit: () {
        //   Navigator.pop(context); // cerrar el popup
        // },
      );
    }
  }

  // ───────────────── UI ─────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: UtilSize.appBarHeight()),
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_stepBasic(), _stepLocation(), _stepChargers()],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // ───────────────── STEP INDICATOR ─────────────────
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 30,
            height: 6,
            decoration: BoxDecoration(
              color:
                  _currentStep >= index
                      ? accentColor()
                      : greyColorWithTransparency(),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  // ───────────────── STEP 1 ─────────────────
  Widget _stepBasic() {
    return Form(
      key: _basicFormKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            spacing: 25,
            children: [
              CustomAssetImg(width: 200, height: 100),

              CustomInput(
                hintText: 'Nombre de la estación',
                textEditingController: _nameController,
                validator: (v) => v!.isEmpty ? '* Ingrese el nombre' : null,
              ),

              CustomInputPhone(
                controller: _phoneController,
                notifier: prefixNotifier,
              ),

              CustomButtonSelect(
                title: 'Seleccionar tipo de punto',
                selectNotifier: stTypePnNotifier,
                optionsList: STATION_TYPE_POINTS_LIST,
              ),

              CustomButtonSelect(
                title: 'Seleccionar estado',
                selectNotifier: stStatusNotifier,
                optionsList: STATION_STATUS_LIST,
              ),
              CustomInput(
                hintText: 'Descripción',
                textEditingController: _descriptionController,
                maxLines: 3,
                validator:
                    (v) => v!.isEmpty ? '* Ingrese la descripción' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── STEP 2 ─────────────────
  Widget _stepLocation() {
    return Form(
      key: _locationFormKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            spacing: 10,
            children: [
              CustomInput(
                hintText: 'Dirección',
                textEditingController: _addressController,
                validator: (v) => v!.isEmpty ? '* Ingrese la dirección' : null,
              ),

              Row(
                children: [
                  Flexible(
                    child: FutureBuilder<List<LocationModel>>(
                      future: LocationServiceImpl().countries(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Text('Error al cargar países');
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No hay países disponibles');
                        }

                        return CustomInputLocation(
                          locations:
                              snapshot.data!, // ✅ usa los datos del Future
                          locationNotifier: countryNotifier,
                          title: 'País',
                          initialCountry: 'ECUADOR',
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: countryNotifier,
                    builder: (context, country, child) {
                      return FutureBuilder<List<LocationModel>>(
                        future: LocationServiceImpl().provinces({
                          'country': country,
                        }),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          return Flexible(
                            child: CustomInputLocation(
                              locations: snapshot.data!,
                              locationNotifier: provinceNotifier,
                              title: 'Provincia',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),

              // Ciudad
              ValueListenableBuilder<String>(
                valueListenable: provinceNotifier,
                builder: (context, province, child) {
                  return FutureBuilder<List<LocationModel>>(
                    future: LocationServiceImpl().cantons({
                      'province': province,
                    }),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      return CustomInputLocation(
                        locations: snapshot.data!,
                        locationNotifier: cantonNotifier,
                        title: 'Ciudad',
                      );
                    },
                  );
                },
              ),
              Consumer<PermissionGpsProvider>(
                builder: (context, gps, _) {
                  if (gps.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!gps.isAllGranted) {
                    return const Center(child: Text('GPS no disponible'));
                  }

                  if (gps.currentPosition == null) {
                    gps.getCurrentPosition(); // se pide una sola vez
                    return const Center(child: Text('Obteniendo ubicación...'));
                  }

                  final position = gps.currentPosition!;

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: SizedBox(
                      width: double.infinity,
                      height: UtilSize.height(context) * 0.5,
                      child: CustomMapPin(
                        initialPosition: LatLng(
                          position.latitude,
                          position.longitude,
                        ),
                        onLocationSelected: (latLng) {
                          stLatLngNotifier.value = {
                            'lat': latLng.latitude.toString(),
                            'lng': latLng.longitude.toString(),
                          };
                          print(stLatLngNotifier.value);
                        },
                      ),
                    ),
                  );
                },
              ),

              // ClipRRect(
              //   borderRadius: BorderRadius.circular(15),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: UtilSize.height(context) * 0.5,
              //     child: CustomMapPin(
              //       initialPosition:await PermissionGpsProvider().getCurrentPosition();,
              //       onLocationSelected: (latLng) {
              //         stLatLngNotifier.value = {
              //           'lat': latLng.latitude.toString(),
              //           'lng': latLng.longitude.toString(),
              //         };
              //         print(stLatLngNotifier.value);
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── STEP 3 ─────────────────
  Widget _stepChargers() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...chargers.asMap().entries.map((entry) {
          final index = entry.key;
          final c = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: greyColorWithTransparency(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                spacing: 12,
                children: [
                  Row(
                    children: [
                      Text(
                        "Charger ${index + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _removeCharger(index),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Flexible(
                        child: CustomButtonSelect(
                          title: 'Conector',
                          selectNotifier:
                              c["typeConnection"]
                                  as ValueNotifier<Map<String, String>?>,
                          optionsList: CONECTORS_TYPE_LIST,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: CustomButtonSelect(
                          title: 'Estado',
                          selectNotifier:
                              c["status"]
                                  as ValueNotifier<Map<String, String>?>,
                          optionsList: STATION_STATUS_LIST,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Flexible(
                        child: CustomButtonSelect(
                          title: 'Formato',
                          selectNotifier:
                              c["format"]
                                  as ValueNotifier<Map<String, String>?>,
                          optionsList: CHARGER_FORMAT_LIST,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: CustomButtonSelect(
                          title: 'Tipo Charger',
                          selectNotifier:
                              c["typeCharger"]
                                  as ValueNotifier<Map<String, String>?>,
                          optionsList: CHARGER_TYPE_LIST,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 15,
                    children: [
                      Flexible(
                        child: CustomInput(
                          hintText: 'Voltaje (V)',
                          textEditingController: c["voltage"],
                          textInputType: TextInputType.number,
                          validator:
                              (v) => v!.isEmpty ? '* Ingrese el nombre' : null,
                        ),
                      ),

                      Flexible(
                        child: CustomInput(
                          hintText: 'Intensidad (A)',
                          textEditingController: c["intensity"],
                          textInputType: TextInputType.number,
                          validator: null,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: 15,
                    children: [
                      Flexible(
                        child: CustomInput(
                          hintText: 'Carga (kW)',
                          textEditingController: c["powerKw"],
                          textInputType: TextInputType.number,
                          validator:
                              (v) => v!.isEmpty ? '* Ingrese el nombre' : null,
                        ),
                      ),

                      Flexible(
                        child: CustomInput(
                          hintText: 'Precio (kWh)',
                          textEditingController: c["priceWithTipeConnector"],
                          textInputType: TextInputType.number,
                          validator: null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: _addCharger,
          icon: const Icon(Icons.add),
          label: const Text("Agregar charger"),
        ),
      ],
    );
  }

  // ───────────────── NAV BUTTONS ─────────────────
  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.only(bottom: UtilSize.bottomPadding()),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                textButton: 'Atras',
                buttonColor: greyColorWithTransparency(),
                textButtonColor: accentColor(),
                onPressed: _back,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              textButton: _currentStep == 2 ? 'Guardar' : 'Siguiente',
              buttonColor: accentColor(),
              textButtonColor: primaryColor(),
              onPressed: _currentStep == 2 ? _submit : _next,
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:ecored_app/src/core/models/location_model.dart';
// import 'package:ecored_app/src/core/services/location_service.dart';
// import 'package:ecored_app/src/core/theme/theme_index.dart';
// import 'package:ecored_app/src/core/utils/utils_index.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:flutter/material.dart';

// class PageStation extends StatefulWidget {
//   const PageStation({super.key});

//   @override
//   State<PageStation> createState() => _PageStationState();
// }

// class _PageStationState extends State<PageStation> {
//   // Page control
//   final PageController _pageController = PageController();
//   int _currentStep = 0;

//   // Form keys
//   final _basicFormKey = GlobalKey<FormState>();
//   final _locationFormKey = GlobalKey<FormState>();
//   final _chargerFormKey = GlobalKey<FormState>();

//   // Controllers
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _addressController = TextEditingController();

//   final ValueNotifier<String> prefixNotifier = ValueNotifier<String>('+593');
//   final ValueNotifier<Map<String, String>> stationTypePointsNotifier =
//       ValueNotifier<Map<String, String>>({});
//   final ValueNotifier<Map<String, String>> stationStatusNotifier =
//       ValueNotifier<Map<String, String>>({});

//   final ValueNotifier<String> countryNotifier = ValueNotifier<String>('');
//   final ValueNotifier<String> provinceNotifier = ValueNotifier<String>('');
//   final ValueNotifier<String> cantonNotifier = ValueNotifier<String>('');

//   // =========================
//   // CHARGERS STATE (SIN MODELO)
//   // =========================
//   int chargersCount = 0;
//   int activeChargerIndex = -1;

//   final ValueNotifier<Map<String, String>> chargeConectorNotifier =
//       ValueNotifier<Map<String, String>>({});
//   final ValueNotifier<Map<String, String>> chargeStatusNotifier =
//       ValueNotifier<Map<String, String>>({});
//   final ValueNotifier<Map<String, String>> chargeTypeNotifier =
//       ValueNotifier<Map<String, String>>({});
//   final ValueNotifier<Map<String, String>> chargeFormatNotifier =
//       ValueNotifier<Map<String, String>>({});

//   final _chargekw = TextEditingController();
//   final _amperage = TextEditingController();
//   final _voltage = TextEditingController();
//   final _price = TextEditingController();

//   // STEP CONTROL
//   void _nextStep() {
//     if (_currentStep == 0 && _basicFormKey.currentState!.validate()) {
//       _goNext();
//     } else if (_currentStep == 1 && _locationFormKey.currentState!.validate()) {
//       _goNext();
//     }
//   }

//   void _goNext() {
//     _pageController.nextPage(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//     setState(() => _currentStep++);
//   }

//   void _goBack() {
//     if (_currentStep > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//       setState(() => _currentStep--);
//     }
//   }

//   void _addCharger() {}

//   void _removeCharger(int index) {}

//   void _saveStationCharger() {
//     print('Guardar estación y cargadores');
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _nameController.dispose();
//     _phoneController.dispose();
//     _descriptionController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> _steps = [_basicInfoStep(), _locationStep(), _chargerStep()];

//     return Scaffold(
//       backgroundColor: primaryColor(),
//       body: Padding(
//         padding: EdgeInsets.only(
//           top: UtilSize.appBarHeight(),
//           left: 20,
//           right: 20,
//         ),
//         child: Column(
//           children: [
//             _stepIndicator(_steps.length),
//             const SizedBox(height: 20),
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: _steps,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // =========================
//   // STEP INDICATOR
//   // =========================
//   Widget _stepIndicator(int totalSteps) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(totalSteps, (index) {
//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 6),
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: index <= _currentStep ? accentColor() : Colors.grey,
//           ),
//         );
//       }),
//     );
//   }

//   // =========================
//   // STEP 1 - BASIC INFO
//   // =========================
//   Widget _basicInfoStep() {
//     return Form(
//       key: _basicFormKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           CustomAssetImg(width: 200, height: 100),

//           CustomInput(
//             hintText: 'Nombre de la estación',
//             textEditingController: _nameController,
//             validator: (value) => value!.isEmpty ? '* Ingrese el nombre' : null,
//           ),

//           CustomInputPhone(
//             controller: _phoneController,
//             notifier: prefixNotifier,
//           ),

//           CustomButtonSelect(
//             title: 'Seleccionar tipo de punto',
//             selectNotifier: stationTypePointsNotifier,
//             optionsList: STATION_TYPE_POINTS_LIST,
//           ),

//           CustomButtonSelect(
//             title: 'Seleccionar estado de la estación',
//             selectNotifier: stationStatusNotifier,
//             optionsList: STATION_STATUS_LIST,
//           ),

//           CustomInput(
//             hintText: 'Descripción',
//             textEditingController: _descriptionController,
//             validator:
//                 (value) => value!.isEmpty ? '* Ingrese la descripción' : null,
//           ),

//           CustomButton(
//             textButton: 'Siguiente',
//             buttonColor: accentColor(),
//             textButtonColor: primaryColor(),
//             onPressed: _nextStep,
//           ),
//         ],
//       ),
//     );
//   }

//   // =========================
//   // STEP 2 - LOCATION
//   // =========================

//   Widget _locationStep() {
//     LocationServiceImpl locationService = LocationServiceImpl();

//     return Form(
//       key: _locationFormKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           // Dirección
//           CustomInput(
//             hintText: 'Dirección',
//             textEditingController: _addressController,
//             validator:
//                 (value) => value!.isEmpty ? '* Ingrese la dirección' : null,
//           ),

//           // País
//           FutureBuilder(
//             future: locationService.countries(),
//             builder: (BuildContext context, AsyncSnapshot snapshot) {
//               if (!snapshot.hasData) {
//                 return const CircularProgressIndicator();
//               }

//               provinceNotifier.value = '';
//               cantonNotifier.value = '';

//               return CustomInputLocation(
//                 locations: snapshot.data!,
//                 locationNotifier: countryNotifier,
//                 title: 'País',
//                 initialCountry: 'ECUADOR',
//               );
//             },
//           ),

//           // Provincia + Ciudad
//           Row(
//             children: [
//               // Provincia
//               Expanded(
//                 child: ValueListenableBuilder<String>(
//                   valueListenable: countryNotifier,
//                   builder: (context, country, child) {
//                     return FutureBuilder<List<LocationModel>>(
//                       future: locationService.provinces({'country': country}),
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData) {
//                           return const CircularProgressIndicator();
//                         }

//                         cantonNotifier.value = '';

//                         return CustomInputLocation(
//                           locations: snapshot.data!,
//                           locationNotifier: provinceNotifier,
//                           title: 'Provincia',
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(width: 10),

//               // Ciudad
//               Expanded(
//                 child: ValueListenableBuilder<String>(
//                   valueListenable: provinceNotifier,
//                   builder: (context, province, child) {
//                     return FutureBuilder<List<LocationModel>>(
//                       future: locationService.cantons({'province': province}),
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData) {
//                           return const CircularProgressIndicator();
//                         }

//                         return CustomInputLocation(
//                           locations: snapshot.data!,
//                           locationNotifier: cantonNotifier,
//                           title: 'Ciudad',
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),

//           // Mapa
//           Container(
//             width: double.infinity,
//             height: UtilSize.height(context) * 0.5,
//             decoration: BoxDecoration(
//               color: greyColorWithTransparency(),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: const Center(child: Text('Mapa de ubicación aquí')),
//           ),

//           // Botones
//           Row(
//             children: [
//               Expanded(
//                 child: CustomButton(
//                   textButton: 'Atrás',
//                   onPressed: _goBack,
//                   textButtonColor: primaryColor(),
//                   buttonColor: accentColor(),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: CustomButton(
//                   textButton: 'Siguiente',
//                   onPressed: _nextStep,
//                   textButtonColor: primaryColor(),
//                   buttonColor: accentColor(),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // =========================
//   // STEP 3 - CHARGERS
//   // =========================

//   Widget _chargerStep() {
//     return Form(
//       key: _chargerFormKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Agregar cargadores',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.add_circle, color: Colors.white),
//                 onPressed: _addCharger,
//               ),
//             ],
//           ),
//           const SizedBox(height: 30),

//           // add n new charger form
//           Flexible(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // SELECTS (full width)
//                   Row(
//                     children: [
//                       Flexible(
//                         child: CustomButtonSelect(
//                           title: 'Conector',
//                           selectNotifier: chargeConectorNotifier,
//                           optionsList: CONECTORS_TYPE_LIST,
//                         ),
//                       ),
//                       Flexible(
//                         child: CustomButtonSelect(
//                           title: 'Estado',
//                           selectNotifier: chargeStatusNotifier,
//                           optionsList: STATION_STATUS_LIST,
//                         ),
//                       ),
//                     ],
//                   ),

//                   Row(
//                     children: [
//                       Flexible(
//                         child: CustomButtonSelect(
//                           title: 'Tipo',
//                           selectNotifier: chargeTypeNotifier,
//                           optionsList: CHARGER_TYPE_LIST,
//                         ),
//                       ),

//                       Flexible(
//                         child: CustomButtonSelect(
//                           title: 'Formato',
//                           selectNotifier: chargeFormatNotifier,
//                           optionsList: CHARGER_FORMAT_LIST,
//                         ),
//                       ),
//                     ],
//                   ),

//                   // INPUTS NUMÉRICOS (2 por fila)
//                   Row(
//                     children: [
//                       Expanded(
//                         child: CustomInput(
//                           hintText: 'Carga (kW)',
//                           textEditingController: _chargekw,
//                           textInputType: TextInputType.number,
//                           validator:
//                               (value) =>
//                                   value!.isEmpty ? '* Ingrese los kW' : null,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: CustomInput(
//                           hintText: 'Intensidad (A)',
//                           textEditingController: _amperage,
//                           textInputType: TextInputType.number,
//                           validator:
//                               (value) =>
//                                   value!.isEmpty
//                                       ? '* Ingrese el amperaje'
//                                       : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: CustomInput(
//                           hintText: 'Voltaje (V)',
//                           textEditingController: _voltage,
//                           textInputType: TextInputType.number,
//                           validator:
//                               (value) =>
//                                   value!.isEmpty
//                                       ? '* Ingrese el voltaje'
//                                       : null,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: CustomInput(
//                           hintText: 'Precio (por kWh)',
//                           textEditingController: _price,
//                           textInputType: TextInputType.number,
//                           validator:
//                               (value) =>
//                                   value!.isEmpty ? '* Ingrese el precio' : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // card expanded list of chargers added
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: CustomButton(
//                   textButton: 'Atrás',
//                   onPressed: () {
//                     // atras
//                   },
//                   textButtonColor: primaryColor(),
//                   buttonColor: accentColor(),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: CustomButton(
//                   textButton: 'Guardar',
//                   onPressed: () {},
//                   textButtonColor: primaryColor(),
//                   buttonColor: accentColor(),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


/*
import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/services/location_service.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:flutter/material.dart';

class PageStation extends StatefulWidget {
  const PageStation({super.key});

  @override
  State<PageStation> createState() => _PageStationState();
}

class _PageStationState extends State<PageStation> {
  // Page control
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form keys
  final _basicFormKey = GlobalKey<FormState>();
  final _locationFormKey = GlobalKey<FormState>();
  final _chargerFormKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  final ValueNotifier<String> prefixNotifier = ValueNotifier<String>('+593');
  final ValueNotifier<Map<String, String>> stationTypePointsNotifier =
      ValueNotifier<Map<String, String>>({});
  final ValueNotifier<Map<String, String>> stationStatusNotifier =
      ValueNotifier<Map<String, String>>({});

  final ValueNotifier<String> countryNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> provinceNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> cantonNotifier = ValueNotifier<String>('');

  // =========================
  // CHARGERS STATE (SIN MODELO)
  // =========================
  int chargersCount = 0;
  int activeChargerIndex = -1;

  final ValueNotifier<Map<String, String>> chargeConectorNotifier =
      ValueNotifier<Map<String, String>>({});
  final ValueNotifier<Map<String, String>> chargeStatusNotifier =
      ValueNotifier<Map<String, String>>({});
  final ValueNotifier<Map<String, String>> chargeTypeNotifier =
      ValueNotifier<Map<String, String>>({});
  final ValueNotifier<Map<String, String>> chargeFormatNotifier =
      ValueNotifier<Map<String, String>>({});

  final _chargekw = TextEditingController();
  final _amperage = TextEditingController();
  final _voltage = TextEditingController();
  final _price = TextEditingController();

  // STEP CONTROL
  void _nextStep() {
    if (_currentStep == 0 && _basicFormKey.currentState!.validate()) {
      _goNext();
    } else if (_currentStep == 1 &&
        _locationFormKey.currentState!.validate() &&
        countryNotifier.value.isNotEmpty &&
        provinceNotifier.value.isNotEmpty &&
        cantonNotifier.value.isNotEmpty) {
      _goNext();
    }
  }

  void _goNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep++);
  }

  void _goBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  void _addCharger() {}

  void _removeCharger(int index) {}

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _steps = [_chargerStep(), _basicInfoStep(), _locationStep()];

    return Scaffold(
      backgroundColor: primaryColor(),
      body: Padding(
        padding: EdgeInsets.only(
          top: UtilSize.appBarHeight(),
          left: 20,
          right: 20,
        ),
        child: Column(
          children: [
            _stepIndicator(_steps.length),
            const SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _steps,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // STEP INDICATOR
  // =========================
  Widget _stepIndicator(int totalSteps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentStep ? accentColor() : Colors.grey,
          ),
        );
      }),
    );
  }

  // =========================
  // STEP 1 - BASIC INFO
  // =========================
  Widget _basicInfoStep() {
    return Form(
      key: _basicFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomAssetImg(width: 200, height: 100),

          CustomInput(
            hintText: 'Nombre de la estación',
            textEditingController: _nameController,
            validator: (value) => value!.isEmpty ? '* Ingrese el nombre' : null,
          ),

          CustomInputPhone(
            controller: _phoneController,
            notifier: prefixNotifier,
          ),

          CustomButtonSelect(
            title: 'Seleccionar tipo de punto',
            selectNotifier: stationTypePointsNotifier,
            optionsList: STATION_TYPE_POINTS_LIST,
          ),

          CustomButtonSelect(
            title: 'Seleccionar estado de la estación',
            selectNotifier: stationStatusNotifier,
            optionsList: STATION_STATUS_LIST,
          ),

          CustomInput(
            hintText: 'Descripción',
            textEditingController: _descriptionController,
            validator:
                (value) => value!.isEmpty ? '* Ingrese la descripción' : null,
          ),

          CustomButton(
            textButton: 'Siguiente',
            buttonColor: accentColor(),
            textButtonColor: primaryColor(),
            onPressed: _nextStep,
          ),
        ],
      ),
    );
  }

  // =========================
  // STEP 2 - LOCATION
  // =========================

  Widget _locationStep() {
    LocationServiceImpl locationService = LocationServiceImpl();

    return Form(
      key: _locationFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Dirección
          CustomInput(
            hintText: 'Dirección',
            textEditingController: _addressController,
            validator:
                (value) => value!.isEmpty ? '* Ingrese la dirección' : null,
          ),

          // País
          FutureBuilder(
            future: locationService.countries(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              provinceNotifier.value = '';
              cantonNotifier.value = '';

              return CustomInputLocation(
                locations: snapshot.data!,
                locationNotifier: countryNotifier,
                title: 'País',
                initialCountry: 'ECUADOR',
              );
            },
          ),

          // Provincia + Ciudad
          Row(
            children: [
              // Provincia
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: countryNotifier,
                  builder: (context, country, child) {
                    return FutureBuilder<List<LocationModel>>(
                      future: locationService.provinces({'country': country}),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        cantonNotifier.value = '';

                        return CustomInputLocation(
                          locations: snapshot.data!,
                          locationNotifier: provinceNotifier,
                          title: 'Provincia',
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(width: 10),

              // Ciudad
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: provinceNotifier,
                  builder: (context, province, child) {
                    return FutureBuilder<List<LocationModel>>(
                      future: locationService.cantons({'province': province}),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        return CustomInputLocation(
                          locations: snapshot.data!,
                          locationNotifier: cantonNotifier,
                          title: 'Ciudad',
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Mapa
          Container(
            width: double.infinity,
            height: UtilSize.height(context) * 0.5,
            decoration: BoxDecoration(
              color: greyColorWithTransparency(),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(child: Text('Mapa de ubicación aquí')),
          ),

          // Botones
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  textButton: 'Atrás',
                  onPressed: _goBack,
                  textButtonColor: primaryColor(),
                  buttonColor: accentColor(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  textButton: 'Siguiente',
                  onPressed: _nextStep,
                  textButtonColor: primaryColor(),
                  buttonColor: accentColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // STEP 3 - CHARGERS
  // =========================

  Widget _chargerStep() {
    return Form(
      key: _chargerFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Agregar cargadores',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.white),
                onPressed: _addCharger,
              ),
            ],
          ),
          const SizedBox(height: 30),

          // add n new charger form
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SELECTS (full width)
                  Row(
                    children: [
                      Flexible(
                        child: CustomButtonSelect(
                          title: 'Conector',
                          selectNotifier: chargeConectorNotifier,
                          optionsList: CONECTORS_TYPE_LIST,
                        ),
                      ),
                      Flexible(
                        child: CustomButtonSelect(
                          title: 'Estado',
                          selectNotifier: chargeStatusNotifier,
                          optionsList: STATION_STATUS_LIST,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Flexible(
                        child: CustomButtonSelect(
                          title: 'Tipo',
                          selectNotifier: chargeTypeNotifier,
                          optionsList: CHARGER_TYPE_LIST,
                        ),
                      ),

                      Flexible(
                        child: CustomButtonSelect(
                          title: 'Formato',
                          selectNotifier: chargeFormatNotifier,
                          optionsList: CHARGER_FORMAT_LIST,
                        ),
                      ),
                    ],
                  ),

                  // INPUTS NUMÉRICOS (2 por fila)
                  Row(
                    children: [
                      Expanded(
                        child: CustomInput(
                          hintText: 'Carga (kW)',
                          textEditingController: _chargekw,
                          textInputType: TextInputType.number,
                          validator:
                              (value) =>
                                  value!.isEmpty ? '* Ingrese los kW' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomInput(
                          hintText: 'Intensidad (A)',
                          textEditingController: _amperage,
                          textInputType: TextInputType.number,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? '* Ingrese el amperaje'
                                      : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: CustomInput(
                          hintText: 'Voltaje (V)',
                          textEditingController: _voltage,
                          textInputType: TextInputType.number,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? '* Ingrese el voltaje'
                                      : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomInput(
                          hintText: 'Precio (por kWh)',
                          textEditingController: _price,
                          textInputType: TextInputType.number,
                          validator:
                              (value) =>
                                  value!.isEmpty ? '* Ingrese el precio' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // card expanded list of chargers added
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  textButton: 'Atrás',
                  onPressed: () {
                    // atras
                  },
                  textButtonColor: primaryColor(),
                  buttonColor: accentColor(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  textButton: 'Guardar',
                  onPressed: () {},
                  textButtonColor: primaryColor(),
                  buttonColor: accentColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/



// !valid
// import 'package:ecored_app/src/core/models/location_model.dart';
// import 'package:ecored_app/src/core/services/location_service.dart';
// import 'package:ecored_app/src/core/theme/theme_index.dart';
// import 'package:ecored_app/src/core/utils/utils_index.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:flutter/material.dart';

// class PageStation extends StatefulWidget {
//   const PageStation({super.key});

//   @override
//   State<PageStation> createState() => _PageStationState();
// }

// class _PageStationState extends State<PageStation> {
//   // =========================
//   // PAGE CONTROL
//   // =========================
//   final PageController _pageController = PageController();
//   int _currentStep = 0;

//   // =========================
//   // FORM KEYS
//   // =========================
//   final _basicFormKey = GlobalKey<FormState>();
//   final _locationFormKey = GlobalKey<FormState>();
//   final _chargerFormKey = GlobalKey<FormState>();

//   // =========================
//   // BASIC INFO CONTROLLERS
//   // =========================
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _addressController = TextEditingController();

//   final ValueNotifier<String> prefixNotifier = ValueNotifier('+593');
//   final ValueNotifier<Map<String, String>> stationTypePointsNotifier =
//       ValueNotifier({});
//   final ValueNotifier<Map<String, String>> stationStatusNotifier =
//       ValueNotifier({});

//   final ValueNotifier<String> countryNotifier = ValueNotifier('');
//   final ValueNotifier<String> provinceNotifier = ValueNotifier('');
//   final ValueNotifier<String> cantonNotifier = ValueNotifier('');

//   // =========================
//   // CHARGERS STATE (SIN MODELO)
//   // =========================
//   int chargersCount = 0;
//   int activeChargerIndex = -1;

//   // SELECT NOTIFIERS (REUTILIZADOS)
//   final ValueNotifier<Map<String, String>> chargeConectorNotifier =
//       ValueNotifier({});
//   final ValueNotifier<Map<String, String>> chargeStatusNotifier = ValueNotifier(
//     {},
//   );
//   final ValueNotifier<Map<String, String>> chargeTypeNotifier = ValueNotifier(
//     {},
//   );
//   final ValueNotifier<Map<String, String>> chargeFormatNotifier = ValueNotifier(
//     {},
//   );

//   // INPUT CONTROLLERS
//   final _chargekw = TextEditingController();
//   final _amperage = TextEditingController();
//   final _voltage = TextEditingController();
//   final _price = TextEditingController();

//   // =========================
//   // STEP CONTROL
//   // =========================
//   void _nextStep() {
//     if (_currentStep == 0 && _basicFormKey.currentState!.validate()) {
//       _goNext();
//     } else if (_currentStep == 1 &&
//         _locationFormKey.currentState!.validate() &&
//         countryNotifier.value.isNotEmpty &&
//         provinceNotifier.value.isNotEmpty &&
//         cantonNotifier.value.isNotEmpty) {
//       _goNext();
//     }
//   }

//   void _goNext() {
//     _pageController.nextPage(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//     setState(() => _currentStep++);
//   }

//   void _goBack() {
//     if (_currentStep > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//       setState(() => _currentStep--);
//     }
//   }

//   // =========================
//   // CHARGER ACTIONS
//   // =========================
//   void _addCharger() {
//     setState(() {
//       activeChargerIndex = chargersCount;
//       chargersCount++;
//     });
//   }

//   void _removeCharger(int index) {
//     setState(() {
//       if (activeChargerIndex == index) {
//         activeChargerIndex = -1;
//       } else if (activeChargerIndex > index) {
//         activeChargerIndex--;
//       }
//       chargersCount--;
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _nameController.dispose();
//     _phoneController.dispose();
//     _descriptionController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final steps = [_chargerStep(), _basicInfoStep(), _locationStep()];

//     return Scaffold(
//       backgroundColor: primaryColor(),
//       body: Padding(
//         padding: EdgeInsets.only(
//           top: UtilSize.appBarHeight(),
//           left: 20,
//           right: 20,
//         ),
//         child: Column(
//           children: [
//             _stepIndicator(steps.length),
//             const SizedBox(height: 20),
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: steps,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // =========================
//   // STEP INDICATOR
//   // =========================
//   Widget _stepIndicator(int totalSteps) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(totalSteps, (index) {
//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 6),
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: index <= _currentStep ? accentColor() : Colors.grey,
//           ),
//         );
//       }),
//     );
//   }

//   // =========================
//   // STEP 1 - BASIC INFO
//   // =========================
//   Widget _basicInfoStep() {
//     return Form(
//       key: _basicFormKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           CustomAssetImg(width: 200, height: 100),
//           CustomInput(
//             hintText: 'Nombre de la estación',
//             textEditingController: _nameController,
//             validator: (v) => v!.isEmpty ? '* Ingrese el nombre' : null,
//           ),
//           CustomInputPhone(
//             controller: _phoneController,
//             notifier: prefixNotifier,
//           ),
//           CustomButtonSelect(
//             title: 'Seleccionar tipo de punto',
//             selectNotifier: stationTypePointsNotifier,
//             optionsList: STATION_TYPE_POINTS_LIST,
//           ),
//           CustomButtonSelect(
//             title: 'Seleccionar estado',
//             selectNotifier: stationStatusNotifier,
//             optionsList: STATION_STATUS_LIST,
//           ),
//           CustomInput(
//             hintText: 'Descripción',
//             textEditingController: _descriptionController,
//             validator: (v) => v!.isEmpty ? '* Ingrese la descripción' : null,
//           ),
//           CustomButton(
//             textButton: 'Siguiente',
//             buttonColor: accentColor(),
//             textButtonColor: primaryColor(),
//             onPressed: _nextStep,
//           ),
//         ],
//       ),
//     );
//   }

//   // =========================
//   // STEP 2 - LOCATION
//   // =========================
//   Widget _locationStep() {
//     final locationService = LocationServiceImpl();

//     return Form(
//       key: _locationFormKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           CustomInput(
//             hintText: 'Dirección',
//             textEditingController: _addressController,
//             validator: (v) => v!.isEmpty ? '* Ingrese la dirección' : null,
//           ),
//           // Mapa
//           Container(
//             height: UtilSize.height(context) * 0.5,
//             decoration: BoxDecoration(
//               color: greyColorWithTransparency(),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: const Center(child: Text('Mapa aquí')),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: CustomButton(
//                   textButton: 'Atrás',
//                   onPressed: _goBack,
//                   textButtonColor: primaryColor(),
//                   buttonColor: accentColor(),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: CustomButton(
//                   textButton: 'Siguiente',
//                   onPressed: _nextStep,
//                   textButtonColor: primaryColor(),
//                   buttonColor: accentColor(),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // =========================
//   // STEP 3 - CHARGERS (EXPANDED)
//   // =========================
//   Widget _chargerStep() {
//     return Form(
//       key: _chargerFormKey,
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Agregar cargadores',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.add_circle, color: Colors.white),
//                 onPressed: _addCharger,
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: ListView.builder(
//               itemCount: chargersCount,
//               itemBuilder: (context, index) {
//                 final isExpanded = index == activeChargerIndex;

//                 return Card(
//                   color: Colors.white.withOpacity(0.08),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Column(
//                     children: [
//                       ListTile(
//                         title: Text(
//                           'Cargador ${index + 1}',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.close, color: Colors.red),
//                               onPressed: () => _removeCharger(index),
//                             ),
//                             Icon(
//                               isExpanded
//                                   ? Icons.expand_less
//                                   : Icons.expand_more,
//                               color: Colors.white,
//                             ),
//                           ],
//                         ),
//                         onTap: () {
//                           setState(() {
//                             activeChargerIndex = isExpanded ? -1 : index;
//                           });
//                         },
//                       ),
//                       AnimatedCrossFade(
//                         duration: const Duration(milliseconds: 300),
//                         crossFadeState:
//                             isExpanded
//                                 ? CrossFadeState.showFirst
//                                 : CrossFadeState.showSecond,
//                         firstChild: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: _chargerFormFields(),
//                         ),
//                         secondChild: const SizedBox.shrink(),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _chargerFormFields() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: CustomButtonSelect(
//                 title: 'Conector',
//                 selectNotifier: chargeConectorNotifier,
//                 optionsList: CONECTORS_TYPE_LIST,
//               ),
//             ),
//             Expanded(
//               child: CustomButtonSelect(
//                 title: 'Estado',
//                 selectNotifier: chargeStatusNotifier,
//                 optionsList: STATION_STATUS_LIST,
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: CustomButtonSelect(
//                 title: 'Tipo',
//                 selectNotifier: chargeTypeNotifier,
//                 optionsList: CHARGER_TYPE_LIST,
//               ),
//             ),
//             Expanded(
//               child: CustomButtonSelect(
//                 title: 'Formato',
//                 selectNotifier: chargeFormatNotifier,
//                 optionsList: CHARGER_FORMAT_LIST,
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: CustomInput(
//                 hintText: 'Carga (kW)',
//                 textEditingController: _chargekw,
//                 textInputType: TextInputType.number,
//                 validator: null,
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: CustomInput(
//                 hintText: 'Intensidad (A)',
//                 textEditingController: _amperage,
//                 textInputType: TextInputType.number,
//                 validator: null,
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: CustomInput(
//                 hintText: 'Voltaje (V)',
//                 textEditingController: _voltage,
//                 textInputType: TextInputType.number,
//                 validator: null,
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: CustomInput(
//                 hintText: 'Precio (kWh)',
//                 textEditingController: _price,
//                 textInputType: TextInputType.number,
//                 validator: null,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
