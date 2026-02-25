import 'package:flutter_bloc/flutter_bloc.dart';
// Consolidated BLoC
import '../../../../domain/repositories/beneficiary_repository.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/beneficiary_entity.dart';

// RE-DEFINING HERE FOR CLARITY IN THE TOOL CALL
abstract class BeneficiaryState extends Equatable {
  const BeneficiaryState();
  @override
  List<Object?> get props => [];
}

class BeneficiaryInitial extends BeneficiaryState {}
class BeneficiaryLoading extends BeneficiaryState {}
class BeneficiaryLoaded extends BeneficiaryState {
  final List<BeneficiaryEntity> beneficiaries;
  const BeneficiaryLoaded(this.beneficiaries);
  @override
  List<Object?> get props => [beneficiaries];
}
class BeneficiaryVerified extends BeneficiaryState {
  final BeneficiaryEntity beneficiary;
  const BeneficiaryVerified(this.beneficiary);
  @override
  List<Object?> get props => [beneficiary];
}
class BeneficiaryStatusUpdated extends BeneficiaryState {
  final BeneficiaryEntity beneficiary;
  const BeneficiaryStatusUpdated(this.beneficiary);
  @override
  List<Object?> get props => [beneficiary];
}

class BeneficiaryError extends BeneficiaryState {
  final String message;
  const BeneficiaryError(this.message);
  @override
  List<Object?> get props => [message];
}

abstract class BeneficiaryEvent extends Equatable {
  const BeneficiaryEvent();
  @override
  List<Object?> get props => [];
}

class VerifyCnicRequested extends BeneficiaryEvent {
  final String cnic;
  const VerifyCnicRequested(this.cnic);
  @override
  List<Object?> get props => [cnic];
}

class LoadBeneficiariesRequested extends BeneficiaryEvent {
  final int year;
  final int month;
  const LoadBeneficiariesRequested(this.year, this.month);
  @override
  List<Object?> get props => [year, month];
}

class LoadPendingBeneficiariesRequested extends BeneficiaryEvent {}

class UpdateBeneficiaryStatusRequested extends BeneficiaryEvent {
  final String id;
  final String status;
  final Map<String, dynamic>? assistanceData;
  const UpdateBeneficiaryStatusRequested(this.id, this.status, {this.assistanceData});
  @override
  List<Object?> get props => [id, status, assistanceData];
}

class BeneficiaryBloc extends Bloc<BeneficiaryEvent, BeneficiaryState> {
  final BeneficiaryRepository repository;

  BeneficiaryBloc({required this.repository}) : super(BeneficiaryInitial()) {
    on<VerifyCnicRequested>(_onVerifyCnic);
    on<LoadBeneficiariesRequested>(_onLoadBeneficiaries);
    on<LoadPendingBeneficiariesRequested>(_onLoadPending);
    on<UpdateBeneficiaryStatusRequested>(_onUpdateStatus);
  }

  Future<void> _onVerifyCnic(VerifyCnicRequested event, Emitter<BeneficiaryState> emit) async {
    emit(BeneficiaryLoading());
    final result = await repository.verifyCnic(event.cnic);
    result.fold(
      (failure) => emit(BeneficiaryError(failure.message)),
      (beneficiary) => emit(BeneficiaryVerified(beneficiary)),
    );
  }

  Future<void> _onLoadBeneficiaries(LoadBeneficiariesRequested event, Emitter<BeneficiaryState> emit) async {
    emit(BeneficiaryLoading());
    final result = await repository.getBeneficiariesByMonth(event.year, event.month);
    result.fold(
      (failure) => emit(BeneficiaryError(failure.message)),
      (list) => emit(BeneficiaryLoaded(list)),
    );
  }

  Future<void> _onLoadPending(LoadPendingBeneficiariesRequested event, Emitter<BeneficiaryState> emit) async {
    emit(BeneficiaryLoading());
    // Directly using updateStatus logic but we need list logic for pending
    // I'll adjust the repository implementation to handle status filtering in getBeneficiariesByMonth or add a specialized method
    // For now, I'll use the ACTIVE status logic I just wrote but intent is 'PENDING'
    final result = await repository.getBeneficiariesByMonth(
      DateTime.now().year, 
      DateTime.now().month, 
      status: 'PENDING',
    );
    result.fold(
      (failure) => emit(BeneficiaryError(failure.message)),
      (list) => emit(BeneficiaryLoaded(list)),
    );
  }

  Future<void> _onUpdateStatus(UpdateBeneficiaryStatusRequested event, Emitter<BeneficiaryState> emit) async {
    emit(BeneficiaryLoading());
    final result = await repository.updateStatus(event.id, event.status, assistanceData: event.assistanceData);
    result.fold(
      (failure) => emit(BeneficiaryError(failure.message)),
      (beneficiary) => emit(BeneficiaryStatusUpdated(beneficiary)),
    );
  }
}
