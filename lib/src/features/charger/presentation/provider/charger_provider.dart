import 'package:ecored_app/src/features/charger/domain/usecase/charger_services.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:flutter/material.dart';

class ChargerProvider extends ChangeNotifier {
  final ChargerServices services;

  ModelOrder? orderData;
  bool isLoading = false;
  String? errorMessage;

  ChargerProvider(this.services);

  Future<void> getOrderData(Map<String, dynamic> params) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      orderData = await services.getOrderData(params);

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      orderData = null;
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<int> deleteStopCharger(Map<String, dynamic> params) async {
    try {
      final stopData = await services.deleteStopCharger(params);
      return stopData;
    } catch (e) {
      return -1;
    }
  }
}
