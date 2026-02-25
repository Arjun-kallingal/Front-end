import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/analytics_model.dart';

class AnalyticsState {
  final String selectedFilter;
  final List<AnalyticsModel> transactions;

  AnalyticsState({
    required this.selectedFilter,
    required this.transactions,
  });

  AnalyticsState copyWith({
    String? selectedFilter,
    List<AnalyticsModel>? transactions,
  }) {
    return AnalyticsState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      transactions: transactions ?? this.transactions,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier()
      : super(
          AnalyticsState(
            selectedFilter: "All",
            transactions: [
              AnalyticsModel(
                  id: "1",
                  type: "cash",
                  amount: 2000,
                  date: DateTime.now()),
              AnalyticsModel(
                  id: "2",
                  type: "account",
                  amount: 5000,
                  date: DateTime.now()),
              AnalyticsModel(
                  id: "3",
                  type: "cash",
                  amount: 1500,
                  date: DateTime.now()),

            ],
          ),
        );

        double get totalIncome {
  return filteredTransactions
      .where((t) => t.amount > 0)
      .fold(0, (sum, item) => sum + item.amount);
}

double get totalExpense {
  return filteredTransactions
      .where((t) => t.amount < 0)
      .fold(0, (sum, item) => sum + item.amount.abs());
}

double get balance => totalIncome - totalExpense;

  List<AnalyticsModel> get filteredTransactions {
    if (state.selectedFilter == "All") {
      return state.transactions;
    } else if (state.selectedFilter == "Cash") {
      return state.transactions
          .where((t) => t.type == "cash")
          .toList();
    } else if (state.selectedFilter == "Account") {
      return state.transactions
          .where((t) => t.type == "account")
          .toList();
    }
    return state.transactions;
  }

  double get totalAmount {
    return filteredTransactions.fold(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  void changeFilter(String value) {
    state = state.copyWith(selectedFilter: value);
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>(
  (ref) => AnalyticsNotifier(),
);