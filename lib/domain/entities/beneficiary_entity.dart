import 'package:equatable/equatable.dart';
import 'package:demo/domain/entities/assistance_case_entity.dart';

class BeneficiaryEntity extends Equatable {
  final String id;
  final String name;
  final String cnic;
  final String? fatherOrHusbandName;
  final String? mobile;
  final String? city;
  final String? area;
  final String? address;
  final String? photoUrl;
  final String? fingerprintData;
  final String status; // PENDING, VERIFIED, APPROVED, REJECTED, SUSPENDED, CLOSED
  final bool isVerified;
  final String? createdBy;
  final String? createdByName; // FK join: user.full_name
  final DateTime? createdAt;
  final List<AssistanceCaseEntity>? assistanceCases; // FK join: assistance_cases

  const BeneficiaryEntity({
    required this.id,
    required this.name,
    required this.cnic,
    this.fatherOrHusbandName,
    this.mobile,
    this.city,
    this.area,
    this.address,
    this.photoUrl,
    this.fingerprintData,
    this.status = 'PENDING',
    this.isVerified = false,
    this.createdBy,
    this.createdByName,
    this.createdAt,
    this.assistanceCases,
  });

  @override
  List<Object?> get props => [id, name, cnic, status];
}
