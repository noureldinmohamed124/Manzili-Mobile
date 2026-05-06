import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(validateStatus: (s) => true));
  
  // Test methods for Admin Block
  final resPost = await dio.post('https://manzili-app.runasp.net/api/admin/users/1/block');
  print('POST /block: ${resPost.statusCode}');
  
  final resPut = await dio.put('https://manzili-app.runasp.net/api/admin/users/1/block');
  print('PUT /block: ${resPut.statusCode}');
  
  final resPatch = await dio.patch('https://manzili-app.runasp.net/api/admin/users/1/block');
  print('PATCH /block: ${resPatch.statusCode}');

  final resGet = await dio.get('https://manzili-app.runasp.net/api/admin/users/1/block');
  print('GET /block: ${resGet.statusCode}');

  // Test unblock
  final resUnblockPost = await dio.post('https://manzili-app.runasp.net/api/admin/users/1/unblock');
  print('POST /unblock: ${resUnblockPost.statusCode}');

  final resUnblockPut = await dio.put('https://manzili-app.runasp.net/api/admin/users/1/unblock');
  print('PUT /unblock: ${resUnblockPut.statusCode}');
}
