import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/features/login/data/models/model_user.dart';

// CLASE FOUR
abstract class LoginRemoteDataSource {
  Future<ModelUser> login(String name, String email);
  Future<int> logout();
  Future<int> saveFCM(Map<String, dynamic> body);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  //call htttps adapter
  final String url;
  final Preferences prefs = Preferences();
  final HttpAdapter httpAdapter = HttpAdapter();

  LoginRemoteDataSourceImpl(this.url) {}

  @override
  Future<ModelUser> login(String email, String password) async {
    final String endpoint = '$url/api/v1/auth/user/login';
    final Map<String, dynamic> data = {'email': email, 'password': password};
    final response = await httpAdapter.post(endpoint, data: data);

    if (response.statusCode != 201) {
      // throw Exception('Failed to login: ${response.statusMessage}');
      throw ('Usuario o contraseña incorrecta');
    }

    final respModelUser = ModelUser.fromJson(response.data['data']);
    prefs.saveUser(respModelUser);
    return respModelUser;
  }

  @override
  Future<int> logout() async {
    final String endpoint = '$url/api/v1/auth/user/logout';
    final response = await httpAdapter.delete(endpoint);
    if (response.statusCode != 200) {
      throw ('Ocurrió un problema, intente más tarde');
    }

    await prefs.clearUser();
    return response.statusCode!;
  }

  @override
  Future<int> saveFCM(Map<String, dynamic> body) {
    // TODO: implement saveFCM
    throw UnimplementedError();
  }
}
