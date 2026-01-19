class CafeTable {
  final int id;
  final String name;
  final String status; // 'Empty', 'Occupied', 'Full'
  final int chairCount;
  final int defaultChairCount;
  final int activeCount;
  final String? currentRule;
  final String? qrCode;
  final String? ruleCreatedBy;

  CafeTable({
    required this.id,
    required this.name,
    required this.status,
    required this.chairCount,
    required this.defaultChairCount,
    required this.activeCount,
    this.currentRule,
    this.qrCode,
    this.ruleCreatedBy,
  });

  factory CafeTable.fromJson(Map<String, dynamic> json) {
    return CafeTable(
      id: json['id'],
      name: json['name'] ?? 'Masa',
      status: json['status'] ?? 'Empty',
      chairCount: json['current_chair_count'] ?? 0,
      defaultChairCount: json['default_chair_count'],
      activeCount: json['active_count'] ?? 0,
      currentRule: json['current_rule'],
      qrCode: json['qr_code'],
      ruleCreatedBy: json['rule_created_by'],
    );
  }
}