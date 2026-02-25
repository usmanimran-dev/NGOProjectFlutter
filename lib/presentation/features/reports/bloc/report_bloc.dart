import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:demo/domain/entities/report_summary_entity.dart';
import 'package:demo/domain/repositories/report_repository.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class GetMonthlySummaryRequested extends ReportEvent {
  final int year;
  final int month;
  const GetMonthlySummaryRequested(this.year, this.month);
  @override
  List<Object?> get props => [year, month];
}

// States
abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}
class ReportLoading extends ReportState {}
class ReportLoaded extends ReportState {
  final ReportSummaryEntity summary;
  const ReportLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}
class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repository;

  ReportBloc({required this.repository}) : super(ReportInitial()) {
    on<GetMonthlySummaryRequested>(_onGetMonthlySummary);
  }

  Future<void> _onGetMonthlySummary(GetMonthlySummaryRequested event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await repository.getMonthlySummary(event.year, event.month);
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (summary) => emit(ReportLoaded(summary)),
    );
  }
}
