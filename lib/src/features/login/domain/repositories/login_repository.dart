import 'package:ecored_app/src/features/login/data/models/model_user.dart';

//? CLASE TWO
abstract class LoginRepository {
  Future<int> saveFCM(Map<String, dynamic> body);
  Future<ModelUser> login(String email, String password);
  Future<int> logout();
}
