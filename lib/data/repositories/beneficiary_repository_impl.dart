import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:demo/core/error/failures.dart';
import 'package:demo/core/network/network_info.dart';
import 'package:demo/domain/entities/beneficiary_entity.dart';
import 'package:demo/domain/repositories/beneficiary_repository.dart';
import 'package:demo/data/datasources/remote_data_source.dart';

class BeneficiaryRepositoryImpl implements BeneficiaryRepository {
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BeneficiaryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, BeneficiaryEntity>> verifyCnic(String cnic) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.verifyCnic(cnic);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e is DioException ? (e.message ?? e.toString()) : e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, BeneficiaryEntity>> registerBeneficiary({
    required String name,
    required String cnic,
    required String photoPath,
    String? fingerprintData,
  }) async {
    // Logic for registration
     return const Left(ServerFailure('Not implemented yet'));
  }

  @override
  Future<Either<Failure, List<BeneficiaryEntity>>> getBeneficiariesByMonth(int year, int month, {String? status}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBeneficiaries(status: status ?? 'APPROVED');
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e is DioException ? (e.message ?? e.toString()) : e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, BeneficiaryEntity>> updateStatus(String id, String status, {Map<String, dynamic>? assistanceData}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.updateBeneficiaryStatus(id, status);
        if (status == 'APPROVED' && assistanceData != null) {
          assistanceData['beneficiary_id'] = id;
          await remoteDataSource.createAssistanceCase(assistanceData);
        }
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e is DioException ? (e.message ?? e.toString()) : e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
