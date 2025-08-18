import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/services/location_service.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_logger.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:flutter/material.dart';

class PageRegister extends StatelessWidget {
  const PageRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor(),

      body: Container(
        decoration: globalDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomAssetImg(width: 200, height: 100),
            LabelTitle(
              alignment: Alignment.center,
              title: 'Bienvenido a Ecored',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),

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
  final ValueNotifier<String> birthdayNotifier = ValueNotifier<String>('');

  List<LocationModel> countries = [];
  final LocationServiceImpl locationService = LocationServiceImpl();

  @override
  void initState() {
    _loadCountries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: Column(
          spacing: 20,
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
              // child: CustomInput(
              //   hintText: 'Fecha de Nacimiento',
              //   enabled: false,
              //   validator: (value) {
              //     return null;
              //   },
              // ),
            ),

            Row(
              children: [
                Flexible(
                  child: CustomInputLocation(
                    locations: countries,
                    locationNotifier: countryNotifier,
                    title: 'Selecciona país',
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: CustomInputLocation(
                    locations: countries,
                    locationNotifier: countryNotifier,
                    title: 'Selecciona provincia',
                  ),
                ),
              ],
            ),

            CustomButton(
              textButton: 'Registrarse',
              buttonColor: accentColor(),
              textButtonColor: primaryColor(),
              onPressed: () {
                Logger.logInfo('user data');
                Logger.logInfo('Cédula: ${_ciController.text}');
                Logger.logInfo('Nombre: ${_nameController.text}');
                Logger.logInfo('Correo: ${_emailController.text}');
                Logger.logInfo('Prefix: ${prefixNotifier.value}');
                Logger.logInfo('Teléfono: ${_phoneController.text}');
                Logger.logInfo('País: ${countryNotifier.value}');
                Logger.logInfo(
                  'Fecha de Nacimiento: ${birthdayNotifier.value}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCountries() async {
    countries = await locationService.countries();
    setState(() {});
  }

  void _pickDate() {
    showDatePickerModal(context: context, notifier: birthdayNotifier);
  }
}
