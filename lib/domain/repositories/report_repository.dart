import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/report_summary_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, ReportSummaryEntity>> getMonthlySummary(int year, int month);
}
