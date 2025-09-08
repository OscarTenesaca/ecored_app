import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/alerts/snackbar.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/login/presentation/provider/login_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageProfile extends StatelessWidget {
  const PageProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Consumer<LoginProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Container(
              padding: UtilSize.paddingMain(),
              child: Column(
                children: <Widget>[
                  _personInformation(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: LabelTitle(
                      title: 'Información',
                      fontSize: 14,
                      textColor: grayInputColor(),
                    ),
                  ),
                  _actionInformation(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: LabelTitle(
                      title: 'Preferencias',
                      fontSize: 14,
                      textColor: grayInputColor(),
                    ),
                  ),
                  _preferencesInformation(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Column _personInformation(BuildContext context) {
    final user = Preferences().getUser();
    return Column(
      children: <Widget>[
        SizedBox(height: UtilSize.appBarHeight()),
        CustomHiveImg(
          // img: 'https://getbeeapp.com/view/customer/constant_1.png',
          img: user?.img ?? '',
          size: 120,
          alignment: Alignment.center,
          onTap: () {
            Navigator.pushNamed(context, RouteNames.pageUser);
          },
        ),

        LabelTitle(
          alignment: Alignment.center,
          title: user?.name ?? '',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        LabelTitle(
          alignment: Alignment.center,
          title: user?.email ?? '',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          textColor: grayInputColor(),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _actionInformation() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: greyColorWithTransparency(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          LabelIconTitle(
            icon: CupertinoIcons.lock,
            iconColor: Colors.amber,
            title: 'Cambiar Contraseña',
            fontSize: 14,
          ),
          Divider(),
          LabelIconTitle(
            icon: CupertinoIcons.share,
            iconColor: Colors.green,
            title: 'Compartir Aplicación',
            fontSize: 14,
          ),

          // Add inventory widgets here
        ],
      ),
    );
  }

  Widget _preferencesInformation(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: greyColorWithTransparency(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          LabelIconTitle(
            icon: CupertinoIcons.info,
            iconColor: Colors.grey,
            title: 'Acerca de Nosotros',
            fontSize: 14,
          ),
          Divider(),
          LabelIconTitle(
            icon: CupertinoIcons.phone,
            iconColor: Colors.blueAccent,
            title: 'Contactar soporte',
            fontSize: 14,
          ),
          Divider(),
          LabelIconTitle(
            icon: CupertinoIcons.question_circle,
            iconColor: Colors.green,
            title: 'FAQ o Ayuda',
            fontSize: 14,
          ),
          Divider(),
          LabelIconTitle(
            icon: CupertinoIcons.device_phone_portrait,
            iconColor: Colors.teal,
            title: 'Versión de la App',
            fontSize: 14,
          ),
          Divider(),
          InkWell(
            child: LabelIconTitle(
              icon: CupertinoIcons.power,
              iconColor: const Color.fromARGB(255, 140, 113, 111),
              title: 'Cerrar Sesión',
              fontSize: 14,
            ),
            onTap: () async {
              final provider = context.read<LoginProvider>(); // ✅ usa read aquí
              await provider.logout();
              if (provider.user == null) {
                Navigator.pushReplacementNamed(context, RouteNames.pageLogin);
              } else {
                showSnackbar(context, provider.errorMessage!);
              }
            },
          ),
        ],
      ),
    );
  }
}
