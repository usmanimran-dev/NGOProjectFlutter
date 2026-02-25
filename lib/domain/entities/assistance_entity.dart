import 'package:equatable/equatable.dart';

enum AssistanceStatus {
  pending,
  delivered,
  failed,
}

class AssistanceEntity extends Equatable {
  final String id;
  final String beneficiaryId;
  final String vendorId;
  final DateTime deliveryTimestamp;
  final String deliveryEvidenceUrl;
  final bool isSynced;
  final AssistanceStatus status;

  const AssistanceEntity({
    required this.id,
    required this.beneficiaryId,
    required this.vendorId,
    required this.deliveryTimestamp,
    required this.deliveryEvidenceUrl,
    this.isSynced = false,
    this.status = AssistanceStatus.pending,
  });

  @override
  List<Object?> get props => [id, beneficiaryId, vendorId, deliveryTimestamp, deliveryEvidenceUrl, isSynced, status];
}
