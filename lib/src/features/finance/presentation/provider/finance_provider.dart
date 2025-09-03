import 'package:ecored_app/src/features/finance/data/models/model_finance.dart';
import 'package:flutter/material.dart';
import 'package:ecored_app/src/features/finance/domain/usecases/finance_services.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceServices services;

  bool isLoading = false;
  ModelFinance? financeData;
  String? errorMessage;

  FinanceProvider(this.services);

  Future<void> getWalletData(Map<String, dynamic> params) async {
    isLoading = true;
    // notifyListeners();

    try {
      financeData = await services.getWalletData(params);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      // notifyListeners();
    }
  }
}
