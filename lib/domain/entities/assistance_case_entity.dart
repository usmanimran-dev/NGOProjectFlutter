import 'package:equatable/equatable.dart';

class AssistanceCaseEntity extends Equatable {
  final String id;
  final String beneficiaryId;
  final String? beneficiaryName;
  final String? beneficiaryCnic;
  final String assistanceType; // RATION, RENT, MEDICAL, EMERGENCY
  final double monthlyAmount;
  final String? vendorId;
  final String? vendorName;
  final String status; // ACTIVE, PAUSED, CLOSED
  final int? durationMonths;
  final String? approvalNotes;
  final String? approvedBy;
  final DateTime? startMonth;
  final DateTime? endMonth;
  final DateTime? createdAt;

  const AssistanceCaseEntity({
    required this.id,
    required this.beneficiaryId,
    this.beneficiaryName,
    this.beneficiaryCnic,
    required this.assistanceType,
    required this.monthlyAmount,
    this.vendorId,
    this.vendorName,
    this.status = 'ACTIVE',
    this.durationMonths,
    this.approvalNotes,
    this.approvedBy,
    this.startMonth,
    this.endMonth,
    this.createdAt,
  });

  factory AssistanceCaseEntity.fromJson(Map<String, dynamic> json) {
    return AssistanceCaseEntity(
      id: json['id'] ?? '',
      beneficiaryId: json['beneficiary_id'] ?? '',
      beneficiaryName: json['beneficiary']?['full_name'],
      beneficiaryCnic: json['beneficiary']?['cnic'],
      assistanceType: json['assistance_type'] ?? '',
      monthlyAmount: double.tryParse(json['monthly_amount']?.toString() ?? '0') ?? 0,
      vendorId: json['vendor_id'],
      vendorName: json['vendor']?['name'],
      status: json['status'] ?? 'ACTIVE',
      durationMonths: json['duration_months'],
      approvalNotes: json['approval_notes'],
      approvedBy: json['approved_by'],
      startMonth: json['start_month'] != null ? DateTime.tryParse(json['start_month']) : null,
      endMonth: json['end_month'] != null ? DateTime.tryParse(json['end_month']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [id, assistanceType, status];
}
