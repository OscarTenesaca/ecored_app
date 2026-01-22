import 'package:ecored_app/src/core/adapter/adapter_http.dart';
import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/core/models/payment_model.dart';

abstract class PaymentesRemoteDataSource {
  Future<List<PaymentModel>> getPaymentMethods();
}

class PaymentesServiceImpl implements PaymentesRemoteDataSource {
  final String url = Environment.url;
  final HttpAdapter httpAdapter = HttpAdapter();

  @override
  Future<List<PaymentModel>> getPaymentMethods() async {
    final String enpoint = '$url/api/v1/paymentes';
    final query = {'status': 'AVAILABLE', 'isPrivate': 'false'};
    final response = await httpAdapter.get(enpoint, queryParams: query);
    if (response.statusCode != 200) {
      throw 'Métodos de pago no disponibles';
    }
    final respModelPayment =
        (response.data['data'] as List)
            .map((item) => PaymentModel.fromJson(item))
            .toList();

    return respModelPayment;
  }
}
