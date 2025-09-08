import 'package:ecored_app/src/features/login/data/models/model_user.dart';

//? CLASE TWO
abstract class LoginRepository {
  Future<ModelUser> registerUser(Map<String, dynamic> userData);
  Future<int> saveFCM(Map<String, dynamic> body);
  Future<ModelUser> login(String email, String password);
  Future<int> logout();
  Future<ModelUser> updateUser(Map<String, dynamic> userData);
  Future<String> uploadImage(Map<String, dynamic> body);
}
