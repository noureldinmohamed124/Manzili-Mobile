import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  
  try {
    final res = await dio.get('https://manzili-app.runasp.net/seller/services?page=1&pageSize=20');
    print('Success /seller/services: ${res.statusCode}');
  } on DioException catch (e) {
    print('Error /seller/services: ${e.response?.statusCode}');
    print('Data: ${e.response?.data}');
  }
}
