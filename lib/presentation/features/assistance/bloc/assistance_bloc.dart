import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:demo/domain/entities/assistance_entity.dart';
import 'package:demo/domain/repositories/assistance_repository.dart';

abstract class AssistanceState extends Equatable {
  const AssistanceState();
  @override
  List<Object?> get props => [];
}

class AssistanceInitial extends AssistanceState {}
class AssistanceLoading extends AssistanceState {}
class AssistanceSuccess extends AssistanceState {
  final AssistanceEntity assistance;
  const AssistanceSuccess(this.assistance);
  @override
  List<Object?> get props => [assistance];
}
class AssistanceError extends AssistanceState {
  final String message;
  const AssistanceError(this.message);
  @override
  List<Object?> get props => [message];
}

abstract class AssistanceEvent extends Equatable {
  const AssistanceEvent();
  @override
  List<Object?> get props => [];
}

class MarkDeliveredRequested extends AssistanceEvent {
  final String beneficiaryId;
  final String vendorId;
  final String evidencePhotoPath;
  const MarkDeliveredRequested({
    required this.beneficiaryId,
    required this.vendorId,
    required this.evidencePhotoPath,
  });
  @override
  List<Object?> get props => [beneficiaryId, vendorId, evidencePhotoPath];
}

class SyncOfflineDataRequested extends AssistanceEvent {}

class AssistanceBloc extends Bloc<AssistanceEvent, AssistanceState> {
  final AssistanceRepository repository;

  AssistanceBloc({required this.repository}) : super(AssistanceInitial()) {
    on<MarkDeliveredRequested>(_onMarkDelivered);
    on<SyncOfflineDataRequested>(_onSyncOfflineData);
  }

  Future<void> _onMarkDelivered(MarkDeliveredRequested event, Emitter<AssistanceState> emit) async {
    emit(AssistanceLoading());
    final result = await repository.markAssistanceDelivered(
      beneficiaryId: event.beneficiaryId,
      vendorId: event.vendorId,
      evidencePhotoPath: event.evidencePhotoPath,
    );
    result.fold(
      (failure) => emit(AssistanceError(failure.message)),
      (assistance) => emit(AssistanceSuccess(assistance)),
    );
  }

  Future<void> _onSyncOfflineData(SyncOfflineDataRequested event, Emitter<AssistanceState> emit) async {
    await repository.syncOfflineAssistance();
  }
}
