import 'package:equatable/equatable.dart';

class EntitlementEntity extends Equatable {
  final String id;
  final String assistanceCaseId;
  final String beneficiaryId;
  final String? beneficiaryName;
  final String? beneficiaryCnic;
  final String month;
  final double amount;
  final String? vendorId;
  final String? vendorName;
  final String status; // NOT_REDEEMED, REDEEMED, EXPIRED, BLOCKED
  final String? assistanceType;
  final DateTime? redeemedAt;

  const EntitlementEntity({
    required this.id,
    required this.assistanceCaseId,
    required this.beneficiaryId,
    this.beneficiaryName,
    this.beneficiaryCnic,
    required this.month,
    required this.amount,
    this.vendorId,
    this.vendorName,
    this.status = 'NOT_REDEEMED',
    this.assistanceType,
    this.redeemedAt,
  });

  factory EntitlementEntity.fromJson(Map<String, dynamic> json) {
    return EntitlementEntity(
      id: json['id'] ?? '',
      assistanceCaseId: json['assistance_case_id'] ?? '',
      beneficiaryId: json['beneficiary_id'] ?? '',
      beneficiaryName: json['beneficiary']?['full_name'],
      beneficiaryCnic: json['beneficiary']?['cnic'],
      month: json['month'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      vendorId: json['vendor_id'],
      vendorName: json['vendor']?['name'],
      status: json['status'] ?? 'NOT_REDEEMED',
      assistanceType: json['assistance_case']?['assistance_type'],
      redeemedAt: json['redeemed_at'] != null ? DateTime.tryParse(json['redeemed_at']) : null,
    );
  }

  @override
  List<Object?> get props => [id, month, status];
}
