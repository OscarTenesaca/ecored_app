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
      print('Logout result: $result');

      if (result == 200) {
        user = null;
      }
    } catch (e) {
      print('Error during logout: $e');
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

  Future<void> uploadImage(Map<String, dynamic> body) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final String result = await loginServices.uploadImage(body);
      print('Upload Image result: $result');
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
