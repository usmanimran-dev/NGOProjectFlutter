import '../../domain/entities/report_summary_entity.dart';

class ReportSummaryModel extends ReportSummaryEntity {
  const ReportSummaryModel({
    required super.month,
    required super.totalBeneficiaries,
    required super.totalEntitlements,
    required super.totalRedeemed,
    required super.pendingRedemption,
    required super.totalAmount,
    required super.redeemedAmount,
    required super.pendingAmount,
    required super.redemptionRate,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      month: json['month'] ?? '',
      totalBeneficiaries: json['totalBeneficiaries'] ?? 0,
      totalEntitlements: json['totalEntitlements'] ?? 0,
      totalRedeemed: json['totalRedeemed'] ?? 0,
      pendingRedemption: json['pendingRedemption'] ?? 0,
      totalAmount: double.parse((json['totalAmount'] ?? '0').toString()),
      redeemedAmount: double.parse((json['redeemedAmount'] ?? '0').toString()),
      pendingAmount: double.parse((json['pendingAmount'] ?? '0').toString()),
      redemptionRate: json['redemptionRate'] ?? '0%',
    );
  }
}
