import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(validateStatus: (s) => true));
  
  // Try sending data in GET request body
  final res = await dio.get('https://manzili-app.runasp.net/api/seller/services', data: {
    'page': 1,
    'pageSize': 20,
  });
  
  print('GET with body status: ${res.statusCode}');
  print('Data: ${res.data}');
}
