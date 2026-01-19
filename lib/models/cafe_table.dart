class CafeTable {
  final int id;
  final int tableNumber;
  final String status; // 'Empty', 'Occupied', 'Full'
  final int currentChairCount;
  final int defaultChairCount;
  final int activeCount;
  final String? currentRule;
  final String? qrCode;
  final String? ruleCreatedBy;

  CafeTable({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.currentChairCount,
    required this.defaultChairCount,
    required this.activeCount,
    this.currentRule,
    this.qrCode,
    this.ruleCreatedBy,
  });

  factory CafeTable.fromJson(Map<String, dynamic> json) {
    return CafeTable(
      id: json['id'],
      tableNumber: json['table_number'],
      status: json['status'] ?? 'Empty',
      currentChairCount: json['current_chair_count'] ?? 0,
      defaultChairCount: json['default_chair_count'],
      activeCount: json['active_count'] ?? 0,
      currentRule: json['current_rule'],
      qrCode: json['qr_code'],
      ruleCreatedBy: json['rule_created_by'],
    );
  }
}