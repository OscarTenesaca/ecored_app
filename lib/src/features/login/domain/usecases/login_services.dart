import 'package:ecored_app/src/features/login/data/models/model_user.dart';
import 'package:ecored_app/src/features/login/domain/repositories/login_repository.dart';

//? CLASE THREE

class LoginServices {
  final LoginRepository repositoryLogin;

  LoginServices(this.repositoryLogin);

  // Login user callback the repository
  Future<ModelUser> login(String email, String password) async {
    return repositoryLogin.login(email, password);
  }

  // Logout user callback the repository
  Future<int> logout() async {
    return repositoryLogin.logout();
  }

  // Save FCM token callback the repository
  Future<int> saveFCM(Map<String, dynamic> body) async {
    return repositoryLogin.saveFCM(body);
  }
}
