import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  
  try {
    final res = await dio.get('https://manzili-app.runasp.net/api/seller/orders?page=1&pageSize=20');
    print('Success /api/seller/orders: ${res.statusCode}');
  } on DioException catch (e) {
    print('Error /api/seller/orders: ${e.response?.statusCode}');
    print('Data: ${e.response?.data}');
  }
}
