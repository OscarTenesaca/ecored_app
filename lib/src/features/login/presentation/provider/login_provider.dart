import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/features/login/data/models/model_user.dart';
import 'package:ecored_app/src/features/login/domain/usecases/login_services.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  final LoginServices loginServices;

  bool isLoading = false;
  ModelUser? user;
  String? errorMessage;

  LoginProvider(this.loginServices);

  Future<void> registerUser(Map<String, dynamic> userData) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      user = await loginServices.registerUser(userData);

      if (user != null) {
        errorMessage = null; // Clear any previous error messages
      }
    } catch (e) {
      errorMessage = e.toString(); // Assign the error message
      user = null; // Make sure user is null if there was an error
    } finally {
      isLoading = false;
      notifyListeners(); // Notify listeners to rebuild UI with the updated state
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      user = await loginServices.login(email, password);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final int result = await loginServices.logout();

      if (result == 200) {
        user = null;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      user = await loginServices.updateUser(userData);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Devuelve la nueva URL de la imagen si la subida fue exitosa, o null
  // si falló (ver errorMessage). El backend ya persiste el cambio en el
  // usuario al subir el archivo, así que aquí solo se actualiza la copia
  // local en Preferences para que no quede desincronizada.
  Future<String?> uploadImage(Map<String, dynamic> body) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final String secureUrl = await loginServices.uploadImage(body);

      final cachedUser = Preferences().getUser();
      if (cachedUser != null) {
        cachedUser.img = secureUrl;
        await Preferences().saveUser(cachedUser);
      }
      user?.img = secureUrl;

      return secureUrl;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
