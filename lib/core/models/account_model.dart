class AccountModel {
  final String id;
  final String name;
  final String type;
  // FIX: Changed to String to prevent float precision loss
  final String availableBalance; 
  final String reservedBalance;
  final String totalBalance;
  final String currency;
  final bool isDefault;
  final String status;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.availableBalance,
    required this.reservedBalance,
    required this.totalBalance,
    required this.currency,
    required this.isDefault,
    required this.status,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'unknown_id',
      name: json['name'] ?? 'Unnamed Account',
      type: json['type'] ?? 'CASH',
      // FIX: Leave as String
      availableBalance: json['available']?.toString() ?? "0.00",
      reservedBalance: json['reserved']?.toString() ?? "0.00",
      totalBalance: json['total']?.toString() ?? "0.00",
      currency: json['currency'] ?? 'INR',
      isDefault: json['isDefault'] ?? false,
      status: json['status'] ?? 'ACTIVE',
    );
  }
}