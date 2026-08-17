import 'package:dio/dio.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';

class HttpAdapter {
  // El authToken es obligatorio al crear una instancia de la clase

  final Dio _dio = Dio();

  // Constructor que requiere authToken
  HttpAdapter() {
    // Si el backend responde 401 (token inválido/expirado), la sesión
    // local ya no es válida: se limpia para que la app refleje el
    // estado real de inicio de sesión en la próxima navegación.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (response.statusCode == 401) {
            Preferences().clearUser();
          }
          handler.next(response);
        },
      ),
    );
  }

  // Configurar los encabezados para incluir el token
  void _setHeaders() {
    String authToken = Preferences().getUser()?.token ?? '';
    // Logger.logInfo(' $authToken');
    //Bearer Token
    _dio.options.headers['Authorization'] = 'Bearer $authToken';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    _setHeaders();

    final response = await _dio.get(
      endpoint,
      queryParameters: queryParams,
      options: dioOptions,
    );
    return response;
  }

  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      _setHeaders();
      final response = await _dio.post(
        endpoint,
        data: data,
        options: dioOptions,
      );
      return response;
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  // Sube un archivo como multipart/form-data (p. ej. la foto de perfil).
  Future<Response> uploadFile(
    String endpoint, {
    required String fieldName,
    required String filePath,
  }) async {
    final String authToken = Preferences().getUser()?.token ?? '';
    // No se usa _setHeaders(): fuerza Content-Type: application/json,
    // que rompería el multipart/form-data (Dio arma el boundary solo).
    _dio.options.headers['Authorization'] = 'Bearer $authToken';
    _dio.options.headers.remove('Content-Type');

    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(
      endpoint,
      data: formData,
      options: dioOptions,
    );
    return response;
  }

  Future<Response> put(String endpoint, {Map<String, dynamic>? data}) async {
    _setHeaders();
    final response = await _dio.put(endpoint, data: data, options: dioOptions);
    return response;
  }

  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    _setHeaders();
    final response = await _dio.delete(
      endpoint,
      queryParameters: queryParams,
      options: dioOptions,
    );
    return response;
  }
}

Options dioOptions = Options(
  followRedirects: false,
  validateStatus: (status) {
    return status! < 500;
  },
);
