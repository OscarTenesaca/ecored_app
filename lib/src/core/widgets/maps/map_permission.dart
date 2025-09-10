import 'package:flutter/material.dart';

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

    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Es necesario activar el GPS y otorgar permisos de ubicación para usar el mapa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Conceder permisos'),
            ),
          ],
        ),
      ),
    );
  }
}
