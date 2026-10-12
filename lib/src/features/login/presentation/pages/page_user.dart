import 'dart:convert';

import 'package:ecored_app/src/core/adapter/adapter_load_img.dart';
import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/services/location_service.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/login/data/models/model_user.dart';
import 'package:ecored_app/src/features/login/presentation/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PageUser extends StatefulWidget {
  const PageUser({super.key});

  @override
  State<PageUser> createState() => _PageUserState();
}

class _PageUserState extends State<PageUser> {
  final _formKey = GlobalKey<FormState>();

  String img = '';
  final _ciController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final ValueNotifier<String> prefixNotifier = ValueNotifier<String>('+593');
  final ValueNotifier<String> countryNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> provinceNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> birthdayNotifier = ValueNotifier<String>('');

  // Se refresca tras guardar: si quedara la copia inicial, guardar dos veces
  // lo mismo detectaría "cambios" que ya se enviaron.
  ModelUser? _user = Preferences().getUser();
  final LocationServiceImpl locationService = LocationServiceImpl();

  late Future<List<LocationModel>> _countriesFuture;
  // Evita relanzar la petición de provincias en cada rebuild: solo se vuelve
  // a pedir cuando el país realmente cambia.
  String? _provincesCountry;
  Future<List<LocationModel>>? _provincesFuture;

  @override
  void initState() {
    super.initState();
    img = _user?.img ?? '';
    _ciController.text = _user?.ci ?? '';
    _nameController.text = _user?.name ?? '';
    _emailController.text = _user?.email ?? '';
    _phoneController.text = _user?.phone ?? '';
    final dateOnly = '${_user?.birthdate}'.split(' ').first;
    birthdayNotifier.value = dateOnly != 'null' ? dateOnly : '';
    countryNotifier.value = _user?.country?.id ?? '';
    provinceNotifier.value = _user?.province?.id ?? '';
    _loadCountries();
  }

  @override
  void dispose() {
    _ciController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    prefixNotifier.dispose();
    countryNotifier.dispose();
    provinceNotifier.dispose();
    birthdayNotifier.dispose();
    super.dispose();
  }

  void _loadCountries() {
    _countriesFuture = locationService.countries().then((countries) {
      // Ecuador por defecto si el usuario aún no tiene país.
      if (mounted && countryNotifier.value.isEmpty) {
        for (final country in countries) {
          if (country.name.toUpperCase() == 'ECUADOR') {
            setState(() => countryNotifier.value = country.id);
            break;
          }
        }
      }
      return countries;
    });
  }

