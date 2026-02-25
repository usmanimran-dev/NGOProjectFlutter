import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:demo/core/network/network_info.dart';
import 'package:demo/data/datasources/local_data_source.dart';
import 'package:demo/data/datasources/remote_data_source.dart';
import 'package:demo/data/repositories/auth_repository_impl.dart';
import 'package:demo/data/repositories/beneficiary_repository_impl.dart';
import 'package:demo/data/repositories/assistance_repository_impl.dart';
import 'package:demo/data/repositories/report_repository_impl.dart';
import 'package:demo/domain/repositories/auth_repository.dart';
import 'package:demo/domain/repositories/beneficiary_repository.dart';
import 'package:demo/domain/repositories/assistance_repository.dart';
import 'package:demo/domain/repositories/report_repository.dart';
import 'package:demo/domain/entities/user_entity.dart';
import 'package:demo/domain/entities/beneficiary_entity.dart';
import 'package:demo/domain/entities/assistance_case_entity.dart';
import 'package:demo/domain/entities/entitlement_entity.dart';
import 'package:demo/data/models/user_model.dart';
import 'package:demo/data/models/assistance_model.dart';
import 'package:demo/data/models/beneficiary_model.dart';
import 'package:demo/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:demo/presentation/features/beneficiary/bloc/beneficiary_bloc.dart';
import 'package:demo/presentation/features/assistance/bloc/assistance_bloc.dart';
import 'package:demo/presentation/features/reports/bloc/report_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(BeneficiaryModelAdapter());
  Hive.registerAdapter(AssistanceModelAdapter());
  
  final userBox = await Hive.openBox<UserModel>('userBox');
  final assistanceBox = await Hive.openBox<AssistanceModel>('assistanceBox');
  final beneficiaryBox = await Hive.openBox<BeneficiaryModel>('beneficiaryBox');

  // Configure Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://ngobackend.virtuohr.com/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add Auth + Debug + 401-Logout Interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        debugPrint('[DIO] REQUEST: ${options.method} ${options.uri}');
        // Do not add token for login
        if (!options.path.contains('auth/login')) {
          try {
            final localDataSource = sl<LocalDataSource>();
            final user = await localDataSource.getLastUser();
            if (user?.token != null) {
              options.headers['Authorization'] = 'Bearer ${user!.token}';
            }
          } catch (_) {}
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[DIO] RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        debugPrint('[DIO] ERROR: ${error.type} ${error.requestOptions.uri}');
        debugPrint('[DIO] RAW: ${error.message}');

        // Auto-logout on 401 (expired/invalid token)
        if (error.response?.statusCode == 401 &&
            !error.requestOptions.path.contains('auth/login')) {
          debugPrint('[DIO] 401 detected — clearing local session');
          try {
            final localDataSource = sl<LocalDataSource>();
            await localDataSource.clearUser();
          } catch (_) {}
        }

        // Extract clear server message
        String? cleanMessage;
        if (error.response?.data != null && error.response?.data is Map) {
          cleanMessage = error.response?.data['message'] ?? error.response?.data['error'];
        }
        
        if (cleanMessage != null && cleanMessage.isNotEmpty) {
          debugPrint('[DIO] CLEAN ERROR: $cleanMessage');
          final newError = DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: error.error,
            message: cleanMessage,
          );
          return handler.next(newError);
        }

        return handler.next(error);
      },
    ),
  );

  sl.registerLazySingleton(() => dio);
  sl.registerLazySingleton(() => Connectivity());

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! Data Sources
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(userBox: userBox, assistanceBox: assistanceBox),
  );

  //! Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<BeneficiaryRepository>(
    () => BeneficiaryRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<AssistanceRepository>(
    () => AssistanceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      dio: sl(),
      networkInfo: sl(),
    ),
  );

  //! BLoCs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => BeneficiaryBloc(repository: sl()));
  sl.registerFactory(() => AssistanceBloc(repository: sl()));
  sl.registerFactory(() => ReportBloc(repository: sl()));
}
