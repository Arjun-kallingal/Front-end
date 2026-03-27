class AnalyticsModel {
  final double income;
  final double expense;
  final double balance;
  final List<MonthlyData> monthly;
  final List<CategoryData> categories;
  final List<GoalData> goals;

  AnalyticsModel({
    required this.income,
    required this.expense,
    required this.balance,
    required this.monthly,
    required this.categories,
    required this.goals,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? {};
    final summary = data["summary"] ?? {};

    return AnalyticsModel(
      income: double.tryParse(summary["income"]?.toString() ?? "0") ?? 0.0,
      expense: double.tryParse(summary["expense"]?.toString() ?? "0") ?? 0.0,
      balance: double.tryParse(summary["net"]?.toString() ?? "0") ?? 0.0,
      monthly: (data["monthly"] as List?)
              ?.map((e) => MonthlyData.fromJson(e))
              .toList() ?? [],
      categories: (data["categorySpending"] as List?)
              ?.map((e) => CategoryData.fromJson(e))
              .toList() ?? [],
      goals: (data["goals"] as List?)
              ?.map((e) => GoalData.fromJson(e))
              .toList() ?? [],
    );
  }
}

class MonthlyData {
  final String month;
  final double income;
  final double expense;

  MonthlyData({required this.month, required this.income, required this.expense});

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json["month"] ?? "Unknown",
      income: double.tryParse(json["income"]?.toString() ?? "0") ?? 0.0,
      expense: double.tryParse(json["expense"]?.toString() ?? "0") ?? 0.0,
    );
  }
}

class CategoryData {
  final String name;
  final double amount;

  CategoryData({required this.name, required this.amount});

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      name: json["category"]?.toString() ?? "Unknown",
      amount: double.tryParse(json["amount"]?.toString() ?? "0") ?? 0.0,
    );
  }
}

class GoalData {
  final String name;
  final double progress;

  GoalData({required this.name, required this.progress});

  factory GoalData.fromJson(Map<String, dynamic> json) {
    return GoalData(
      name: json["name"]?.toString() ?? "Unknown",
      progress: double.tryParse(json["progress"]?.toString() ?? "0") ?? 0.0,
    );
  }
}