  Future<List<LocationModel>>? _provincesFor(String country) {
    if (country.isEmpty) return null;
    if (_provincesCountry != country) {
      _provincesCountry = country;
      _provincesFuture = locationService.provinces({'country': country});
    }
    return _provincesFuture;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LoginProvider>().isLoading;

    return Scaffold(
      backgroundColor: primaryColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: accentColor(), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Editar perfil',
          style: TextStyle(
            color: whiteColor(),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Center(child: _ProfileAvatar(img: img, onTap: _onChangeImg)),
                const SizedBox(height: 24),

                LabeledField(
                  label: 'Nombre completo',
                  child: TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    cursorColor: accentColor(),
                    style: formInputStyle(),
                    decoration: formInputDecoration(hint: 'Tu nombre'),
                    validator:
                        (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Ingresa tu nombre'
                                : null,
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabeledField(
                        label: 'Cédula',
                        child: _readOnlyField(_ciController),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LabeledField(
                        label: 'Fecha de nacimiento',
                        child: _birthdateField(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                LabeledField(
                  label: 'Correo electrónico',
                  child: _readOnlyField(_emailController),
                ),
                const SizedBox(height: 18),

                // El teléfono no se edita desde aquí (no se envía al guardar).
                // Va en su propio Form para que su validador no bloquee
                // "Guardar cambios" con un número que el usuario no puede
                // corregir en esta pantalla.
                LabeledField(
                  label: 'Teléfono',
                  child: Form(
                    child: IgnorePointer(
                      child: CustomInputPhone(
                        controller: _phoneController,
                        notifier: prefixNotifier,
                        fillColor: formFieldFill(),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabeledField(
                        label: 'País',
                        child: _countryField(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LabeledField(
                        label: 'Provincia',
                        child: _provinceField(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // El formulario sigue montado mientras carga: antes se reemplazaba
          // por un spinner y se perdían los cambios sin guardar (p. ej. al
          // subir la foto después de editar el nombre).
          if (isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: CircularProgressIndicator(color: accentColor()),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          14 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: SizedBox(
          height: 56,
          child: Material(
            color: isLoading ? Colors.white12 : accentColor(),
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: isLoading ? null : _save,
              child: Center(
                child: Text(
                  'Guardar cambios',
                  style: TextStyle(
                    color: isLoading ? grayInputColor() : primaryColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _readOnlyField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: formInputStyle(muted: true),
      decoration: formInputDecoration(),
    );
  }

  Widget _birthdateField() {
    return ValueListenableBuilder<String>(
      valueListenable: birthdayNotifier,
      builder: (context, value, _) {
        final date = DateTime.tryParse(value);
        return FormSelectField(
          label:
              date == null
                  ? 'Seleccionar'
                  : '${date.day.toString().padLeft(2, '0')}/'
                      '${date.month.toString().padLeft(2, '0')}/'
                      '${date.year}',
          isPlaceholder: date == null,
          trailingIcon: Icons.calendar_today_outlined,
          onTap: () {
            FocusScope.of(context).unfocus();
            showDatePickerModal(context: context, notifier: birthdayNotifier);
          },
        );
      },
    );
  }

  Widget _countryField() {
    return FutureBuilder<List<LocationModel>>(
      future: _countriesFuture,
      builder: (context, snapshot) {
        final countries = snapshot.data ?? const <LocationModel>[];
        final selected = _findById(countries, countryNotifier.value);

        return FormSelectField(
          label:
              snapshot.connectionState == ConnectionState.waiting
                  ? 'Cargando…'
                  : snapshot.hasError
                  ? 'Toca para reintentar'
                  : selected != null
                  ? _titleCase(selected.name)
                  : 'País',
          leading:
              (selected?.flag ?? '').isNotEmpty
                  ? Text(selected!.flag, style: const TextStyle(fontSize: 20))
                  : null,
          isPlaceholder: selected == null,
          onTap:
              snapshot.hasError
                  ? () => setState(_loadCountries)
                  : countries.isEmpty
                  ? null
                  : () => showFormOptionsPicker(
                    context: context,
                    title: 'País',
                    searchable: countries.length > 8,
                    selectedId: countryNotifier.value,
                    options:
                        countries
                            .map(
                              (c) => FormPickerOption(
                                id: c.id,
                                label: _titleCase(c.name),
                                leadingText: c.flag,
                              ),
                            )
                            .toList(),
                    onSelected: (id) {
                      if (id == countryNotifier.value) return;
                      // La provincia anterior pertenece a otro país.
                      setState(() {
                        countryNotifier.value = id;
                        provinceNotifier.value = '';
                      });
                    },
                  ),
        );
      },
    );
  }

  Widget _provinceField() {
    final future = _provincesFor(countryNotifier.value);

    return FutureBuilder<List<LocationModel>>(
      future: future,
      builder: (context, snapshot) {
        final provinces = snapshot.data ?? const <LocationModel>[];
        final isLoadingList =
            future != null &&
            snapshot.connectionState == ConnectionState.waiting;

        return FormField<String>(
          validator:
              (_) =>
                  provinceNotifier.value.isEmpty
                      ? 'Selecciona tu provincia'
                      : null,
          builder: (field) {
            final selected = _findById(provinces, provinceNotifier.value);
            // Mientras cargan las provincias se muestra la que ya tenía el
            // usuario, para que el campo no parpadee vacío.
            final fallbackName =
                provinceNotifier.value == _user?.province?.id
                    ? _user?.province?.name
                    : null;
            final name = selected?.name ?? fallbackName;

            return FormSelectField(
              label:
                  name != null
                      ? _titleCase(name)
                      : isLoadingList
                      ? 'Cargando…'
                      : 'Provincia',
              isPlaceholder: name == null,
              errorText: field.errorText,
              onTap:
                  provinces.isEmpty
                      ? null
                      : () => showFormOptionsPicker(
                        context: context,
                        title: 'Provincia',
                        searchable: provinces.length > 8,
                        selectedId: provinceNotifier.value,
                        options:
                            provinces
                                .map(
                                  (p) => FormPickerOption(
                                    id: p.id,
                                    label: _titleCase(p.name),
                                  ),
                                )
                                .toList(),
                        onSelected: (id) {
                          setState(() => provinceNotifier.value = id);
                          field.didChange(id);
                        },
                      ),
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final user = _user;
    if (user == null) return;

    final updates = <String, dynamic>{
      'img': img,
      'name': _nameController.text.trim(),
      'country': countryNotifier.value,
      'province': provinceNotifier.value,
      // Sin fecha elegida no se envía (antes DateTime.parse('') rompía).
      if (birthdayNotifier.value.isNotEmpty)
        'birthdate': DateTime.parse(birthdayNotifier.value).toIso8601String(),
    };

    final birthdateBefore = '${user.birthdate}'.split(' ').first;
    final birthdateAfter =
        birthdayNotifier.value.isEmpty
            ? birthdateBefore
            : birthdayNotifier.value;

    final hasChanges =
        user.name != updates['name'] ||
        birthdateBefore != birthdateAfter ||
        user.country?.id != updates['country'] ||
        user.province?.id != updates['province'];

    if (!hasChanges) {
      showPopUpWithChildren(
        context: context,
        title: 'Alerta',
        subTitle: 'No hay cambios para actualizar.',
        textButton: 'Aceptar',
      );
      return;
    }

    final provider = context.read<LoginProvider>();
    await provider.updateUser(updates);

    if (!mounted) return;
    if (provider.errorMessage == null) {
      setState(() => _user = Preferences().getUser());
      showSnackbar(
        context,
        'Usuario actualizado con éxito',
        SnackbarStatus.success,
      );
    } else {
      showSnackbar(context, provider.errorMessage!, SnackbarStatus.error);
    }
  }

  void _onChangeImg() async {
    final adapter = AdapterLoadImg();
    // 📌 1. Seleccionar imagen
    final String? imgPath = await adapter.pickImagePath();

    if (!mounted) return;

    if (imgPath == null) {
      showPopUpWithChildren(
        context: context,
        title: 'Alerta',
        subTitle:
            'No tienes permisos para seleccionar imágenes. Por favor, habilítalos en la configuración de tu dispositivo.',
        textButton: 'Habilitar',
        onSubmit: () {
          Navigator.pop(context);
          openAppSettings();
        },
      );
      return;
    }

    final provider = context.read<LoginProvider>();
    final String? newImg = await provider.uploadImage({'file': imgPath});

    if (!mounted) return;

    if (newImg != null) {
      setState(() => img = newImg);
      showSnackbar(
        context,
        'Foto de perfil actualizada',
        SnackbarStatus.success,
      );
    } else if (provider.errorMessage != null) {
      showSnackbar(context, provider.errorMessage!, SnackbarStatus.error);
    }
  }
}

LocationModel? _findById(List<LocationModel> locations, String id) {
  if (id.isEmpty) return null;
  for (final location in locations) {
    if (location.id == id) return location;
  }
  return null;
}

// "ECUADOR" → "Ecuador"
String _titleCase(String value) => value
    .toLowerCase()
    .split(' ')
    .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
    .join(' ');

/// Foto de perfil circular con anillo de acento y botón de cámara.
class _ProfileAvatar extends StatelessWidget {
  final String img;
  final VoidCallback onTap;

  const _ProfileAvatar({required this.img, required this.onTap});

  static const double _size = 116;

  ImageProvider? get _image {
    if (img.isEmpty) return null;
    // URL (subida reciente o ruta del servidor) o base64 (formato antiguo).
    if (img.startsWith('http') || img.contains('files/user/')) {
      return NetworkImage(img);
    }
    try {
      return MemoryImage(base64Decode(img));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _size + 12,
        height: _size + 12,
        child: Stack(
          children: [
            Container(
              width: _size,
              height: _size,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor(), width: 3),
              ),
              child: CircleAvatar(
                backgroundColor: deepForestGreen(),
                backgroundImage: image,
                onBackgroundImageError: image == null ? null : (_, __) {},
                child:
                    image == null
                        ? Icon(
                          Icons.person_outline,
                          color: grayInputColor(),
                          size: 48,
                        )
                        : null,
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor(), width: 3),
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  color: primaryColor(),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
