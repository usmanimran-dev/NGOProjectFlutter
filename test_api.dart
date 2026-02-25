import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final loginRes = await dio.post('http://localhost:3000/api/auth/login', 
      data: {'email': 'admin@ngo.com', 'password': 'admin123'});
    final token = loginRes.data['data']['token'];
    
    // Test list
    try {
      final res = await dio.get('http://localhost:3000/api/beneficiary/list?status=PENDING', 
        options: Options(headers: {'Authorization': 'Bearer $token'}));
      print('GET /list PENDING OK: ${res.statusCode}');
    } on DioException catch(e) {
      print('GET /list PENDING ERROR 400: ${e.response?.data}');
    }

    // Attempt to test approval on a dummy ID to see if it gives 400
    try {
      final res2 = await dio.put('http://localhost:3000/api/beneficiary/update/TEST-ID-123', 
        data: {'status': 'APPROVED'},
        options: Options(headers: {'Authorization': 'Bearer $token'}));
      print('PUT /update APPROVED OK: ${res2.statusCode}');
    } on DioException catch(e) {
      print('PUT /update ERROR: ${e.response?.statusCode} ${e.response?.data}');
    }

  } catch(e) {
    print('FATAL ERROR: $e');
  }
}
