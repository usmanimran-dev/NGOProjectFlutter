import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:demo/core/error/failures.dart';
import 'package:demo/core/network/network_info.dart';
import 'package:demo/domain/entities/report_summary_entity.dart';
import 'package:demo/domain/repositories/report_repository.dart';
import 'package:demo/data/models/report_summary_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final Dio dio;
  final NetworkInfo networkInfo;

  ReportRepositoryImpl({
    required this.dio,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ReportSummaryEntity>> getMonthlySummary(int year, int month) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await dio.get(
          '/reports/monthly-summary',
          queryParameters: {'year': year, 'month': month},
        );

        if (response.data['success']) {
          return Right(ReportSummaryModel.fromJson(response.data['data']));
        } else {
          return Left(ServerFailure(response.data['error'] ?? 'Server error'));
        }
      } catch (e) {
        return const Left(ServerFailure('Connection failed'));
      }
    } else {
      return const Left(CacheFailure('No internet connection'));
    }
  }
}
