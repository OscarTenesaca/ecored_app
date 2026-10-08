import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
import 'package:ecored_app/src/core/services/location_service.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_connector_type.dart';
import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Se guardan para no volver a pedir las listas en cada rebuild.
  late Future<List<LocationModel>> _countriesFuture;
  Future<List<LocationModel>>? _provincesFuture;
  Future<List<LocationModel>>? _cantonsFuture;
  // Posición a la que se mueve el mapa con "Usar mi ubicación".
  LatLng? _mapFocus;

  // ───────────────── STEP 3 (CHARGERS) ─────────────────
  // Cada elemento es un punto de carga físico (ChargePoint) y contiene la
  // lista de sus conectores (Charger).
  List<List<_ConnectorDraft>> chargePoints = [];

  @override
  void initState() {
    super.initState();
    chargePoints.add([]); // un cargador (sin conectores) por defecto
    // Los tipos de conector vienen del catálogo del backend (se envía su
    // _id, no el código).
    _loadCountries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StationProvider>().findConnectorTypes();
      final gps = context.read<PermissionGpsProvider>();
      if (gps.currentPosition == null) gps.getCurrentPosition();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    prefixNotifier.dispose();
    stTypePnNotifier.dispose();
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
    super.dispose();
  }

  int get _totalConnectors =>
      chargePoints.fold(0, (sum, point) => sum + point.length);

  // El backend exige al menos un conector por cargador.
  bool get _canSaveStation =>
      chargePoints.isNotEmpty && chargePoints.every((p) => p.isNotEmpty);

  void _addChargePoint() {
    setState(() => chargePoints.add([]));
  }

  void _removeChargePoint(int pointIndex) {
    if (chargePoints.length == 1) return;
    setState(() => chargePoints.removeAt(pointIndex));
  }

  void _openConnectorSheet(int pointIndex, {int? connectorIndex}) {
    final provider = context.read<StationProvider>();
    if (provider.connectorTypes.isEmpty) provider.findConnectorTypes();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _ConnectorSheet(
            chargerName: 'Cargador ${pointIndex + 1}',
            initial:
                connectorIndex != null
                    ? chargePoints[pointIndex][connectorIndex]
                    : null,
            onSave: (draft) {
              setState(() {
                if (connectorIndex != null) {
                  chargePoints[pointIndex][connectorIndex] = draft;
                } else {
                  chargePoints[pointIndex].add(draft);
                }
              });
            },
            onDelete:
                connectorIndex == null
                    ? null
                    : () => setState(
                      () => chargePoints[pointIndex].removeAt(connectorIndex),
                    ),
          ),
    );
  }

  // ───────────────── NAVIGATION ─────────────────
  void _next() {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0 && !_basicFormKey.currentState!.validate()) return;

    if (_currentStep == 1) {
      if (!_locationFormKey.currentState!.validate()) return;
      if (_savedPin == null) {
        showSnackbar(
          context,
          'Mueve el mapa para ubicar la estación.',
          SnackbarStatus.waiting,
        );
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

  // ───────────────── SUBMIT ─────────────────
  void _submit() async {
    if (!_canSaveStation) return;

    final stationProvider = context.read<StationProvider>();

    /// 1️⃣ BODY: ESTACIÓN + PUNTOS DE CARGA, cada uno con sus conectores
    /// (el backend resuelve station y chargePointCode)
    final bodyStation = {
      "user": Preferences().getUser()!.id,
      "name": _nameController.text,
      "prefixCode": prefixNotifier.value,
      "phone": _phoneController.text,
      "description": _descriptionController.text,
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
      "chargePoints":
          chargePoints
              .map(
                (point) => {
                  "connectors": point.map((c) => c.toJson()).toList(),
                },
              )
              .toList(),
    };

    /// 2️⃣ CREAR TODO EN UNA SOLA LLAMADA (transacción: o se crea todo o nada)
    try {
      final station = await stationProvider.createStationWithChargers(
        bodyStation,
      );
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

    /// 3️⃣ RESULTADO FINAL
    if (!mounted) return;
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

  Widget _stepHeader(int step, String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PASO $step DE 3',
          style: TextStyle(
            color: accentColor(),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: whiteColor(),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: grayInputColor(),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  void _openOptionsPicker({
    required String title,
    required List<_PickerOption> options,
    required String? selectedId,
    required ValueChanged<String> onSelected,
    bool searchable = false,
  }) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _OptionsPickerSheet(
            title: title,
            options: options,
            selectedId: selectedId,
            searchable: searchable,
            onSelected: onSelected,
          ),
    );
  }

  // ───────────────── STEP 1 ─────────────────
  Widget _stepBasic() {
    return Form(
      key: _basicFormKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _stepHeader(
            1,
            'Información de la estación',
            subtitle: 'Así la verán los conductores en el mapa.',
          ),
          const SizedBox(height: 24),

          _labeled(
            'Nombre de la estación',
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: accentColor(),
              style: _inputStyle(),
              decoration: _inputDecoration(hint: 'Ej. Estación Quito Norte'),
              validator: _required('Ingresa el nombre de la estación'),
              onFieldSubmitted:
                  (_) => FocusScope.of(context).requestFocus(_phoneFocus),
            ),
          ),
          const SizedBox(height: 22),

          _labeled('Tipo de lugar', _typePointField()),
          const SizedBox(height: 22),

          _labeled(
            'Teléfono de contacto',
            CustomInputPhone(
              controller: _phoneController,
              notifier: prefixNotifier,
              hintText: 'Número de contacto',
              fillColor: _fieldFill(),
              fontSize: 16,
              focusNode: _phoneFocus,
              textInputAction: TextInputAction.next,
              onSubmitted:
                  (_) => FocusScope.of(context).requestFocus(_descriptionFocus),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Se usa en los botones Llamar y WhatsApp de la estación.',
            style: TextStyle(color: grayInputColor(), fontSize: 12),
          ),
          const SizedBox(height: 22),

          _labeled(
            'Descripción',
            TextFormField(
              controller: _descriptionController,
              focusNode: _descriptionFocus,
              minLines: 4,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: accentColor(),
              style: _inputStyle(),
              decoration: _inputDecoration(
                hint: 'Qué ofrece la estación, horarios, referencias…',
              ),
              validator: _required('Ingresa una descripción'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typePointField() {
    return FormField<String>(
      validator:
          (_) =>
              stTypePnNotifier.value['key'] == null
                  ? 'Selecciona el tipo de lugar'
                  : null,
      builder: (field) {
        final key = stTypePnNotifier.value['key'];

        return _selectField(
          leading: Icon(
            key == null ? Icons.place_outlined : stationTypePointIcon(key),
            color: accentColor(),
            size: 22,
          ),
          label:
              key == null
                  ? 'Selecciona el tipo de lugar'
                  : stationTypePointLabel(key) ?? key,
          isPlaceholder: key == null,
          errorText: field.errorText,
          onTap:
              () => _openOptionsPicker(
                title: 'Tipo de lugar',
                selectedId: key,
                options:
                    STATION_TYPE_POINTS_LIST
                        .map(
                          (t) => _PickerOption(
                            id: t['key']!,
                            label:
                                stationTypePointLabel(t['key']!) ?? t['key']!,
                            icon: stationTypePointIcon(t['key']!),
                          ),
                        )
                        .toList(),
                onSelected: (id) {
                  setState(() {
                    stTypePnNotifier.value = STATION_TYPE_POINTS_LIST
                        .firstWhere((t) => t['key'] == id);
                  });
                  field.didChange(id);
                },
              ),
        );
      },
    );
  }

  // ───────────────── STEP 2 ─────────────────
  void _loadCountries() {
    _countriesFuture = LocationServiceImpl().countries().then((countries) {
      // Ecuador preseleccionado por defecto, como antes.
      if (mounted && countryNotifier.value.isEmpty) {
        for (final country in countries) {
          if (country.name.toUpperCase() == 'ECUADOR') {
            _onCountrySelected(country.id);
            break;
          }
        }
      }
      return countries;
    });
  }

  // Al cambiar el país/provincia se limpian los niveles inferiores: un id de
  // provincia de otro país quedaría inválido.
  void _onCountrySelected(String countryId) {
    if (countryId == countryNotifier.value) return;
    setState(() {
      countryNotifier.value = countryId;
      provinceNotifier.value = '';
      cantonNotifier.value = '';
      _provincesFuture = LocationServiceImpl().provinces({
        'country': countryId,
      });
      _cantonsFuture = null;
    });
  }

  void _onProvinceSelected(String provinceId) {
    if (provinceId == provinceNotifier.value) return;
    setState(() {
      provinceNotifier.value = provinceId;
      cantonNotifier.value = '';
      _cantonsFuture = LocationServiceImpl().cantons({'province': provinceId});
    });
  }

  void _setPin(LatLng latLng) {
    stLatLngNotifier.value = {
      'lat': latLng.latitude.toString(),
      'lng': latLng.longitude.toString(),
    };
  }

  LatLng? get _savedPin {
    final lat = double.tryParse(stLatLngNotifier.value['lat'] ?? '');
    final lng = double.tryParse(stLatLngNotifier.value['lng'] ?? '');
    return (lat == null || lng == null) ? null : LatLng(lat, lng);
  }

  Future<void> _centerOnMyLocation(PermissionGpsProvider gps) async {
    final position = await gps.getCurrentPosition();
    if (!mounted) return;
    if (position == null) {
      showSnackbar(
        context,
        'No pudimos obtener tu ubicación. Revisa que el GPS y los permisos '
        'estén activos.',
        SnackbarStatus.waiting,
      );
      return;
    }
    final latLng = LatLng(position.latitude, position.longitude);
    setState(() => _mapFocus = latLng);
    _setPin(latLng);
  }

  Widget _stepLocation() {
    return Form(
      key: _locationFormKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _stepHeader(2, 'Ubicación'),
          const SizedBox(height: 20),

          _mapCard(),
          const SizedBox(height: 12),
          ValueListenableBuilder<Map<String, String>>(
            valueListenable: stLatLngNotifier,
            builder: (_, __, ___) {
              final pin = _savedPin;
              return Row(
                children: [
                  Text(
                    'Coordenadas del pin',
                    style: TextStyle(color: grayInputColor(), fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    pin == null
                        ? '—'
                        : '${pin.latitude.toStringAsFixed(5)}, '
                            '${pin.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                      color: whiteColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),

          _labeled(
            'Dirección',
            TextFormField(
              controller: _addressController,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: accentColor(),
              style: _inputStyle(),
              decoration: _inputDecoration(
                hint: 'Calle principal y secundaria',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: accentColor(),
                ),
              ),
              validator: _required('Ingresa la dirección'),
            ),
          ),
          const SizedBox(height: 22),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeled(
                  'País',
                  _locationField(
                    future: _countriesFuture,
                    notifier: countryNotifier,
                    title: 'País',
                    placeholder: 'País',
                    showFlag: true,
                    onSelected: _onCountrySelected,
                    onRetry: () => setState(_loadCountries),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeled(
                  'Provincia',
                  _locationField(
                    future: _provincesFuture,
                    notifier: provinceNotifier,
                    title: 'Provincia',
                    placeholder: 'Provincia',
                    onSelected: _onProvinceSelected,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          _labeled(
            'Ciudad',
            _locationField(
              future: _cantonsFuture,
              notifier: cantonNotifier,
              title: 'Ciudad',
              placeholder:
                  provinceNotifier.value.isEmpty
                      ? 'Elige primero la provincia'
                      : 'Ciudad',
              onSelected: (id) => setState(() => cantonNotifier.value = id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapCard() {
    return Consumer<PermissionGpsProvider>(
      builder: (context, gps, _) {
        final position = gps.currentPosition;
        // Si ya hay un pin elegido (p. ej. al volver de otro paso) se respeta;
        // si no, se arranca en la ubicación del usuario.
        final initial =
            _savedPin ??
            (position != null
                ? LatLng(position.latitude, position.longitude)
                : null);
        final waitingGps =
            initial == null &&
            (gps.isLoading || (gps.isAllGranted && position == null));

        return Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              children: [
                if (waitingGps)
                  Center(child: CircularProgressIndicator(color: accentColor()))
                else
                  CustomMapPin(
                    initialPosition: initial,
                    focusPosition: _mapFocus,
                    pinColor: accentColor(),
                    onLocationSelected: _setPin,
                  ),

                Positioned(
                  top: 12,
                  left: 12,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor().withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Mueve el mapa para ajustar el pin',
                        style: TextStyle(
                          color: whiteColor(),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                if (!waitingGps)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Material(
                      color: primaryColor().withValues(alpha: 0.92),
                      shape: const StadiumBorder(),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: () => _centerOnMyLocation(gps),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.my_location,
                                color: accentColor(),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Usar mi ubicación',
                                style: TextStyle(
                                  color: whiteColor(),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _locationField({
    required Future<List<LocationModel>>? future,
    required ValueNotifier<String> notifier,
    required String title,
    required String placeholder,
    required ValueChanged<String> onSelected,
    bool showFlag = false,
    VoidCallback? onRetry,
  }) {
    return FutureBuilder<List<LocationModel>>(
      future: future,
      builder: (context, snapshot) {
        final locations = snapshot.data ?? const <LocationModel>[];
        final isLoading =
            future != null &&
            snapshot.connectionState == ConnectionState.waiting;

        return FormField<String>(
          validator: (_) => notifier.value.isEmpty ? 'Requerido' : null,
          builder: (field) {
            LocationModel? selected;
            for (final location in locations) {
              if (location.id == notifier.value) {
                selected = location;
                break;
              }
            }

            String label = placeholder;
            if (isLoading) {
              label = 'Cargando…';
            } else if (snapshot.hasError) {
              label = 'Toca para reintentar';
            } else if (selected != null) {
              label = _titleCase(selected.name);
            }

            VoidCallback? onTap;
            if (snapshot.hasError) {
              onTap = onRetry;
            } else if (locations.isNotEmpty) {
              onTap =
                  () => _openOptionsPicker(
                    title: title,
                    searchable: locations.length > 8,
                    selectedId: notifier.value.isEmpty ? null : notifier.value,
                    options:
                        locations
                            .map(
                              (l) => _PickerOption(
                                id: l.id,
                                label: _titleCase(l.name),
                                leadingText: showFlag ? l.flag : null,
                              ),
                            )
                            .toList(),
                    onSelected: (id) {
                      onSelected(id);
                      field.didChange(id);
                    },
                  );
            }

            final flag = selected?.flag ?? '';
            return _selectField(
              leading:
                  showFlag && flag.isNotEmpty
                      ? Text(flag, style: const TextStyle(fontSize: 20))
                      : null,
              label: label,
              isPlaceholder: selected == null,
              errorText: field.errorText,
              onTap: onTap,
            );
          },
        );
      },
    );
  }

  // ───────────────── STEP 3 ─────────────────
  Widget _stepChargers() {
    final hasConnectors = _totalConnectors > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        _stepHeader(
          3,
          'Cargadores y conectores',
          subtitle:
              hasConnectors
                  ? 'Toca un conector para editarlo.'
                  : 'El cargador es el equipo. Cada cargador puede tener uno '
                      'o varios conectores.',
        ),
        const SizedBox(height: 24),

        ...chargePoints.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _chargePointCard(entry.key, entry.value),
          ),
        ),

        _DashedBox(
          color: Colors.white.withValues(alpha: 0.18),
          radius: 22,
          height: 64,
          onTap: _addChargePoint,
          child: _addLabel('Agregar cargador', whiteColor()),
        ),
      ],
    );
  }

  Widget _chargePointCard(int pointIndex, List<_ConnectorDraft> connectors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: deepForestGreen(),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _squareBox(
                size: 48,
                child: Icon(Icons.bolt_outlined, color: accentColor()),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cargador ${pointIndex + 1}',
                      style: TextStyle(
                        color: whiteColor(),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      connectors.isEmpty
                          ? 'Sin conectores'
                          : _plural(
                            connectors.length,
                            'conector',
                            'conectores',
                          ),
                      style: TextStyle(color: grayInputColor(), fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: grayInputColor()),
                color: deepForestGreen(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'add') _openConnectorSheet(pointIndex);
                  if (value == 'delete') _removeChargePoint(pointIndex);
                },
                itemBuilder:
                    (_) => [
                      PopupMenuItem(
                        value: 'add',
                        child: Text(
                          'Agregar conector',
                          style: TextStyle(color: whiteColor()),
                        ),
                      ),
                      if (chargePoints.length > 1)
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Eliminar cargador',
                            style: TextStyle(color: errorColor()),
                          ),
                        ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (connectors.isEmpty)
            _DashedBox(
              color: Colors.white.withValues(alpha: 0.15),
              radius: 18,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Column(
                children: [
                  Image.asset(
                    AssetPaths.iconTypeC,
                    width: 36,
                    height: 36,
                    color: grayInputColor(),
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Aún no hay conectores',
                    style: TextStyle(
                      color: whiteColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Agrega el primero para este cargador.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: grayInputColor(), fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  _PillButton(
                    label: 'Agregar conector',
                    icon: Icons.add,
                    onTap: () => _openConnectorSheet(pointIndex),
                  ),
                ],
              ),
            )
          else ...[
            ...connectors.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _connectorRow(pointIndex, entry.key, entry.value),
              ),
            ),
            _DashedBox(
              color: accentColor().withValues(alpha: 0.6),
              radius: 16,
              height: 56,
              onTap: () => _openConnectorSheet(pointIndex),
              child: _addLabel('Agregar conector', accentColor()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _connectorRow(
    int pointIndex,
    int connectorIndex,
    _ConnectorDraft connector,
  ) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap:
              () => _openConnectorSheet(
                pointIndex,
                connectorIndex: connectorIndex,
              ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _squareBox(
                  size: 52,
                  child: _ConnectorTypeIcon(
                    icon: connector.connectorType.icon,
                    color: accentColor(),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              connector.connectorType.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: whiteColor(),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (connector.displayLabel.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _labelBadge(connector.displayLabel),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${connector.typeCharger} · '
                        '${_formatNumber(connector.powerKw)} kW · '
                        '${_formatNumber(connector.voltage)} V · '
                        '${_formatNumber(connector.intensity)} A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: grayInputColor(), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatMoney(connector.price),
                      style: TextStyle(
                        color: accentColor(),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/ kWh',
                      style: TextStyle(color: grayInputColor(), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepChargersBottomBar() {
    final canSave = _canSaveStation;
    final total = _totalConnectors;

    final String status;
    if (canSave) {
      status =
          '${_plural(chargePoints.length, 'cargador', 'cargadores')} · '
          '${_plural(total, 'conector', 'conectores')} '
          '${total == 1 ? 'listo' : 'listos'}';
    } else if (total == 0) {
      status = 'Agrega al menos un conector para guardar.';
    } else {
      status = 'Cada cargador necesita al menos un conector.';
    }

    return _bottomBar(
      status: Row(
        children: [
          Icon(
            canSave ? Icons.check : Icons.info_outline,
            size: 18,
            color: canSave ? accentColor() : grayInputColor(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status,
              style: TextStyle(color: grayInputColor(), fontSize: 13),
            ),
          ),
        ],
      ),
      actions: Row(
        children: [
          Expanded(
            flex: 2,
            child: _PillButton(label: 'Atrás', filled: false, onTap: _back),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: _PillButton(
              label: 'Guardar estación',
              onTap: canSave ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addLabel(String label, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _labelBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: whiteColor(),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ───────────────── NAV BUTTONS ─────────────────
  Widget _bottomBar({Widget? status, required Widget actions}) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + UtilSize.bottomPadding()),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status != null) ...[status, const SizedBox(height: 14)],
          actions,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (_currentStep == 2) return _stepChargersBottomBar();

    return _bottomBar(
      actions: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              flex: 2,
              child: _PillButton(label: 'Atrás', filled: false, onTap: _back),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 5,
            child: _PillButton(label: 'Siguiente', onTap: _next),
          ),
        ],
      ),
    );
  }
}

// ───────────────── STEP 3: helpers ─────────────────

double? _parseNumber(String value) =>
    double.tryParse(value.trim().replaceAll(',', '.'));

// 22.0 → "22", 7.5 → "7.5"
String _formatNumber(double value) =>
    value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();

// 2 → "$2.00", 0.2856 → "$0.2856" (no redondea lo que ingresó el usuario)
String _formatMoney(double value) {
  final fixed = value.toStringAsFixed(4).replaceFirst(RegExp(r'0{1,2}$'), '');
  return '\$$fixed';
}

String _plural(int count, String singular, String plural) =>
    '$count ${count == 1 ? singular : plural}';

Widget _squareBox({required Widget child, double size = 48}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    ),
    child: Center(child: child),
  );
}

/// Conector ya completado en el formulario, pendiente de enviarse junto con
/// la estación.
class _ConnectorDraft {
  final ModelConnectorType connectorType;
  final String typeCharger;
  final double voltage;
  final double intensity;
  final double powerKw;
  final double price;
  final String displayLabel;
  final String status;

  const _ConnectorDraft({
    required this.connectorType,
    required this.typeCharger,
    required this.voltage,
    required this.intensity,
    required this.powerKw,
    required this.price,
    required this.displayLabel,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    "connectorType": connectorType.id,
    "status": status,
    "typeCharger": typeCharger,
    "powerKw": powerKw,
    "intensity": intensity,
    "voltage": voltage,
    "priceWithTipeConnector": price,
    // Vacío: el backend lo autocompleta (A, B, C...).
    if (displayLabel.isNotEmpty) "displayLabel": displayLabel,
  };
}

// ───────────────── STEP 3: hoja "Nuevo / Editar conector" ─────────────────

class _ConnectorSheet extends StatefulWidget {
  final String chargerName;
  final _ConnectorDraft? initial;
  final ValueChanged<_ConnectorDraft> onSave;
  final VoidCallback? onDelete;

  const _ConnectorSheet({
    required this.chargerName,
    required this.onSave,
    this.initial,
    this.onDelete,
  });

  @override
  State<_ConnectorSheet> createState() => _ConnectorSheetState();
}

class _ConnectorSheetState extends State<_ConnectorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _voltageController = TextEditingController();
  final _intensityController = TextEditingController();
  final _powerController = TextEditingController();
  final _priceController = TextEditingController();
  final _labelController = TextEditingController();

  ModelConnectorType? _connectorType;
  String _typeCharger = CHARGER_TYPE_LIST.first['key']!;
  String _status = STATION_STATUS_LIST.first['key']!;
  bool _showTypeError = false;
  int _addedCount = 0;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _connectorType = initial.connectorType;
      _typeCharger = initial.typeCharger;
      _status = initial.status;
      _voltageController.text = _formatNumber(initial.voltage);
      _intensityController.text = _formatNumber(initial.intensity);
      _powerController.text = _formatNumber(initial.powerKw);
      _priceController.text = _formatMoney(initial.price).substring(1);
      _labelController.text = initial.displayLabel;
    }
  }

  @override
  void dispose() {
    _voltageController.dispose();
    _intensityController.dispose();
    _powerController.dispose();
    _priceController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  _ConnectorDraft? _buildDraft() {
    final isFormValid = _formKey.currentState!.validate();
    setState(() => _showTypeError = _connectorType == null);
    if (!isFormValid || _connectorType == null) return null;

    return _ConnectorDraft(
      connectorType: _connectorType!,
      typeCharger: _typeCharger,
      voltage: _parseNumber(_voltageController.text)!,
      intensity: _parseNumber(_intensityController.text)!,
      powerKw: _parseNumber(_powerController.text)!,
      price: _parseNumber(_priceController.text)!,
      displayLabel: _labelController.text.trim(),
      status: _status,
    );
  }

  void _save({bool addAnother = false}) {
    final draft = _buildDraft();
    if (draft == null) return;

    widget.onSave(draft);

    if (!addAnother) {
      Navigator.pop(context);
      return;
    }

    // Se limpia para el siguiente conector; tipo de carga y estado se
    // mantienen porque suelen repetirse dentro del mismo cargador.
    _voltageController.clear();
    _intensityController.clear();
    _powerController.clear();
    _priceController.clear();
    _labelController.clear();
    _formKey.currentState!.reset();
    setState(() {
      _connectorType = null;
      _addedCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final connectorTypes = context.watch<StationProvider>().connectorTypes;

    final subtitle =
        _addedCount == 0
            ? 'En ${widget.chargerName}'
            : 'En ${widget.chargerName} · '
                '${_plural(_addedCount, 'agregado', 'agregados')}';

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      decoration: BoxDecoration(
        color: primaryColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Material propio: sin él, el fondo del Container de arriba tapa
      // los fondos/efectos de toque que ListTile e InkWell pintan sobre el
      // Material del bottom sheet (que es transparente).
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditing
                                        ? 'Editar conector'
                                        : 'Nuevo conector',
                                    style: TextStyle(
                                      color: whiteColor(),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      color: grayInputColor(),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => Navigator.pop(context),
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(Icons.close, color: whiteColor()),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _fieldLabel('Tipo de conector'),
                        _connectorTypeSelector(connectorTypes),
                        if (_showTypeError) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Selecciona un tipo de conector',
                            style: TextStyle(color: errorColor(), fontSize: 11),
                          ),
                        ],

                        const SizedBox(height: 22),
                        _fieldLabel('Tipo de carga'),
                        _chargeTypeSelector(),

                        const SizedBox(height: 22),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _labeled(
                                'Voltaje',
                                _numberField(_voltageController, suffix: 'V'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _labeled(
                                'Intensidad',
                                _numberField(_intensityController, suffix: 'A'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _labeled(
                                'Potencia',
                                _numberField(_powerController, suffix: 'kW'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),
                        _labeled(
                          'Precio por kWh',
                          _numberField(
                            _priceController,
                            prefix: '\$',
                            suffix: '/ kWh',
                            allowZero: true,
                          ),
                        ),

                        const SizedBox(height: 22),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _labeled(
                                'Etiqueta (opcional)',
                                TextFormField(
                                  controller: _labelController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  cursorColor: accentColor(),
                                  style: _inputStyle(),
                                  decoration: _inputDecoration(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _labeled('Estado', _statusSelector()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _PillButton(
                        label:
                            _isEditing ? 'Guardar cambios' : 'Guardar conector',
                        height: 56,
                        onTap: _save,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_isEditing)
                      TextButton(
                        onPressed: () {
                          widget.onDelete?.call();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Eliminar conector',
                          style: TextStyle(
                            color: errorColor(),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: () => _save(addAnother: true),
                        child: Text(
                          'Guardar y agregar otro',
                          style: TextStyle(
                            color: accentColor(),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _connectorTypeSelector(List<ModelConnectorType> types) {
    if (types.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentColor(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cargando tipos de conector…',
                style: TextStyle(color: grayInputColor(), fontSize: 13),
              ),
            ),
            TextButton(
              onPressed:
                  () => context.read<StationProvider>().findConnectorTypes(),
              child: Text('Reintentar', style: TextStyle(color: accentColor())),
            ),
          ],
        ),
      );
    }

    const columns = 4;
    const spacing = 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              types.map((type) {
                final selected = _connectorType?.id == type.id;

                return GestureDetector(
                  onTap:
                      () => setState(() {
                        _connectorType = type;
                        _showTypeError = false;
                      }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: itemWidth,
                    height: 96,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? accentColor().withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            selected
                                ? accentColor()
                                : Colors.white.withValues(alpha: 0.08),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ConnectorTypeIcon(
                          icon: type.icon,
                          color: selected ? accentColor() : grayInputColor(),
                          size: 30,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          type.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? whiteColor() : Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _chargeTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children:
            CHARGER_TYPE_LIST.map((item) {
              final key = item['key']!;
              final selected = _typeCharger == key;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _typeCharger = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? accentColor() : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      key,
                      style: TextStyle(
                        color: selected ? primaryColor() : Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _statusSelector() {
    final label =
        STATION_STATUS_LIST.firstWhere(
          (s) => s['key'] == _status,
          orElse: () => STATION_STATUS_LIST.first,
        )['label']!;

    return PopupMenuButton<String>(
      color: deepForestGreen(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (value) => setState(() => _status = value),
      itemBuilder:
          (_) =>
              STATION_STATUS_LIST
                  .map(
                    (s) => PopupMenuItem(
                      value: s['key'],
                      child: Text(
                        s['label']!,
                        style: TextStyle(color: whiteColor()),
                      ),
                    ),
                  )
                  .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _inputStyle(),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: accentColor()),
          ],
        ),
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller, {
    String? prefix,
    String? suffix,
    bool allowZero = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      cursorColor: accentColor(),
      style: _inputStyle(),
      decoration: _inputDecoration(prefix: prefix, suffix: suffix),
      validator: (value) {
        final number = _parseNumber(value ?? '');
        if (number == null) return 'Requerido';
        if (allowZero ? number < 0 : number <= 0) return 'Inválido';
        return null;
      },
    );
  }
}

// ───────────────── STEP 3: piezas visuales ─────────────────

/// Icono del catálogo de tipos de conector, teñido con [color] (los PNG son
/// silueta con fondo transparente).
class _ConnectorTypeIcon extends StatelessWidget {
  final String icon;
  final Color color;
  final double size;

  const _ConnectorTypeIcon({
    required this.icon,
    required this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      AssetPaths.iconTypeC,
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
    if (icon.isEmpty) return fallback;

    // El catálogo arma la URL con HOST_API del servidor; se toma solo el
    // nombre del archivo y se usa Environment.url, la misma base del resto
    // de llamadas de la app.
    final fileName = Uri.tryParse(icon)?.pathSegments.lastOrNull ?? icon;

    return Image.network(
      '${Environment.url}/api/v1/connector-types/icon/$fileName',
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      headers: {
        'Authorization': 'Bearer ${Preferences().getUser()?.token ?? ''}',
      },
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final IconData? icon;
  final double height;

  const _PillButton({
    required this.label,
    required this.onTap,
    this.filled = true,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final background =
        filled
            ? (enabled ? accentColor() : Colors.white.withValues(alpha: 0.08))
            : Colors.transparent;
    final foreground =
        filled ? (enabled ? primaryColor() : grayInputColor()) : whiteColor();

    return Material(
      color: background,
      shape: StadiumBorder(
        side:
            filled
                ? BorderSide.none
                : BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: foreground, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Contenedor con borde punteado (para los botones "Agregar" y el estado
/// vacío de un cargador).
class _DashedBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double? height;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const _DashedBox({
    required this.child,
    required this.color,
    this.radius = 16,
    this.height,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          painter: _DashedRRectPainter(color: color, radius: radius),
          child: Container(
            height: height,
            padding: padding,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRRectPainter({required this.color, required this.radius});

  static const double _dash = 6;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

    final path =
        ui.Path()..addRRect(
          RRect.fromRectAndRadius(
            (Offset.zero & size).deflate(0.6),
            Radius.circular(radius),
          ),
        );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = math.min(distance + _dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

// ───────────────── Campos compartidos (pasos 1, 2 y hoja de conector) ─────

Color _fieldFill() => Colors.white.withValues(alpha: 0.04);

Color _fieldBorder() => Colors.white.withValues(alpha: 0.08);

String? Function(String?) _required(String message) =>
    (value) => (value == null || value.trim().isEmpty) ? message : null;

// "CUENCA" → "Cuenca", "SANTO DOMINGO" → "Santo Domingo"
String _titleCase(String value) => value
    .toLowerCase()
    .split(' ')
    .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
    .join(' ');

Widget _fieldLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.85),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _labeled(String label, Widget field) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [_fieldLabel(label), field],
  );
}

TextStyle _inputStyle() =>
    TextStyle(color: whiteColor(), fontSize: 16, fontWeight: FontWeight.w600);

InputDecoration _inputDecoration({
  String? hint,
  String? prefix,
  String? suffix,
  Widget? prefixIcon,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget? prefixWidget;
  if (prefixIcon != null) {
    prefixWidget = Padding(
      padding: const EdgeInsets.only(left: 14, right: 10),
      child: prefixIcon,
    );
  } else if (prefix != null) {
    prefixWidget = Padding(
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Text(
        prefix,
        style: TextStyle(
          color: accentColor(),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: _fieldFill(),
    hintText: hint,
    hintStyle: TextStyle(
      color: grayInputColor(),
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    errorStyle: const TextStyle(fontSize: 11),
    errorMaxLines: 2,
    prefixIcon: prefixWidget,
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    suffixIcon:
        suffix == null
            ? null
            : Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Text(
                suffix,
                style: TextStyle(color: grayInputColor(), fontSize: 14),
              ),
            ),
    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    enabledBorder: border(_fieldBorder()),
    focusedBorder: border(accentColor(), 1.5),
    errorBorder: border(errorColor()),
    focusedErrorBorder: border(errorColor(), 1.5),
  );
}

/// Campo de selección con el mismo aspecto que los TextFormField de arriba.
/// Si [onTap] es null el campo queda deshabilitado (chevron gris).
Widget _selectField({
  required String label,
  Widget? leading,
  bool isPlaceholder = false,
  String? errorText,
  VoidCallback? onTap,
}) {
  final hasError = errorText != null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            decoration: BoxDecoration(
              color: _fieldFill(),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError ? errorColor() : _fieldBorder(),
              ),
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading, const SizedBox(width: 12)],
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        isPlaceholder
                            ? TextStyle(color: grayInputColor(), fontSize: 15)
                            : _inputStyle(),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: onTap == null ? grayInputColor() : accentColor(),
                ),
              ],
            ),
          ),
        ),
      ),
      if (hasError)
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 6),
          child: Text(
            errorText,
            style: TextStyle(color: errorColor(), fontSize: 11),
          ),
        ),
    ],
  );
}

class _PickerOption {
  final String id;
  final String label;
  final IconData? icon;
  final String? leadingText;

  const _PickerOption({
    required this.id,
    required this.label,
    this.icon,
    this.leadingText,
  });
}

/// Hoja inferior para elegir una opción (tipo de lugar, país, provincia,
/// ciudad), con buscador opcional para listas largas.
class _OptionsPickerSheet extends StatefulWidget {
  final String title;
  final List<_PickerOption> options;
  final String? selectedId;
  final bool searchable;
  final ValueChanged<String> onSelected;

  const _OptionsPickerSheet({
    required this.title,
    required this.options,
    required this.selectedId,
    required this.searchable,
    required this.onSelected,
  });

  @override
  State<_OptionsPickerSheet> createState() => _OptionsPickerSheetState();
}

class _OptionsPickerSheetState extends State<_OptionsPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final query = _query.trim().toLowerCase();
    final visible =
        query.isEmpty
            ? widget.options
            : widget.options
                .where((o) => o.label.toLowerCase().contains(query))
                .toList();

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.8),
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      decoration: BoxDecoration(
        color: primaryColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Material propio: sin él, el fondo del Container de arriba tapa
      // los fondos/efectos de toque que ListTile e InkWell pintan sobre el
      // Material del bottom sheet (que es transparente).
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: whiteColor(),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.searchable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    cursorColor: accentColor(),
                    style: _inputStyle(),
                    decoration: _inputDecoration(
                      hint: 'Buscar',
                      prefixIcon: Icon(Icons.search, color: grayInputColor()),
                    ),
                  ),
                ),
              Flexible(
                child:
                    visible.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No se encontraron resultados',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: grayInputColor()),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          itemCount: visible.length,
                          itemBuilder: (_, index) {
                            final option = visible[index];
                            final selected = option.id == widget.selectedId;
                            final leadingText = option.leadingText ?? '';

                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              tileColor:
                                  selected
                                      ? accentColor().withValues(alpha: 0.1)
                                      : null,
                              leading:
                                  option.icon != null
                                      ? Icon(option.icon, color: accentColor())
                                      : leadingText.isNotEmpty
                                      ? Text(
                                        leadingText,
                                        style: const TextStyle(fontSize: 22),
                                      )
                                      : null,
                              title: Text(
                                option.label,
                                style: TextStyle(
                                  color: whiteColor(),
                                  fontSize: 15,
                                  fontWeight:
                                      selected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                ),
                              ),
                              trailing:
                                  selected
                                      ? Icon(Icons.check, color: accentColor())
                                      : null,
                              onTap: () {
                                widget.onSelected(option.id);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
