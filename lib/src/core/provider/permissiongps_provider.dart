import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionGpsProvider extends ChangeNotifier {
  bool isGpsEnabled = false;
  bool isPermissionGranted = false;
  bool isLoading = true;

  bool get isAllGranted => isGpsEnabled && isPermissionGranted;

  StreamSubscription<ServiceStatus>? _gpsServiceSubscription;
  StreamSubscription<Position>? _positionStream;

  Position? currentPosition;
  bool _disposed = false;

  PermissionGpsProvider() {
    _init();
  }

  // 🚀 Inicialización
  Future<void> _init() async {
    print('PermissionGpsProvider _init');

    final gpsInitial = await Future.wait([
      _checkGpsStatus(),
      _isPermissionsGranted(),
    ]);

    isGpsEnabled = gpsInitial[0];
    isPermissionGranted = gpsInitial[1];

    // Solicitar permisos si no están concedidos
    if (!isPermissionGranted) {
      await askGpsAccess();
    }

    isLoading = false;
    _safeNotify();
  }

  // 🔹 Verificar si los permisos ya están concedidos
  Future<bool> _isPermissionsGranted() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // 🔹 Verificar si el GPS está activo y escuchar cambios
  Future<bool> _checkGpsStatus() async {
    final isEnable = await Geolocator.isLocationServiceEnabled();

    _gpsServiceSubscription = Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) {
      isGpsEnabled = status == ServiceStatus.enabled;
      _safeNotify();
    });

    return isEnable;
  }

  // 🔹 Pedir permisos de ubicación
  Future<void> askGpsAccess() async {
    final status = await Geolocator.requestPermission();

    switch (status) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        isPermissionGranted = true;
        break;
      case LocationPermission.denied:
        isPermissionGranted = false;
        print('Permiso de ubicación denegado, puede solicitarse nuevamente.');
        break;
      case LocationPermission.deniedForever:
        isPermissionGranted = false;
        print(
          'Permiso de ubicación denegado permanentemente. Abrir Configuración manualmente.',
        );
        break;
      default:
        isPermissionGranted = false;
        break;
    }
    _safeNotify();
  }

  // 🔹 Obtener posición actual
  Future<Position?> getCurrentPosition() async {
    if (!isPermissionGranted || !isGpsEnabled) {
      print('No se puede obtener la posición: permisos o GPS no activos.');
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        // desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition = position;
      _safeNotify();
      return position;
    } catch (e) {
      print('Error al obtener posición: $e');
      return null;
    }
  }

  // 🔹 Iniciar seguimiento continuo
  Future<void> startTracking() async {
    _positionStream?.cancel();

    if (!isPermissionGranted || !isGpsEnabled) {
      print('No se puede iniciar tracking: permisos o GPS no habilitados.');
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10, // Solo notifica cambios de 10m o más
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        currentPosition = position;
        print('Nueva posición: $position');
        _safeNotify();
      },
      onError: (e) {
        print('Error en stream de ubicación: $e');
      },
    );
  }

  // 🔹 Detener seguimiento
  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  // 🔹 Notificar solo si el provider no está disposed
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _gpsServiceSubscription?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';

// class PermissionGpsProvider extends ChangeNotifier {
//   bool isGpsEnabled = false;
//   bool isPermissionGranted = false;
//   bool isLoading = true;
//   bool get isAllGranted => isGpsEnabled && isPermissionGranted;

//   StreamSubscription? _gpsServiceSubscription;

//   Position? currentPosition;
//   StreamSubscription<Position>? _positionStream;

//   PermissionGpsProvider() {
//     _init();
//   }

//   // 🚀 Inicialización (similar a _init del bloc)
//   Future<void> _init() async {
//     print('PermissionGpsProvider _init');
//     final gpsInitial = await Future.wait([
//       _checkGpsStatus(),
//       _isPermissionsGranted(),
//     ]);

//     isGpsEnabled = gpsInitial[0];
//     isPermissionGranted = gpsInitial[1];

//     if (!isPermissionGranted) {
//       await askGpsAccess();
//     }

//     isLoading = false;
//     notifyListeners();
//   }

//   // ✅ Verificar permisos
//   Future<bool> _isPermissionsGranted() async {
//     final LocationPermission permission = await Geolocator.checkPermission();
//     return permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse;
//   }

//   // ✅ Verificar si el GPS está activado y escuchar cambios
//   Future<bool> _checkGpsStatus() async {
//     final isEnable = await Geolocator.isLocationServiceEnabled();

//     _gpsServiceSubscription = Geolocator.getServiceStatusStream().listen((
//       event,
//     ) {
//       final enabled = (event.index == 1) ? true : false;

//       isGpsEnabled = enabled;
//       notifyListeners();
//     });

//     return isEnable;
//   }

//   // ✅ Pedir permisos
//   Future<void> askGpsAccess() async {
//     final status = await Geolocator.requestPermission();

//     switch (status) {
//       case LocationPermission.whileInUse:
//       case LocationPermission.always:
//         isPermissionGranted = true;
//         break;
//       case LocationPermission.denied:
//       case LocationPermission.deniedForever:
//       case LocationPermission.unableToDetermine:
//         isPermissionGranted = false;
//         openAppSettings(); // del package:permission_handler
//         break;
//     }
//     notifyListeners();
//   }

//   //? add this method to get current position and start listening to position changes
//   Future<Position> getCurrentPosition() async {
//     final position = await Geolocator.getCurrentPosition();
//     return position;
//   }

//   void startTracking() {
//     _positionStream?.cancel();

//     const locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.best,
//       distanceFilter: 100, // 🔹 solo notifica si se mueve 100m o más
//     );

//     _positionStream = Geolocator.getPositionStream(
//       locationSettings: locationSettings,
//     ).listen((Position position) {
//       currentPosition = position;
//       print('New position: $position');
//       notifyListeners(); // 🔹 actualiza widgets que consumen este provider
//     });
//   }

//   void stopTracking() {
//     _positionStream?.cancel();
//     _positionStream = null;
//   }

//   @override
//   void dispose() {
//     _gpsServiceSubscription?.cancel();
//     super.dispose();
//   }
// }
