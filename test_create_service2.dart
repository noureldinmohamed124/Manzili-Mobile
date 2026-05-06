import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(validateStatus: (s) => true));
  
  final res = await dio.post(
    'https://manzili-app.runasp.net/api/seller/services', 
    data: {
      'title': 'Test Service',
      'description': 'Test Description 1234567890 1234567890',
      'categoryId': 1,
      'basePrice': 100.0,
    },
  );
  
  print('Status: ${res.statusCode}');
  print('Data: ${res.data}');
}
