class ServiceItem {
  ServiceItem({
    required this.id,
    required this.title,
    required this.providerName,
    required this.basePrice,
    required this.rating,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String providerName;
  final num basePrice;
  final num rating;
  final String imageUrl;

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as int,
      title: json['title'] as String,
      providerName: json['providerName'] as String,
      basePrice: json['basePrice'] as num,
      rating: json['rating'] as num,
      imageUrl: json['imageUrl'] as String,
    );
  }
}

class PaginatedServicesResponse {
  PaginatedServicesResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<ServiceItem> items;
  final int page;
  final int pageSize;
  final int totalPages;

  factory PaginatedServicesResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return PaginatedServicesResponse(
      items: itemsJson
          .map((item) => ServiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

