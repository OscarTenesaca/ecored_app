import 'dart:convert';

import 'package:ecored_app/src/features/login/data/models/model_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _instance = Preferences._internal();
  factory Preferences() => _instance;
  Preferences._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Guardar modelo completo
  Future<void> saveUser(ModelUser user) async {
    final jsonString = jsonEncode(user.toJson());
    final saved = await _prefs?.setString('user', jsonString);
    print('User saved to preferences: ${saved}');
  }

  // Obtener modelo completo
  ModelUser? getUser() {
    final jsonString = _prefs?.getString('user');
    if (jsonString == null) return null;
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return ModelUser.fromJson(jsonMap);
  }

  // Limpiar usuario
  Future<void> clearUser() async {
    print('Clearing user from preferences');
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
