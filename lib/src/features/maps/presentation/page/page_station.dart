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
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

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
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _descriptionFocus = FocusNode();

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

  @override
  void dispose() {
    _pageController.dispose();
    prefixNotifier.dispose();
    stTypePnNotifier.dispose();
    stStatusNotifier.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _descriptionFocus.dispose();
    _addressController.dispose();
    stLatLngNotifier.dispose();
    countryNotifier.dispose();
    provinceNotifier.dispose();
    cantonNotifier.dispose();
    for (final charger in chargers) {
      for (final controller in charger.values) {
        if (controller is ChangeNotifier) controller.dispose();
      }
    }
    super.dispose();
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
    final removed = chargers.removeAt(index);
    for (final controller in removed.values) {
      if (controller is ChangeNotifier) controller.dispose();
    }
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

    if (_currentStep == 1) {
      bool isValidNotifyStep2 =
          countryNotifier.value.isNotEmpty &&
          provinceNotifier.value.isNotEmpty &&
          cantonNotifier.value.isNotEmpty;

      if (!isValidNotifyStep2) {
        showSnackbar(context, msgValidation, SnackbarStatus.waiting);
        return;
      }
    }

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

  // ───────────────── VALIDACIÓN CHARGERS ─────────────────
  bool _validateChargers() {
    if (chargers.isEmpty) {
      showSnackbar(context, msgValidation, SnackbarStatus.waiting);
      return false;
    }

    for (final c in chargers) {
      final typeConnection =
          (c["typeConnection"] as ValueNotifier<Map<String, String>?>).value;
      final status = (c["status"] as ValueNotifier<Map<String, String>?>).value;
      final format = (c["format"] as ValueNotifier<Map<String, String>?>).value;
      final typeCharger =
          (c["typeCharger"] as ValueNotifier<Map<String, String>?>).value;
      final powerKw = (c["powerKw"] as TextEditingController).text;
      final intensity = (c["intensity"] as TextEditingController).text;
      final voltage = (c["voltage"] as TextEditingController).text;
      final price = (c["priceWithTipeConnector"] as TextEditingController).text;

      final isComplete =
          typeConnection != null &&
          status != null &&
          format != null &&
          typeCharger != null &&
          powerKw.isNotEmpty &&
          intensity.isNotEmpty &&
          voltage.isNotEmpty &&
          price.isNotEmpty;

      if (!isComplete) {
        showSnackbar(context, msgValidation, SnackbarStatus.waiting);
        return false;
      }
    }

    return true;
  }

  // ───────────────── SUBMIT ─────────────────
  void _submit() async {
    if (!_validateChargers()) return;

    final stationProvider = context.read<StationProvider>();

    /// 1️⃣ BODY DE LA STATION
    final bodyStation = {
      "user": Preferences().getUser()!.id,
      "name": _nameController.text,
      "prefixCode": prefixNotifier.value,
      "phone": _phoneController.text,
      "description": _descriptionController.text,
      // "status": stStatusNotifier.value['key'],
      "status": 'PENDING',
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
      if (!mounted) return;
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
    if (!mounted) return;
    if (successCount == bodyChargers.length) {
      showPopUpWithChildren(
        context: context,
        title: '¡Estación creada!',
        subTitle:
            'La estación y todos sus cargadores han sido creados exitosamente. Una vez que sean verificados, estarán disponibles para su uso.',
        textButton: 'Aceptar',
        onSubmit: () {
          Navigator.pop(context);
        },
      );
    } else {
      showPopUpWithChildren(
        context: context,
        title: 'Estación creada con errores',
        subTitle:
            'La estación fue creada, pero algunos cargadores no pudieron ser añadidos.\nInténtalo de nuevo.',
        textButton: 'Aceptar',
        onSubmit: () {
          Navigator.pop(context); // cerrar el popup
        },
      );
    }
  }

  // ───────────────── UI ─────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: accentColor()),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildStepIndicator(),
        actions: const [SizedBox(width: 56)],
      ),

      body: Consumer<StationProvider>(
        builder: (context, stationProv, _) {
          return Stack(
            children: [
              Column(
                children: [
                  // _buildStepIndicator(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _stepBasic(),
                        _stepLocation(),
                        _stepChargers(),
                      ],
                    ),
                  ),
                  // _buildNavigationButtons(),
                ],
              ),

              /// LOADING ANIMADO
              AnimatedOpacity(
                opacity: stationProv.isLoading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child:
                    stationProv.isLoading
                        ? Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.8, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Creando estación...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildNavigationButtons(), // ✅ aquí
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
                filledColor: deepForestGreen(),
                icon: Icons.store_mall_directory_outlined,
                iconColor: accentColor(),
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onEditingComplete:
                    () => FocusScope.of(context).requestFocus(_phoneFocus),
              ),

              CustomInputPhone(
                controller: _phoneController,
                notifier: prefixNotifier,
                hintText: 'Celular',
                fillColor: deepForestGreen(),
                focusNode: _phoneFocus,
                textInputAction: TextInputAction.next,
                onSubmitted:
                    (_) =>
                        FocusScope.of(context).requestFocus(_descriptionFocus),
              ),

              CustomButtonSelect(
                title: 'Seleccionar tipo de punto',
                selectNotifier: stTypePnNotifier,
                optionsList: STATION_TYPE_POINTS_LIST,
                backgroundColor: deepForestGreen(),
                textColor: grayInputColor(),
                icon: Icons.location_on_outlined,
                iconColor: accentColor(),
              ),

              CustomButtonSelect(
                title: 'Seleccionar estado',
                selectNotifier: stStatusNotifier,
                optionsList: STATION_STATUS_LIST,
                backgroundColor: deepForestGreen(),
                textColor: grayInputColor(),
                icon: Icons.check_circle_outline,
                iconColor: accentColor(),
              ),
              CustomInput(
                hintText: 'Descripción',
                textEditingController: _descriptionController,
                maxLines: 6,
                validator:
                    (v) => v!.isEmpty ? '* Ingrese la descripción' : null,
                filledColor: deepForestGreen(),
                icon: Icons.notes,
                iconColor: accentColor(),
                focusNode: _descriptionFocus,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  _descriptionFocus.unfocus();
                  _next();
                },
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
                filledColor: deepForestGreen(),
                icon: Icons.location_on_outlined,
                iconColor: accentColor(),
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
                          filledColor: deepForestGreen(),
                          icon: Icons.outlined_flag,
                          iconColor: accentColor(),
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? '* Requerido'
                                      : null,
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
                              filledColor: deepForestGreen(),
                              icon: Icons.location_on_outlined,
                              iconColor: accentColor(),
                              validator:
                                  (v) =>
                                      (v == null || v.isEmpty)
                                          ? '* Requerido'
                                          : null,
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
                        filledColor: deepForestGreen(),
                        icon: Icons.holiday_village_outlined,
                        iconColor: accentColor(),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? '* Requerido' : null,
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
                        },
                      ),
                    ),
                  );
                },
              ),
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

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: cardDecoration(shadow: true),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 12,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: accentColor().withValues(alpha: 0.2),
                        child: Icon(
                          Icons.ev_station,
                          color: accentColor(),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Charger ${index + 1}",
                          style: TextStyle(
                            color: whiteColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: errorColor()),
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
                          backgroundColor: deepForestGreen(),
                          textColor: grayInputColor(),
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
                          backgroundColor: deepForestGreen(),
                          textColor: grayInputColor(),
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
                          backgroundColor: deepForestGreen(),
                          textColor: grayInputColor(),
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
                          backgroundColor: deepForestGreen(),
                          textColor: grayInputColor(),
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
                          textInputType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          filledColor: deepForestGreen(),
                          validator:
                              (v) => v!.isEmpty ? '* Ingrese el nombre' : null,
                        ),
                      ),

                      Flexible(
                        child: CustomInput(
                          hintText: 'Intensidad (A)',
                          textEditingController: c["intensity"],
                          textInputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          filledColor: deepForestGreen(),
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
                          textInputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          filledColor: deepForestGreen(),
                          validator:
                              (v) => v!.isEmpty ? '* Ingrese el nombre' : null,
                        ),
                      ),

                      Flexible(
                        child: CustomInput(
                          hintText: 'Precio (kWh)',
                          textEditingController: c["priceWithTipeConnector"],
                          textInputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          filledColor: deepForestGreen(),
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
        CustomButton(
          textButton: '+ Agregar charger',
          buttonColor: greyColorWithTransparency(),
          textButtonColor: accentColor(),
          onPressed: _addCharger,
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
