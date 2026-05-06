import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  
  // Try seller services
  try {
    // We need a token to test seller endpoints. Since we don't have it, we might get 401.
    // If we get 401, it means the route exists and expects auth!
    // If we get 404, it means the route doesn't exist.
    // If we get 400, it means validation error.
    final res = await dio.get('https://manzili-app.runasp.net/api/seller/services?page=1&pageSize=20');
    print('Seller Services Success: ${res.statusCode}');
  } on DioException catch (e) {
    print('Seller Services Error: ${e.response?.statusCode}');
    print('Data: ${e.response?.data}');
  }

  // Try admin block
  try {
    final res = await dio.post('https://manzili-app.runasp.net/api/admin/users/1/block', data: {
      'reason': 'test',
      'blockedUntil': DateTime.now().toIso8601String(),
    });
    print('Admin Block Success: ${res.statusCode}');
  } on DioException catch (e) {
    print('Admin Block Error: ${e.response?.statusCode}');
    print('Data: ${e.response?.data}');
  }
}
