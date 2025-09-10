import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionGpsProvider extends ChangeNotifier {
  bool isGpsEnabled = false;
  bool isPermissionGranted = false;
  bool isLoading = true;

  bool get isAllGranted => isGpsEnabled && isPermissionGranted;

  StreamSubscription? _gpsServiceSubscription;

  PermissionGpsProvider() {
    _init();
  }

  // 🚀 Inicialización (similar a _init del bloc)
  Future<void> _init() async {
    final gpsInitial = await Future.wait([
      _checkGpsStatus(),
      _isPermissionsGranted(),
    ]);

    isGpsEnabled = gpsInitial[0];
    isPermissionGranted = gpsInitial[1];
    isLoading = false;
    notifyListeners();
  }

  // ✅ Verificar permisos
  Future<bool> _isPermissionsGranted() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // ✅ Verificar si el GPS está activado y escuchar cambios
  Future<bool> _checkGpsStatus() async {
    final isEnable = await Geolocator.isLocationServiceEnabled();

    _gpsServiceSubscription = Geolocator.getServiceStatusStream().listen((
      event,
    ) {
      final enabled = (event.index == 1) ? true : false;

      isGpsEnabled = enabled;
      notifyListeners();
    });

    return isEnable;
  }

  // ✅ Pedir permisos
  Future<void> askGpsAccess() async {
    final status = await Geolocator.requestPermission();

    switch (status) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        isPermissionGranted = true;
        break;
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        isPermissionGranted = false;
        openAppSettings(); // del package:permission_handler
        break;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _gpsServiceSubscription?.cancel();
    super.dispose();
  }
}
