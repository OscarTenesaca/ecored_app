import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';
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

  static Widget _buildField({
    required String hint,
    required Color fieldColor,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(.35),
          fontSize: 15,
        ),
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(.04)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFB6FF00), width: 1.2),
        ),
      ),
    );
  }
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

  @override
  void initState() {
    // _ciController.text = '0302618251';
    // _nameController.text = 'Oscar Tenesaca';
    // _emailController.text = 'tenesaca.999@gmail.com';
    // _passwordController.text = '12345';
    // _confirmPasswordController.text = '12345';
    // _phoneController.text = '983895402';

    super.initState();
    _loadCountries();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFFB6FF00);

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
                    if (value!.isEmpty) {
                      return '* Ingrese su cédula!';
                    }
                    return null;
                  },
                  textInputType: TextInputType.emailAddress,
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
                    if (value!.isEmpty) {
                      return '* Ingrese su correo!';
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
                    if (value!.isEmpty) {
                      return '* Ingrese su contraseña!';
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
                    if (value!.isEmpty) {
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
                        return FutureBuilder<List<LocationModel>>(
                          future: _loadProvinces(country),
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
      print('pasoo');
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

      if (provider.user != null) {
        final msg = 'Registro exitoso. Por favor, inicie sesión.';
        showSnackbar(context, msg, SnackbarStatus.success);

        Navigator.pushNamed(context, RouteNames.pageLogin);
      } else if (provider.errorMessage != null) {
        final msg = provider.errorMessage!;
        showSnackbar(context, msg, SnackbarStatus.error);
      }
    }
  }
}
