import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_assets.dart';
import 'package:ecored_app/src/core/widgets/blur/blur.dart';
import 'package:flutter/material.dart';

// ❌ Permisos no concedidos
class MapPermission extends StatelessWidget {
  final bool isAllGranted;
  final VoidCallback onPressed;

  const MapPermission({
    super.key,
    required this.isAllGranted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isAllGranted) return const SizedBox.shrink();

    return Stack(
      fit: StackFit.expand,
      children: [
        /// Fondo
        Image.asset(AssetPaths.map_template, fit: BoxFit.cover),

        /// Blur
        const Blur(opacity: 0.7, child: SizedBox.expand()),

        /// Mensaje
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: greyColorWithTransparency(),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_off_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),

                /// Título
                const Text(
                  'Permiso de ubicación requerido',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                /// Descripción
                const Text(
                  'Para mostrar el mapa y tu ubicación en tiempo real, '
                  'necesitamos que actives el GPS y concedas el permiso de ubicación.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                /// Acción
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.location_on),
                    label: const Text('Activar ubicación'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
