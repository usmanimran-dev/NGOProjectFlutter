import 'package:equatable/equatable.dart';
import 'package:demo/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final DateTime timestamp;
  AuthError(this.message) : timestamp = DateTime.now();
  
  @override
  List<Object?> get props => [message, timestamp];
}
