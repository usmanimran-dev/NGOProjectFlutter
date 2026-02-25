import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:demo/core/error/failures.dart';
import 'package:demo/core/network/network_info.dart';
import 'package:demo/domain/entities/user_entity.dart';
import 'package:demo/domain/repositories/auth_repository.dart';
import 'package:demo/data/datasources/local_data_source.dart';
import 'package:demo/data/datasources/remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      // Prioritize remote login attempt, as networkInfo can be unreliable on web
      final remoteUser = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on DioException catch (e) {
      // Handle Dio-specific network errors
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.error.toString().contains('SocketException')) {
        return const Left(NetworkFailure(
            'Cannot connect to server. Please check:\n'
            '1. Backend server is running on port 3000\n'
            '2. Your device/emulator can reach the server\n'
            '3. For Android emulator, use 10.0.2.2\n'
            '4. For real device, use your computer\'s IP address'));
      }
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 
                        e.response?.data['error'] ?? 
                        'Server error: ${e.response?.statusCode}';
        return Left(ServerFailure(message));
      }
      return Left(ServerFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getAuthenticatedUser() async {
    try {
      final user = await localDataSource.getLastUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
