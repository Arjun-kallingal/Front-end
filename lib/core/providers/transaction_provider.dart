import 'package:flutter/material.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {

  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<TransactionModel> get transactions => _recentTransactions;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  Future<void> fetchTransactions(String userId) async {

    try {

      _isLoading = true;
      notifyListeners();

      final response = await TransactionService.getHistory(userId);

      _recentTransactions = response.transactions;

      _errorMessage = null;

    } catch (e) {

      _errorMessage = "Failed to load transactions";

    }

    _isLoading = false;

    notifyListeners();
  }
}