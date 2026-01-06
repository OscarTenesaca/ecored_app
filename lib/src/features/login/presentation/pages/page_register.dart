import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/services/location_service.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/login/presentation/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageRegister extends StatelessWidget {
  const PageRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor(),

      body: Padding(
        padding: EdgeInsets.only(top: UtilSize.statusBarHeight()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomAssetImg(width: 200, height: 100),
            SizedBox(height: 40),
            const _Form(),
          ],
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({super.key});

  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
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
    _ciController.text = '0302618252';
    _nameController.text = 'John Doe';
    _emailController.text = 'johndoe@example.com';
    _passwordController.text = '12345';
    _confirmPasswordController.text = '12345';
    _phoneController.text = '999999999';

    super.initState();
    _loadCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            spacing: 15,
            children: <Widget>[
              CustomInput(
                validator: (value) {
                  if (value!.isEmpty) {
                    return '* Ingrese su cédula!';
                  }
                  return null;
                },
                textInputType: TextInputType.number,
                hintText: 'Cédula',
                textEditingController: _ciController,
              ),

              CustomInput(
                validator: (value) {
                  if (value!.isEmpty) {
                    return '* Ingrese su nombre!';
                  }
                  return null;
                },
                hintText: 'Nombre',
                textEditingController: _nameController,
              ),

              CustomInput(
                validator: (value) {
                  if (value!.isEmpty) {
                    return '* Ingrese su correo!';
                  }
                  return null;
                },
                textInputType: TextInputType.emailAddress,
                hintText: 'Correo',
                textEditingController: _emailController,
              ),

              CustomInput(
                validator: (value) {
                  if (value!.isEmpty) {
                    return '* Ingrese su contraseña!';
                  }
                  return null;
                },
                obscured: true,
                hintText: 'Contraseña',
                textEditingController: _passwordController,
              ),

              // SizedBox(height: 20),
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
                textEditingController: _confirmPasswordController,
              ),

              CustomInputPhone(
                controller: _phoneController,
                notifier: prefixNotifier,
              ),

              InkWell(
                onTap: _pickDate,
                child: ValueListenableBuilder<String>(
                  valueListenable: birthdayNotifier,
                  builder: (context, value, child) {
                    return CustomInput(
                      hintText: 'Fecha de Nacimiento',
                      textEditingController: TextEditingController(text: value),
                      enabled: false,
                      validator: (value) {
                        return null;
                      },
                    );
                  },
                ),
              ),

              Row(
                children: [
                  Flexible(
                    child: CustomInputLocation(
                      locations: countries,
                      locationNotifier: countryNotifier,
                      title: 'País',
                      initialCountry: 'ECUADOR', // ✅ ID del país por defecto
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
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),

              CustomButton(
                textButton: 'Registrarse',
                buttonColor: accentColor(),
                textButtonColor: primaryColor(),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // vaalid phone ,birthdate, country, province
                    if (_phoneController.text.isEmpty ||
                        birthdayNotifier.value.isEmpty ||
                        countryNotifier.value.isEmpty ||
                        provinceNotifier.value.isEmpty) {
                      final msg =
                          'Por favor revise que todos los campos estén completos.';
                      showSnackbar(context, msg, SnackbarStatus.error);
                      return;
                    }

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
                      'birthdate':
                          DateTime.parse(
                            birthdayNotifier.value,
                          ).toIso8601String(),
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
                  } else {
                    print('Formulario no válido');
                  }
                },
              ),
            ],
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
}
