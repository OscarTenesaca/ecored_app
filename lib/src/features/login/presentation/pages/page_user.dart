import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/services/location_service.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/utils/utils_size.dart';
import 'package:ecored_app/src/core/widgets/alerts/snackbar.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/login/data/models/model_user.dart';
import 'package:ecored_app/src/features/login/presentation/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageUser extends StatelessWidget {
  const PageUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        decoration: globalDecoration(),
        child: Consumer<LoginProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [SizedBox(height: UtilSize.appBarHeight()), _Form()],
              ),
            );
          },
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

  String img = '';
  final _ciController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final ValueNotifier<String> prefixNotifier = ValueNotifier<String>('+593');
  final ValueNotifier<String> countryNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> provinceNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> birthdayNotifier = ValueNotifier<String>('');

  List<LocationModel> countries = [];
  List<LocationModel> provinces = [];

  final ModelUser? user = Preferences().getUser();
  final LocationServiceImpl locationService = LocationServiceImpl();

  @override
  void initState() {
    img = user?.img ?? '';
    _ciController.text = user?.ci ?? '';
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
    final dateOnly = '${user?.birthdate}'.split(' ').first;
    birthdayNotifier.value = dateOnly != 'null' ? dateOnly : '';
    countryNotifier.value = user?.country?.id ?? '';
    provinceNotifier.value = user?.province?.id ?? '';
    _loadCountries();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 15,
        children: [
          SizedBox(height: 15),
          CustomHiveImg(
            img: 'https://getbeeapp.com/view/customer/constant_1.png',
            size: 120,
            alignment: Alignment.center,
            onTap: () {},
          ),

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
            enabled: false,
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
                return '* Ingrese su correo electrónico!';
              }
              return null;
            },
            hintText: 'Correo electrónico',
            textEditingController: _emailController,
            enabled: false,
          ),

          IgnorePointer(
            ignoring: true, // true = bloqueado, false = activo
            child: CustomInputPhone(
              controller: _phoneController,
              notifier: prefixNotifier,
            ),
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
                  title: 'Selecciona país',
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
                          title: user?.province?.name ?? '',
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),

          CustomButton(
            textButton: 'Actualizar',
            buttonColor: accentColor(),
            textButtonColor: primaryColor(),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                //validar que la data sea distinto sino no actualiza nada
                if (user != null) {
                  final updates = {
                    'img': img,
                    'name': _nameController.text,
                    'birthdate':
                        DateTime.parse(
                          birthdayNotifier.value,
                        ).toIso8601String(),
                    'country': countryNotifier.value,
                    'province': provinceNotifier.value,
                  };

                  final String birthdateOnlyLocal =
                      '${user!.birthdate}'.split(' ').first;
                  final String birthdateOnlyUpdate =
                      '${updates['birthdate']}'.split('T').first;

                  if (user!.name != updates['name'] ||
                      birthdateOnlyLocal != birthdateOnlyUpdate ||
                      user!.country?.id != updates['country'] ||
                      user!.province?.id != updates['province']) {
                    final provider = context.read<LoginProvider>();
                    await provider.updateUser(updates);

                    if (provider.user != null) {
                    } else if (provider.errorMessage != null) {
                      showSnackbar(context, provider.errorMessage!);
                    }
                    // showSnackbar(context, 'Usuario actualizado con éxito');
                  } else {
                    print('no hay cambios que actualizar');
                    showSnackbar(context, 'No hay cambios que actualizar');
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _pickDate() {
    showDatePickerModal(context: context, notifier: birthdayNotifier);
  }

  Future<void> _loadCountries() async {
    countries = await locationService.countries();
    setState(() {});
  }

  Future<List<LocationModel>> _loadProvinces(String country) async {
    provinces = await locationService.provinces({'country': country});
    return provinces;
  }
}
