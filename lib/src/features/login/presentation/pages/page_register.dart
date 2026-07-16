import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/services/location_service.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/login/presentation/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageRegister extends StatefulWidget {
  const PageRegister({super.key});

  @override
  State<PageRegister> createState() => _PageRegisterState();
}

class _PageRegisterState extends State<PageRegister> {
  final _formKey = GlobalKey<FormState>();
  final _ciController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  final ValueNotifier<String> prefixNotifier = ValueNotifier<String>('+593');
  final ValueNotifier<String> countryNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> provinceNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> birthdayNotifier = ValueNotifier<String>('');

  List<LocationModel> countries = [];
  List<LocationModel> provinces = [];
  final LocationServiceImpl locationService = LocationServiceImpl();

  // Evita relanzar la petición de provincias en cada rebuild del
  // formulario: solo se vuelve a pedir cuando el país realmente cambia.
  String? _provincesCountry;
  Future<List<LocationModel>>? _provincesFuture;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _ciController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    prefixNotifier.dispose();
    countryNotifier.dispose();
    provinceNotifier.dispose();
    birthdayNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),

                // LOGO
                CustomAssetImg(width: 200, height: 100),
                const SizedBox(height: 18),
                LabelTitle(
                  title: 'Crear cuenta',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  alignment: AlignmentGeometry.center,
                ),

                LabelTitle(
                  title: "Completa tus datos para continuar",
                  fontSize: 15,
                  alignment: AlignmentGeometry.center,
                  textColor: grayInputColor(),
                ),

                const SizedBox(height: 40),

                CustomInput(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '* Ingrese su cédula!';
                    }
                    return null;
                  },
                  textInputType: TextInputType.text,
                  hintText: 'Cédula o identificación',
                  filledColor: deepForestGreen(),
                  textEditingController: _ciController,
                ),

                const SizedBox(height: 16),

                CustomInput(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '* Ingrese su nombre!';
                    }
                    return null;
                  },
                  hintText: 'Nombre completo',
                  textEditingController: _nameController,
                  filledColor: deepForestGreen(),
                ),

                const SizedBox(height: 16),

                CustomInput(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '* Ingrese su correo!';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                      return '* Ingrese un correo válido';
                    }
                    return null;
                  },
                  textInputType: TextInputType.emailAddress,
                  hintText: 'Correo electrónico',
                  filledColor: deepForestGreen(),
                  textEditingController: _emailController,
                ),

                const SizedBox(height: 16),

                CustomInput(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '* Ingrese su contraseña!';
                    }
                    if (value.length < 5) {
                      return '* Mínimo 5 caracteres';
                    }
                    return null;
                  },
                  obscured: true,
                  hintText: 'Contraseña',
                  filledColor: deepForestGreen(),
                  textEditingController: _passwordController,
                ),

                const SizedBox(height: 16),

                CustomInput(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '* Confirme su contraseña!';
                    }
                    if (value != _passwordController.text) {
                      return '* Las contraseñas no coinciden!';
                    }
                    return null;
                  },
                  obscured: true,
                  hintText: 'Confirmar Contraseña',
                  filledColor: deepForestGreen(),
                  textEditingController: _confirmPasswordController,
                ),

                const SizedBox(height: 16),

                CustomInputPhone(
                  // hintText: 'Celular',
                  controller: _phoneController,
                  notifier: prefixNotifier,
                  fillColor: deepForestGreen(),
                ),

                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  child: ValueListenableBuilder<String>(
                    valueListenable: birthdayNotifier,
                    builder: (context, value, child) {
                      return CustomInput(
                        hintText: 'Fecha de Nacimiento',
                        textEditingController: TextEditingController(
                          text: value,
                        ),
                        enabled: false,
                        filledColor: deepForestGreen(),

                        validator: (value) {
                          if (value!.isEmpty) {
                            return '* Ingrese fecha ded nacimieto!';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Flexible(
                      child: CustomInputLocation(
                        locations: countries,
                        locationNotifier: countryNotifier,
                        title: 'País',
                        initialCountry: 'ECUADOR', // ✅ ID del país por defecto
                        filledColor: deepForestGreen(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ValueListenableBuilder<String>(
                      valueListenable: countryNotifier,
                      builder: (context, country, child) {
                        if (_provincesCountry != country) {
                          _provincesCountry = country;
                          _provincesFuture = _loadProvinces(country);
                        }
                        return FutureBuilder<List<LocationModel>>(
                          future: _provincesFuture,
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '* Seleccione una ubicación';
                                  }
                                  return null;
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                CustomButton(
                  textButton: 'Registrarse',
                  buttonColor: accentColor(),
                  textButtonColor: primaryColor(),
                  fontSize: 16,
                  onPressed: () => submit(context),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadCountries() async {
    countries = await locationService.countries();
    setState(() {});
  }

  Future<List<LocationModel>> _loadProvinces(String country) async {
    provinces = await locationService.provinces({'country': country});
    return provinces;
  }

  void _pickDate() {
    showDatePickerModal(context: context, notifier: birthdayNotifier);
  }

  Future<void> submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> body = {
        'ci': _ciController.text,
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'prefix': prefixNotifier.value,
        'phone': _phoneController.text,
        'country': countryNotifier.value,
        'province': provinceNotifier.value,
        //transfor the date
        'birthdate': DateTime.parse(birthdayNotifier.value).toIso8601String(),
      };

      final provider = context.read<LoginProvider>();
      await provider.registerUser(body);

      if (!context.mounted) return;

      if (provider.user != null) {
        final msg = 'Registro exitoso. Por favor, inicie sesión.';
        showSnackbar(context, msg, SnackbarStatus.success);

        // Ya existe una pantalla de login debajo en el stack (es la
        // única forma de llegar a Registro), así que se vuelve a ella
        // en vez de apilar una nueva.
        Navigator.pop(context);
      } else if (provider.errorMessage != null) {
        final msg = provider.errorMessage!;
        showSnackbar(context, msg, SnackbarStatus.error);
      }
    }
  }
}
