import 'package:hive/hive.dart';
import 'package:demo/domain/entities/beneficiary_entity.dart';
import 'package:demo/domain/entities/assistance_case_entity.dart';

class BeneficiaryModel extends BeneficiaryEntity {
  const BeneficiaryModel({
    required String id,
    required String name,
    required String cnic,
    String? fatherOrHusbandName,
    String? mobile,
    String? city,
    String? area,
    String? address,
    String? photoUrl,
    String? fingerprintData,
    String status = 'PENDING',
    bool isVerified = false,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    List<AssistanceCaseEntity>? assistanceCases,
  }) : super(
          id: id,
          name: name,
          cnic: cnic,
          fatherOrHusbandName: fatherOrHusbandName,
          mobile: mobile,
          city: city,
          area: area,
          address: address,
          photoUrl: photoUrl,
          fingerprintData: fingerprintData,
          status: status,
          isVerified: isVerified,
          createdBy: createdBy,
          createdByName: createdByName,
          createdAt: createdAt,
          assistanceCases: assistanceCases,
        );

  factory BeneficiaryModel.fromJson(Map<String, dynamic> json) {
    // Parse nested assistance_cases from FK join
    List<AssistanceCaseEntity>? cases;
    if (json['assistance_cases'] != null && json['assistance_cases'] is List) {
      cases = (json['assistance_cases'] as List)
          .map((c) => AssistanceCaseEntity.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    return BeneficiaryModel(
      id: json['id'] ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
      cnic: json['cnic'] ?? '',
      fatherOrHusbandName: json['father_or_husband_name'],
      mobile: json['mobile'],
      city: json['city'],
      area: json['area'],
      address: json['address'],
      photoUrl: json['photo_url'],
      fingerprintData: json['fingerprint_data'],
      status: json['status'] ?? 'PENDING',
      isVerified: json['status'] == 'APPROVED' || json['status'] == 'VERIFIED',
      createdBy: json['created_by'],
      createdByName: json['createdby']?['full_name'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      assistanceCases: cases,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'cnic': cnic,
      'father_or_husband_name': fatherOrHusbandName,
      'mobile': mobile,
      'city': city,
      'area': area,
      'address': address,
      'photo_url': photoUrl,
      'status': status,
    };
  }
}

// ── Manual Hive Adapter ──
class BeneficiaryModelAdapter extends TypeAdapter<BeneficiaryModel> {
  @override
  final int typeId = 1;

  @override
  BeneficiaryModel read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return BeneficiaryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cnic: map['cnic'] ?? '',
      fatherOrHusbandName: map['fatherOrHusbandName'],
      mobile: map['mobile'],
      city: map['city'],
      area: map['area'],
      address: map['address'],
      photoUrl: map['photoUrl'],
      fingerprintData: map['fingerprintData'],
      status: map['status'] ?? 'PENDING',
      isVerified: map['isVerified'] ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, BeneficiaryModel obj) {
    writer.writeMap({
      'id': obj.id,
      'name': obj.name,
      'cnic': obj.cnic,
      'fatherOrHusbandName': obj.fatherOrHusbandName,
      'mobile': obj.mobile,
      'city': obj.city,
      'area': obj.area,
      'address': obj.address,
      'photoUrl': obj.photoUrl,
      'fingerprintData': obj.fingerprintData,
      'status': obj.status,
      'isVerified': obj.isVerified,
    });
  }
}
