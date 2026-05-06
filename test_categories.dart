import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  
  try {
    final res = await dio.get('https://manzili-app.runasp.net/categories');
    print('GET /categories: ${res.statusCode}');
  } on DioException catch (e) {
    print('GET /categories Error: ${e.response?.statusCode}');
  }
  
  try {
    final res = await dio.get('https://manzili-app.runasp.net/api/categories');
    print('GET /api/categories: ${res.statusCode}');
  } on DioException catch (e) {
    print('GET /api/categories Error: ${e.response?.statusCode}');
  }
}
