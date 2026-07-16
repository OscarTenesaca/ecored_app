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
        break;
      case LocationPermission.deniedForever:
        isPermissionGranted = false;
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
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      currentPosition = position;
      notifyListeners();
      return position;
    } catch (_) {
      return null;
    }
  }

  // 🔹 Iniciar seguimiento continuo
  Future<void> startTracking() async {
    _positionStream?.cancel();

    if (!isPermissionGranted || !isGpsEnabled) {
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
        notifyListeners();
      },
    );
  }

  void openSettings() async {
    await Geolocator.openAppSettings();
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
