import 'package:hive/hive.dart';
import 'package:demo/domain/entities/assistance_entity.dart';

class AssistanceModel extends AssistanceEntity {
  const AssistanceModel({
    required String id,
    required String beneficiaryId,
    required String vendorId,
    required DateTime deliveryTimestamp,
    required String deliveryEvidenceUrl,
    bool isSynced = false,
    AssistanceStatus status = AssistanceStatus.pending,
  }) : super(
          id: id,
          beneficiaryId: beneficiaryId,
          vendorId: vendorId,
          deliveryTimestamp: deliveryTimestamp,
          deliveryEvidenceUrl: deliveryEvidenceUrl,
          isSynced: isSynced,
          status: status,
        );

  AssistanceModel copyWith({
    String? id,
    String? beneficiaryId,
    String? vendorId,
    DateTime? deliveryTimestamp,
    String? deliveryEvidenceUrl,
    bool? isSynced,
    AssistanceStatus? status,
  }) {
    return AssistanceModel(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      vendorId: vendorId ?? this.vendorId,
      deliveryTimestamp: deliveryTimestamp ?? this.deliveryTimestamp,
      deliveryEvidenceUrl: deliveryEvidenceUrl ?? this.deliveryEvidenceUrl,
      isSynced: isSynced ?? this.isSynced,
      status: status ?? this.status,
    );
  }

  factory AssistanceModel.fromJson(Map<String, dynamic> json) {
    return AssistanceModel(
      id: json['id'] ?? '',
      beneficiaryId: json['beneficiary_id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      deliveryTimestamp: DateTime.parse(json['delivery_timestamp'] ?? DateTime.now().toIso8601String()),
      deliveryEvidenceUrl: json['delivery_evidence_url'] ?? '',
      isSynced: json['is_synced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'beneficiary_id': beneficiaryId,
      'vendor_id': vendorId,
      'delivery_timestamp': deliveryTimestamp.toIso8601String(),
      'delivery_evidence_url': deliveryEvidenceUrl,
      'is_synced': isSynced,
    };
  }
}

// ── Manual Hive Adapter ──
class AssistanceModelAdapter extends TypeAdapter<AssistanceModel> {
  @override
  final int typeId = 2;

  @override
  AssistanceModel read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return AssistanceModel(
      id: map['id'] ?? '',
      beneficiaryId: map['beneficiaryId'] ?? '',
      vendorId: map['vendorId'] ?? '',
      deliveryTimestamp: DateTime.tryParse(map['deliveryTimestamp'] ?? '') ?? DateTime.now(),
      deliveryEvidenceUrl: map['deliveryEvidenceUrl'] ?? '',
      isSynced: map['isSynced'] ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AssistanceModel obj) {
    writer.writeMap({
      'id': obj.id,
      'beneficiaryId': obj.beneficiaryId,
      'vendorId': obj.vendorId,
      'deliveryTimestamp': obj.deliveryTimestamp.toIso8601String(),
      'deliveryEvidenceUrl': obj.deliveryEvidenceUrl,
      'isSynced': obj.isSynced,
    });
  }
}
