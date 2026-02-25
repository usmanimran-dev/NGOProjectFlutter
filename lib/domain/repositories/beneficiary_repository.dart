import 'package:dartz/dartz.dart';
import 'package:demo/domain/entities/beneficiary_entity.dart';
import 'package:demo/core/error/failures.dart';

abstract class BeneficiaryRepository {
  Future<Either<Failure, BeneficiaryEntity>> verifyCnic(String cnic);
  Future<Either<Failure, BeneficiaryEntity>> registerBeneficiary({
    required String name,
    required String cnic,
    required String photoPath,
    String? fingerprintData,
  });
  Future<Either<Failure, List<BeneficiaryEntity>>> getBeneficiariesByMonth(int year, int month, {String? status});
  Future<Either<Failure, BeneficiaryEntity>> updateStatus(String id, String status, {Map<String, dynamic>? assistanceData});
}
