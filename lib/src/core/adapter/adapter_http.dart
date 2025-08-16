import 'package:dio/dio.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';

class HttpAdapter {
  // El authToken es obligatorio al crear una instancia de la clase

  final Dio _dio = Dio();

  // Constructor que requiere authToken
  HttpAdapter();

  // Configurar los encabezados para incluir el token
  void _setHeaders() {
    String authToken = Preferences().getUser()?.token ?? '';
    Logger.logInfo(' $authToken');
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
    // _handleDioError(response);
    return response;
  }

  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    _setHeaders();
    final response = await _dio.post(endpoint, data: data, options: dioOptions);
    return response;
  }

  Future<Response> put(String endpoint, {Map<String, dynamic>? data}) async {
    _setHeaders();
    final response = await _dio.put(endpoint, data: data, options: dioOptions);

    // _handleDioError(response);
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
    // _handleDioError(response);
    return response;
  }

  void _handleDioError(Response response) {
    if (response.statusCode != 200) {
      throw Exception(response.data ?? 'Error occurred');
    }
  }
}

Options dioOptions = Options(
  followRedirects: false,
  validateStatus: (status) {
    return status! < 500;
  },
);
