import 'package:dartz/dartz.dart';
import 'package:demo/core/error/failures.dart';
import 'package:demo/core/network/network_info.dart';
import 'package:demo/domain/entities/assistance_entity.dart';
import 'package:demo/domain/repositories/assistance_repository.dart';
import 'package:demo/data/datasources/local_data_source.dart';
import 'package:demo/data/datasources/remote_data_source.dart';
import 'package:demo/data/models/assistance_model.dart';

class AssistanceRepositoryImpl implements AssistanceRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AssistanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AssistanceEntity>> markAssistanceDelivered({
    required String beneficiaryId,
    required String vendorId,
    required String evidencePhotoPath,
  }) async {
    final assistance = AssistanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      beneficiaryId: beneficiaryId,
      vendorId: vendorId,
      deliveryTimestamp: DateTime.now(),
      deliveryEvidenceUrl: evidencePhotoPath,
      isSynced: false,
    );

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.markDelivered(assistance);
        return Right(result);
      } catch (e) {
        await localDataSource.cacheOfflineAssistance(assistance);
        return Right(assistance);
      }
    } else {
      await localDataSource.cacheOfflineAssistance(assistance);
      return Right(assistance);
    }
  }

  @override
  Future<Either<Failure, void>> syncOfflineAssistance() async {
    if (await networkInfo.isConnected) {
      try {
        final offlineData = await localDataSource.getOfflineAssistance();
        for (var item in offlineData) {
          await remoteDataSource.markDelivered(item);
        }
        await localDataSource.clearOfflineAssistance();
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, List<AssistanceEntity>>> getDeliveryHistory() async {
     return const Left(ServerFailure('Not implemented yet'));
  }
}
