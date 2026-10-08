import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:flutter/foundation.dart';

abstract class ChargerRemoteDataSource {
  Future<ModelOrder?> getOrderData(Map<String, dynamic> params);
  Future<int> deleteStopCharger(Map<String, dynamic> body);
}

class ChargerRemoteDataSourceImpl implements ChargerRemoteDataSource {
  final String url;
  final HttpAdapter httpAdapter = HttpAdapter();

  ChargerRemoteDataSourceImpl(this.url);

  @override
  Future<ModelOrder?> getOrderData(Map<String, dynamic> params) async {
    // Si se manda un `id` puntual (p. ej. justo después de crear la orden, con
    // el _id que ya devolvió el POST /orders), se resuelve directo por
    // GET /orders/:id — sin ambigüedad y sin ninguna ventana de carrera posible.
    // find/one sigue existiendo para cuando no hay ningún _id de referencia
    // todavía (p. ej. al reabrir la app, para saber si había algo activo).
    final hasId = params.containsKey('id');
    final String endpoint =
        hasId
            ? '$url/api/v1/orders/${params['id']}'
            : '$url/api/v1/orders/find/one';

    debugPrint(
      '🔎 getOrderData → ${hasId ? "GET /orders/:id" : "GET /orders/find/one"} '
      '($endpoint) params=$params',
    );

    final response = await httpAdapter.get(
      endpoint,
      queryParams: hasId ? null : params,
    );

    debugPrint(
      '🔎 getOrderData ← statusCode=${response.statusCode} data=${response.data}',
    );

    // 404: el usuario no tiene ninguna carga activa (estado normal, no un error).
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Ocurrió un problema, intente más tarde');
    }
    return ModelOrder.fromJson(response.data['data']);
  }

  @override
  Future<int> deleteStopCharger(Map<String, dynamic> body) async {
    final String endpoint = '$url/api/v1/orders/stop';

    try {
      final response = await httpAdapter.delete(endpoint, queryParams: body);
      return response.statusCode ?? -1;
    } catch (e) {
      return -1;
    }
  }
}
