import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/core/models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<LocationModel>> countries();
  Future<List<LocationModel>> provinces(Map<String, dynamic>? query);
}

class LocationServiceImpl implements LocationRemoteDataSource {
  final String url = Environment.url;
  final HttpAdapter httpAdapter = HttpAdapter();

  @override
  Future<List<LocationModel>> countries() async {
    final String enpoint = '$url/api/v1/country';
    final response = await httpAdapter.get(enpoint);
    if (response.statusCode != 200) {
      throw 'Paices no disponibles';
    }
    final respModelLocation =
        (response.data['data'] as List)
            .map((item) => LocationModel.fromJson(item))
            .toList();

    return respModelLocation;
  }

  @override
  Future<List<LocationModel>> provinces(Map<String, dynamic>? query) async {
    final response = await httpAdapter.get(
      '$url/api/v1/province',
      queryParams: query,
    );

    if (response.statusCode != 200) {
      // throw 'Provincias no disponibles';
      return []; // Retorna una lista vacía si no hay provincias disponibles
    }
    final List<LocationModel> respModelLocation =
        (response.data['data'] as List)
            .map((item) => LocationModel.fromJson(item))
            .toList();
    return respModelLocation;
  }
}
