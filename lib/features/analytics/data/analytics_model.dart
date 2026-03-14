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

    return AnalyticsModel(
      income: (json["income"] ?? 0).toDouble(),
      expense: (json["expense"] ?? 0).toDouble(),
      balance: (json["balance"] ?? 0).toDouble(),

      monthly: (json["monthly"] as List)
          .map((e) => MonthlyData.fromJson(e))
          .toList(),

      categories: (json["categories"] as List)
          .map((e) => CategoryData.fromJson(e))
          .toList(),

      goals: (json["goals"] as List)
          .map((e) => GoalData.fromJson(e))
          .toList(),
    );
  }
}

class MonthlyData {

  final String month;
  final double income;
  final double expense;

  MonthlyData({
    required this.month,
    required this.income,
    required this.expense,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json["month"],
      income: (json["income"]).toDouble(),
      expense: (json["expense"]).toDouble(),
    );
  }
}

class CategoryData {

  final String name;
  final double amount;

  CategoryData({
    required this.name,
    required this.amount,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      name: json["name"],
      amount: (json["amount"]).toDouble(),
    );
  }
}

class GoalData {

  final String name;
  final double progress;

  GoalData({
    required this.name,
    required this.progress,
  });

  factory GoalData.fromJson(Map<String, dynamic> json) {
    return GoalData(
      name: json["name"],
      progress: (json["progress"]).toDouble(),
    );
  }
}