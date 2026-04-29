class SellerServicesListResponse {
  SellerServicesListResponse({
    required this.items,
  });

  final List<SellerServiceListItem> items;

  factory SellerServicesListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['Items'] ?? json['items'] ?? [];
    if (rawItems is! List) return SellerServicesListResponse(items: const []);
    return SellerServicesListResponse(
      items: rawItems
          .whereType<Map>()
          .map((e) => SellerServiceListItem.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class SellerServiceListItem {
  SellerServiceListItem({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.rating,
    required this.ordersCount,
    required this.status,
    required this.basePrice,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String image;
  final String category;
  final double rating;
  final int ordersCount;
  final String status;
  final double basePrice;
  final DateTime? createdAt;

  factory SellerServiceListItem.fromJson(Map<String, dynamic> json) {
    return SellerServiceListItem(
      id: (json['Id'] as num?)?.toInt() ?? (json['id'] as num?)?.toInt() ?? 0,
      title: json['Title']?.toString() ?? json['title']?.toString() ?? '',
      image: json['Image']?.toString() ?? json['image']?.toString() ?? '',
      category:
          json['Category']?.toString() ?? json['category']?.toString() ?? '',
      rating: ((json['Rating'] as num?) ?? (json['rating'] as num?) ?? 0)
          .toDouble(),
      ordersCount:
          (json['OrdersCount'] as num?)?.toInt() ??
          (json['ordersCount'] as num?)?.toInt() ??
          0,
      status: json['Status']?.toString() ?? json['status']?.toString() ?? '',
      basePrice:
          ((json['BasePrice'] as num?) ?? (json['basePrice'] as num?) ?? 0)
              .toDouble(),
      createdAt: DateTime.tryParse(
        json['CreatedAt']?.toString() ?? json['createdAt']?.toString() ?? '',
      ),
    );
  }
}

class SellerServiceDetailsResponse {
  SellerServiceDetailsResponse({required this.success, this.message, this.data});

  final bool success;
  final String? message;
  final SellerServiceDetails? data;

  factory SellerServiceDetailsResponse.fromJson(Map<String, dynamic> json) {
    final ok = json['success'] == true;
    final dataJson = json['data'];
    return SellerServiceDetailsResponse(
      success: ok,
      message: json['message']?.toString(),
      data: dataJson is Map<String, dynamic>
          ? SellerServiceDetails.fromJson(dataJson)
          : null,
    );
  }
}

class SellerServiceDetails {
  SellerServiceDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.rating,
    required this.ordersCount,
    required this.images,
    required this.optionGroups,
  });

  final int id;
  final String title;
  final String description;
  final double basePrice;
  final String category;
  final String status;
  final DateTime? createdAt;
  final double rating;
  final int ordersCount;
  final List<String> images;
  final List<SellerOptionGroup> optionGroups;

  factory SellerServiceDetails.fromJson(Map<String, dynamic> json) {
    final imgs = <String>[];
    final rawImgs = json['images'];
    if (rawImgs is List) {
      for (final e in rawImgs) {
        if (e != null) imgs.add(e.toString());
      }
    }

    final groups = <SellerOptionGroup>[];
    final rawGroups = json['optionGroups'];
    if (rawGroups is List) {
      for (final e in rawGroups) {
        if (e is Map<String, dynamic>) {
          groups.add(SellerOptionGroup.fromJson(e));
        }
      }
    }

    return SellerServiceDetails(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ordersCount: (json['ordersCount'] as num?)?.toInt() ?? 0,
      images: imgs,
      optionGroups: groups,
    );
  }
}

class SellerOptionGroup {
  SellerOptionGroup({
    required this.id,
    required this.name,
    required this.isRequired,
    required this.options,
  });

  final int id;
  final String name;
  final bool isRequired;
  final List<SellerOption> options;

  factory SellerOptionGroup.fromJson(Map<String, dynamic> json) {
    final opts = <SellerOption>[];
    final raw = json['options'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          opts.add(SellerOption.fromJson(e));
        }
      }
    }
    return SellerOptionGroup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      isRequired: json['isRequired'] == true,
      options: opts,
    );
  }
}

class SellerOption {
  SellerOption({
    required this.id,
    required this.name,
    required this.price,
  });

  final int id;
  final String name;
  final double price;

  factory SellerOption.fromJson(Map<String, dynamic> json) {
    return SellerOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SellerDashboardStats {
  SellerDashboardStats({
    required this.totalServices,
    required this.activeOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.averageRating,
  });

  final int totalServices;
  final int activeOrders;
  final int completedOrders;
  final double totalRevenue;
  final double averageRating;

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory SellerDashboardStats.fromJson(Map<String, dynamic> json) {
    dynamic getVal(String key) {
      final lowerKey = key.toLowerCase();
      for (final k in json.keys) {
        // Strip out underscores to match snake_case as well (e.g. total_services -> totalservices)
        if (k.replaceAll('_', '').toLowerCase() == lowerKey) return json[k];
      }
      return null;
    }

    return SellerDashboardStats(
      totalServices: _parseInt(getVal('totalservices')),
      activeOrders: _parseInt(getVal('activeorders')),
      completedOrders: _parseInt(getVal('completedorders')),
      totalRevenue: _parseDouble(getVal('totalrevenue')),
      averageRating: _parseDouble(getVal('averagerating')),
    );
  }
}

class CreateServiceRequest {
  CreateServiceRequest({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.basePrice,
    required this.images,
    required this.optionGroups,
  });

  final String title;
  final String description;
  final int categoryId;
  final double basePrice;
  final List<String> images;
  final List<CreateOptionGroup> optionGroups;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'categoryId': categoryId,
        'basePrice': basePrice,
        'images': images,
        'optionGroups': optionGroups.map((e) => e.toJson()).toList(),
      };
}

class CreateOptionGroup {
  CreateOptionGroup({
    required this.name,
    required this.isRequired,
    required this.options,
  });

  final String name;
  final bool isRequired;
  final List<CreateOption> options;

  Map<String, dynamic> toJson() => {
        'name': name,
        'isRequired': isRequired,
        'options': options.map((e) => e.toJson()).toList(),
      };
}

class CreateOption {
  CreateOption({
    required this.name,
    required this.price,
  });

  final String name;
  final double price;

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
      };
}

