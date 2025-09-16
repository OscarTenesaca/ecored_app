import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PermissionGPS extends StatelessWidget {
  const PermissionGPS({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionGpsProvider>(
      builder: (context, provider, _) {
        if (provider.isPermissionGranted) {
          return _EnableGpsMessage(showButton: false);
        }

        return (provider.isGpsEnabled)
            ? _EnableGpsMessage()
            : _EnableGpsMessage(showButton: false);
      },
    );
  }
}

class _EnableGpsMessage extends StatelessWidget {
  final bool showButton;
  const _EnableGpsMessage({Key? key, this.showButton = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          AssetPaths.map_template,
          height: double.infinity,
          fit: BoxFit.fitHeight,
        ),
        Blur(intensity: Intensity.medium.value, child: SizedBox.expand()),

        Positioned(
          top: UtilSize.height(context) * 0.2,
          left: UtilSize.width(context) * 0.1,
          child: Center(
            child: SizedBox(
              width: UtilSize.width(context) * 0.8,
              height: UtilSize.height(context) * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  // Image.asset(
                  //   AssetPaths.logo_text,
                  //   height: 80,
                  //   fit: BoxFit.fitHeight,
                  // ),
                  Blur(
                    intensity: Intensity.high.value,
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Text(
                        (showButton)
                            ? 'Para usar esta aplicación, es necesario activar el GPS y otorgar permisos de ubicación. Por favor, habilita el GPS en la configuración de tu dispositivo y concede los permisos necesarios cuando se te solicite.'
                            : "Se requiere que el GPS esté activado para usar esta aplicación. Por favor, habilita el GPS en la configuración de tu dispositivo.",
                        textAlign: TextAlign.justify,
                        maxLines: 10,
                        style: TextStyle(
                          fontFamily: 'YaroRg',
                          fontSize: 14,
                          color: primaryColor(),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: showButton,
                    child: CustomButton(
                      textButton: 'Solicitar Permisos',
                      buttonColor: accentColor(),
                      textButtonColor: primaryColor(),
                      onPressed: () {
                        final gpsProvider =
                            context.read<PermissionGpsProvider>();
                        gpsProvider.askGpsAccess();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
