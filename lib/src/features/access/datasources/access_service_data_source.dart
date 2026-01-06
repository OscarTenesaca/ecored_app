import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';

abstract class AccessServicesDataSource {
  Future validateToken();
}

class AccessServicesDataSourceImpl implements AccessServicesDataSource {
  //call htttps adapter
  final String url;
  final Preferences prefs = Preferences();
  final HttpAdapter httpAdapter = HttpAdapter();

  AccessServicesDataSourceImpl(this.url) {}

  @override
  Future<int> validateToken() async {
    final String endpoint = '$url/api/v1/auth/user/validate';
    final response = await httpAdapter.get(endpoint);

    if (response.statusCode == 200) {
      print('update data user');
      return response.statusCode ?? 200;
    } else {
      prefs.clearUser();
      return response.statusCode ?? 401;
    }
  }
}
