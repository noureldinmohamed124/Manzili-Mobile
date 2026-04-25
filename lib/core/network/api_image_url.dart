import 'package:manzili_mobile/core/network/api_constants.dart';

/// Turns API fields like `cakes_1.jpg` into `https://host/.../cakes_1.jpg`.
/// Returns `null` if [raw] is empty.
String? resolveServiceImageUrl(String? raw) {
  if (raw == null) return null;
  final s = raw.trim().replaceAll('\\', '/');
  if (s.isEmpty) return null;
  
  if (s.startsWith('http://') || s.startsWith('https://')) {
    // print('API Image resolved (absolute): $s');
    return s;
  }
  
  final base = ApiConstants.baseUrl;
  final normalized = base.endsWith('/') ? base : '$base/';
  var path = s.startsWith('/') ? s.substring(1) : s;
  
  // If the path already has a folder, don't prepend serviceImageFolder
  // e.g. 'uploads/cakes.png' -> don't append 'images/'
  final folder = ApiConstants.serviceImageFolder.trim();
  if (folder.isNotEmpty && !path.contains('/')) {
    final f = folder.endsWith('/') ? folder : '$folder/';
    path = '$f$path';
  }
  
  final finalUrl = Uri.encodeFull('$normalized$path');
  // print('API Image resolved (relative): $finalUrl');
  return finalUrl;
}
