import 'package:ecored_app/src/core/models/nuvei_model.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:flutter/material.dart';
import 'package:ecored_app/src/features/finance/domain/usecases/finance_services.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceServices services;

  bool isLoading = false;
  ModelFinance? financeData;
  ModelOrder? orderData;
  ModelRecharge? rechargeData;
  List<ModelTransaction>? transactionData;
  String? errorMessage;

  FinanceProvider(this.services);

  Future<void> getWalletData(Map<String, dynamic> params) async {
    isLoading = true;

    try {
      financeData = await services.getWalletData(params);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
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
}
