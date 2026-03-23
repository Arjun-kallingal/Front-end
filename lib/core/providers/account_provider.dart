import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {

  bool isLoading = true;

  List<AccountModel> cashAccounts = [];
  List<AccountModel> bankAccounts = [];
  AccountModel? defaultAccount;

  double totalCash = 0;
  double totalBank = 0;
  double totalAll = 0;

  Future<void> loadAccounts(String userId) async {

    isLoading = true;
    notifyListeners();

    try {

      final Map<String, dynamic> data =
          await AccountService.getAccountDashboard(userId);

      final List<AccountModel> all =
          (data['accounts'] as List<dynamic>?)?.cast<AccountModel>() ?? [];

      cashAccounts = all.where((a) => a.type == "CASH").toList();
      bankAccounts = all.where((a) => a.type == "BANK").toList();

      if (all.isNotEmpty) {
        defaultAccount =
            all.firstWhere((acc) => acc.isDefault, orElse: () => all.first);
      }

      totalCash =
          cashAccounts.fold(0, (sum, item) => sum + double.parse(item.totalBalance));

      totalBank =
          bankAccounts.fold(0, (sum, item) => sum + double.parse(item.totalBalance));

      totalAll = totalCash + totalBank;

    } catch (e) {
      debugPrint("AccountProvider error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> setPrimary(String accountId, String userId) async {

    final success = await AccountService.setPrimaryAccount(accountId);

    if (success) {
      await loadAccounts(userId);
    }
  }
}