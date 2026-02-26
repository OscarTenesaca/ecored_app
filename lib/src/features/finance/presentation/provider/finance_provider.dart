import 'package:ecored_app/src/core/models/nuvei_model.dart';
import 'package:ecored_app/src/core/utils/utils_logger.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';
import 'package:ecored_app/src/features/maps/domain/usecases/station_services.dart';
import 'package:flutter/material.dart';
import 'package:ecored_app/src/features/finance/domain/usecases/finance_services.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceServices services;
  final StationServices stationServices; // <-- agregamos esto

  bool isLoading = false;
  ModelFinance? financeData;
  ModelOrder? orderData;
  ModelRecharge? rechargeData;
  ModelCharger? chargerData; // <-- para almacenar el charger
  List<ModelTransaction>? transactionData;
  String? errorMessage;

  // FinanceProvider(this.services);
  FinanceProvider({
    required this.services,
    required this.stationServices, // <-- inyectamos StationServices
  });

  Future<void> getWalletData(Map<String, dynamic> params) async {
    isLoading = true;

    try {
      financeData = await services.getWalletData(params);
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTransactionData(Map<String, dynamic> params) async {
    isLoading = true;

    try {
      transactionData = await services.getTransactionData(params);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getOrderData(Map<String, dynamic> params) async {
    isLoading = true;

    try {
      orderData = await services.getOrderData(params);
      print('ORDER DATA FETCHED: ${orderData}');
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getRechargeData(Map<String, dynamic> params) async {
    isLoading = true;

    try {
      rechargeData = await services.getRechargeData(params);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map> postNuveiData(ModelNuvei body) async {
    try {
      final response = await services.postNuveiData(body);
      return response;
    } catch (e) {
      errorMessage = e.toString();
    }
    return {};
  }

  Future<int> postRecharge(Map<String, dynamic> body) async {
    try {
      final response = await services.postRecharge(body);
      return response;
    } catch (e) {
      errorMessage = e.toString();
    }
    return -1;
  }

  Future<int> postOrder(Map<String, dynamic> body) async {
    try {
      isLoading = true;
      final response = await services.postOrder(body);
      isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
    return -1;
  }

  Future<int> postOrderPayment(Map<String, dynamic> body) async {
    try {
      isLoading = true;
      final response = await services.postOrderPayment(body);
      isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
    return -1;
  }

  Future<void> findOneCharger(String chargerId) async {
    isLoading = true;
    notifyListeners();

    try {
      chargerData = await stationServices.findOneCharger({'id': chargerId});
    } catch (e) {
      errorMessage = 'Error fetching charger: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearChargerData() async {
    chargerData = null;
    errorMessage = null;
    notifyListeners();
  }
}
