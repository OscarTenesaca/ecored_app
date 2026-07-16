import 'dart:convert';

import 'package:ecored_app/src/features/login/data/models/model_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _instance = Preferences._internal();
  factory Preferences() => _instance;
  Preferences._internal();

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _cachedToken;

  static const String _tokenKey = 'user_token';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _cachedToken = await _secureStorage.read(key: _tokenKey);
  }

  // Guardar modelo completo (el token se guarda por separado, cifrado)
  Future<void> saveUser(ModelUser user) async {
    _cachedToken = user.token;
    await _secureStorage.write(key: _tokenKey, value: user.token);

    final Map<String, dynamic> userJson = user.toJson();
    userJson['token'] = '';
    final jsonString = jsonEncode(userJson);
    await _prefs?.setString('user', jsonString);
  }

  // Obtener modelo completo
  ModelUser? getUser() {
    final jsonString = _prefs?.getString('user');
    if (jsonString == null) return null;
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final ModelUser user = ModelUser.fromJson(jsonMap);
    user.token = _cachedToken ?? '';
    return user;
  }

  // Limpiar usuario
  Future<void> clearUser() async {
    _cachedToken = null;
    await _secureStorage.delete(key: _tokenKey);
    await _prefs?.remove('user');
  }

  // Ejemplo dinámico de campo individual
  dynamic get(String key) => _prefs?.get(key);

  Future<void> set(String key, dynamic value) async {
    if (value is String) await _prefs?.setString(key, value);
    if (value is int) await _prefs?.setInt(key, value);
    if (value is bool) await _prefs?.setBool(key, value);
    if (value is double) await _prefs?.setDouble(key, value);
    if (value is List<String>) await _prefs?.setStringList(key, value);
  }
}
