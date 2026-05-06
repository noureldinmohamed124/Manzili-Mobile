import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  
  final res = await dio.get('https://manzili-app.runasp.net/api/categories');
  print('GET /api/categories: ${res.statusCode}');
  print('Data: ${res.data}');
}
