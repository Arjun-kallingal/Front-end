class AccountModel {
  final String id;
  final String name;
  final String type;
  final double availableBalance;
  final double reservedBalance;
  final double totalBalance;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.availableBalance,
    required this.reservedBalance,
    required this.totalBalance,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      availableBalance:
          double.parse(json['availableBalance'] ?? "0"),
      reservedBalance:
          double.parse(json['reservedBalance'] ?? "0"),
      totalBalance:
          double.parse(json['totalBalance'] ?? "0"),
    );
  }
}