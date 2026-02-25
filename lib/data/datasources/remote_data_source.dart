import 'package:dio/dio.dart';
import 'package:demo/data/models/user_model.dart';
import 'package:demo/data/models/beneficiary_model.dart';
import 'package:demo/data/models/assistance_model.dart';
import 'package:demo/domain/entities/assistance_entity.dart';
import 'package:demo/domain/entities/vendor_entity.dart';
import 'package:demo/domain/entities/entitlement_entity.dart';
import 'package:demo/domain/entities/assistance_case_entity.dart';
import 'package:demo/domain/entities/audit_log_entity.dart';

abstract class RemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<BeneficiaryModel> verifyCnic(String cnic);
  Future<List<BeneficiaryModel>> getBeneficiaries({int page = 1, int limit = 10, String? status});
  Future<BeneficiaryModel> getBeneficiaryById(String id);
  Future<BeneficiaryModel> createBeneficiary(Map<String, dynamic> data);
  Future<BeneficiaryModel> updateBeneficiaryStatus(String id, String status);
  Future<AssistanceModel> markDelivered(AssistanceModel assistance);
  // Vendor
  Future<List<VendorEntity>> getVendors();
  Future<VendorEntity> createVendor(Map<String, dynamic> data);
  // Assistance Cases
  Future<List<AssistanceCaseEntity>> getAssistanceCases({int page = 1, int limit = 20, String? status});
  Future<AssistanceCaseEntity> createAssistanceCase(Map<String, dynamic> data);
  Future<AssistanceCaseEntity> updateCaseStatus(String id, String action);
  // Entitlements
  Future<List<EntitlementEntity>> getEntitlements({int page = 1, int limit = 20, String? status, String? beneficiaryId});
  // Users
  Future<List<UserModel>> getUsers({int page = 1, int limit = 20, String? role, String? status});
  Future<UserModel> createUser(Map<String, dynamic> data);
  Future<UserModel> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);
  // Audit Logs
  Future<List<AuditLogEntity>> getAuditLogs({int page = 1, int limit = 30});
  // Reports
  Future<Map<String, dynamic>> getMonthlySummary(int year, int month);
  Future<Map<String, dynamic>> getVendorReport(String vendorId, String startDate, String endDate);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final Dio dio;

  RemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final userData = response.data['data'];
        final userModel = UserModel.fromJson(userData['user']);
        return userModel.copyWith(token: userData['token']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.data['message'],
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'Server error ${e.response?.statusCode}');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BeneficiaryModel> verifyCnic(String cnic) async {
    try {
      final response = await dio.get('/beneficiary/search/$cnic');
      if (response.data['success']) {
        return BeneficiaryModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.data['error'],
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BeneficiaryModel>> getBeneficiaries({int page = 1, int limit = 10, String? status}) async {
    try {
      final response = await dio.get('/beneficiary/list', queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      });

      if (response.data['success']) {
        final List data = response.data['data'];
        return data.map((json) => BeneficiaryModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.data['error'],
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BeneficiaryModel> getBeneficiaryById(String id) async {
    final response = await dio.get('/beneficiary/$id');
    if (response.data['success']) {
      return BeneficiaryModel.fromJson(response.data['data']);
    }
    throw DioException(requestOptions: response.requestOptions, error: response.data['error']);
  }

  @override
  Future<BeneficiaryModel> createBeneficiary(Map<String, dynamic> data) async {
    final response = await dio.post('/beneficiary/create', data: data);
    if (response.data['success']) {
      return BeneficiaryModel.fromJson(response.data['data']);
    }
    throw DioException(requestOptions: response.requestOptions, error: response.data['error']);
  }

  @override
  Future<BeneficiaryModel> updateBeneficiaryStatus(String id, String status) async {
    try {
      final response = await dio.put('/beneficiary/update/$id', data: {
        'status': status,
      });

      if (response.data['success']) {
        return BeneficiaryModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.data['error'],
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'Server error ${e.response?.statusCode}');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AssistanceModel> markDelivered(AssistanceModel assistance) async {
    try {
      final response = await dio.post('/vendor/redeem', data: {
        'entitlement_id': assistance.id,
        'device_id': 'mobile_app_001',
      });

      if (response.data['success']) {
        return assistance.copyWith(status: AssistanceStatus.delivered);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.data['error'],
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Vendors ──
  @override
  Future<List<VendorEntity>> getVendors() async {
    final response = await dio.get('/vendor/list');
    if (response.data['success']) {
      final List data = response.data['data'];
      return data.map((json) => VendorEntity.fromJson(json)).toList();
    }
    throw DioException(requestOptions: response.requestOptions, error: 'Failed to load vendors');
  }

  @override
  Future<VendorEntity> createVendor(Map<String, dynamic> data) async {
    final response = await dio.post('/vendor/create', data: data);
    if (response.data['success']) {
      return VendorEntity.fromJson(response.data['data']);
    }
    throw DioException(requestOptions: response.requestOptions, error: response.data['error']);
  }

  // ── Assistance Cases ──
  @override
  Future<List<AssistanceCaseEntity>> getAssistanceCases({int page = 1, int limit = 20, String? status}) async {
    final response = await dio.get('/assistance/list', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    if (response.data['success']) {
      final List data = response.data['data'];
      return data.map((json) => AssistanceCaseEntity.fromJson(json)).toList();
    }
    throw DioException(requestOptions: response.requestOptions, error: 'Failed to load cases');
  }

  @override
  Future<AssistanceCaseEntity> createAssistanceCase(Map<String, dynamic> data) async {
    final response = await dio.post('/assistance/approve', data: data);
    if (response.data['success']) {
      return AssistanceCaseEntity.fromJson(response.data['data']);
    }
    throw DioException(requestOptions: response.requestOptions, error: response.data['error']);
  }

  @override
  Future<AssistanceCaseEntity> updateCaseStatus(String id, String action) async {
    final response = await dio.put('/assistance/$action/$id');
    if (response.data['success']) {
      return AssistanceCaseEntity.fromJson(response.data['data']);
    }
    throw DioException(requestOptions: response.requestOptions, error: response.data['error']);
  }

  // ── Entitlements ──
  @override
  Future<List<EntitlementEntity>> getEntitlements({int page = 1, int limit = 20, String? status, String? beneficiaryId}) async {
    final response = await dio.get('/entitlement/list', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
    });
    if (response.data['success']) {
      final List data = response.data['data'];
      return data.map((json) => EntitlementEntity.fromJson(json)).toList();
    }
    throw DioException(requestOptions: response.requestOptions, error: 'Failed to load entitlements');
  }

  // ── Users ──
  @override
  Future<List<UserModel>> getUsers({int page = 1, int limit = 20, String? role, String? status}) async {
    final response = await dio.get('/users/all', queryParameters: {
      'page': page,
      'limit': limit,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
    });
    if (response.data['success']) {
      final List data = response.data['data'];
      return data.map((json) => UserModel.fromJson(json)).toList();
    }
    throw DioException(requestOptions: response.requestOptions, error: 'Failed to load users');
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    final response = await dio.post('/users/create', data: data);
    if (response.data['success']) {
      return UserModel.fromJson(response.data['data']);
    }
    throw DioException(requestOptions: response.requestOptions, error: response.data['message']);
  }

  @override
  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    final response = await dio.put('/users/update/$id', data: data);
    if (response.data['success']) {
      return UserModel.fromJson(response.data['data']);
    }
    throw DioException(requestOptions: response.requestOptions, error: response.data['message']);
  }

  @override
  Future<void> deleteUser(String id) async {
    final response = await dio.delete('/users/delete/$id');
    if (!response.data['success']) {
      throw DioException(requestOptions: response.requestOptions, error: response.data['message']);
    }
  }

  // ── Audit Logs ──
  @override
  Future<List<AuditLogEntity>> getAuditLogs({int page = 1, int limit = 30}) async {
    final response = await dio.get('/audit/logs', queryParameters: {
      'page': page,
      'limit': limit,
    });
    if (response.data['success']) {
      final List data = response.data['data'];
      return data.map((json) => AuditLogEntity.fromJson(json)).toList();
    }
    throw DioException(requestOptions: response.requestOptions, error: 'Failed to load audit logs');
  }

  // ── Reports ──
  @override
  Future<Map<String, dynamic>> getMonthlySummary(int year, int month) async {
    final response = await dio.get('/reports/monthly-summary', queryParameters: {
      'year': year,
      'month': month,
    });
    if (response.data['success']) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    throw DioException(requestOptions: response.requestOptions, error: 'Failed to load report');
  }

  @override
  Future<Map<String, dynamic>> getVendorReport(String vendorId, String startDate, String endDate) async {
    final response = await dio.get('/reports/vendor/$vendorId', queryParameters: {
      'startDate': startDate,
      'endDate': endDate,
    });
    if (response.data['success']) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    throw DioException(requestOptions: response.requestOptions, error: 'Failed to load report');
  }
}
