import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:flutter/material.dart';

/// Ícono del catálogo de tipos de conector (`connectorType.icon`), teñido con
/// [color]: los PNG son silueta con fondo transparente. Si no hay ícono o
/// falla la descarga, usa el asset genérico.
class ConnectorTypeIcon extends StatelessWidget {
  final String? icon;
  final Color color;
  final double size;

  const ConnectorTypeIcon({
    super.key,
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

    final value = icon ?? '';
    if (value.isEmpty) return fallback;

    // El backend arma la URL con su HOST_API (p. ej. localhost:3005, que no
    // existe en el teléfono): se toma solo el nombre del archivo y se usa
    // Environment.url, la misma base del resto de llamadas de la app.
    final fileName = Uri.tryParse(value)?.pathSegments.lastOrNull ?? value;

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
