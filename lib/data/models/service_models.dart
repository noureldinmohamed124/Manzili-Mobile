class ServiceItem {
  ServiceItem({
    required this.id,
    required this.title,
    required this.providerName,
    required this.basePrice,
    required this.rating,
    required this.imageUrl,
    this.serviceDescription,
    this.address,
    this.provider,
    this.options,
    this.images,
  });

  final int id;
  final String title;
  final String providerName;
  final num basePrice;
  final num rating;
  final String imageUrl;
  final String? serviceDescription;
  final String? address;
  final ServiceProvider? provider;
  final List<ServiceOption>? options;
  final List<ServiceImage>? images;

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    // Handle both list item shape and detailed shape
    final providerName = json['providerName'] as String? ??
        (json['provider'] is Map
            ? (json['provider'] as Map<String, dynamic>)['fullName'] as String?
            : null) ??
        '';

    return ServiceItem(
      id: json['id'] as int,
      title: json['title'] as String,
      providerName: providerName,
      basePrice: json['basePrice'] as num? ?? 0,
      rating: json['rating'] as num? ??
          (json['provider'] is Map
              ? (json['provider'] as Map<String, dynamic>)['rating'] as num?
              : null) ??
          0,
      imageUrl: json['imageUrl'] as String? ?? '',
      serviceDescription: json['serviceDescription'] as String?,
      address: json['address'] as String?,
      provider: json['provider'] is Map
          ? ServiceProvider.fromJson(json['provider'] as Map<String, dynamic>)
          : null,
      options: json['options'] is List
          ? (json['options'] as List<dynamic>)
              .map((e) => ServiceOption.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      images: json['images'] is List
          ? (json['images'] as List<dynamic>)
              .map((e) => ServiceImage.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class ServiceProvider {
  ServiceProvider({
    required this.id,
    required this.fullName,
    required this.rating,
    required this.reviewsNo,
  });

  final int id;
  final String fullName;
  final num rating;
  final int reviewsNo;

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      rating: json['rating'] as num,
      reviewsNo: json['reviewsNo'] as int? ?? 0,
    );
  }
}

class ServiceOption {
  ServiceOption({
    required this.id,
    required this.serviceOptionName,
    required this.price,
  });

  final int id;
  final String serviceOptionName;
  final num price;

  factory ServiceOption.fromJson(Map<String, dynamic> json) {
    return ServiceOption(
      id: json['id'] as int,
      serviceOptionName: json['serviceOptionName'] as String,
      price: json['price'] as num,
    );
  }
}

class ServiceImage {
  ServiceImage({
    required this.id,
    required this.imageUrl,
  });

  final int id;
  final String imageUrl;

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      id: json['id'] as int,
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
    // Support both direct shape { items, page, pageSize, totalPages }
    // and wrapped shape { data: { items, page, pageSize, totalPages }, success, message }
    final Map<String, dynamic> root;
    if (json.containsKey('items') && json['items'] is List) {
      root = json;
    } else if (json['data'] is Map<String, dynamic>) {
      root = json['data'] as Map<String, dynamic>;
    } else {
      root = json;
    }

    final itemsJson = root['items'] as List<dynamic>? ?? [];
    return PaginatedServicesResponse(
      items: itemsJson
          .map((item) => ServiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: root['page'] as int? ?? 1,
      pageSize: root['pageSize'] as int? ?? itemsJson.length,
      totalPages: root['totalPages'] as int? ?? 1,
    );
  }
}

