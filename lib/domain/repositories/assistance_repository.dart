import 'package:dartz/dartz.dart';
import 'package:demo/domain/entities/assistance_entity.dart';
import 'package:demo/core/error/failures.dart';

abstract class AssistanceRepository {
  Future<Either<Failure, AssistanceEntity>> markAssistanceDelivered({
    required String beneficiaryId,
    required String vendorId,
    required String evidencePhotoPath,
  });
  Future<Either<Failure, void>> syncOfflineAssistance();
  Future<Either<Failure, List<AssistanceEntity>>> getDeliveryHistory();
}
