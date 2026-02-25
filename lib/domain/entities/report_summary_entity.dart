import 'package:equatable/equatable.dart';

class ReportSummaryEntity extends Equatable {
  final String month;
  final int totalBeneficiaries;
  final int totalEntitlements;
  final int totalRedeemed;
  final int pendingRedemption;
  final double totalAmount;
  final double redeemedAmount;
  final double pendingAmount;
  final String redemptionRate;

  const ReportSummaryEntity({
    required this.month,
    required this.totalBeneficiaries,
    required this.totalEntitlements,
    required this.totalRedeemed,
    required this.pendingRedemption,
    required this.totalAmount,
    required this.redeemedAmount,
    required this.pendingAmount,
    required this.redemptionRate,
  });

  @override
  List<Object?> get props => [
        month,
        totalBeneficiaries,
        totalEntitlements,
        totalRedeemed,
        pendingRedemption,
        totalAmount,
        redeemedAmount,
        pendingAmount,
        redemptionRate,
      ];
}
