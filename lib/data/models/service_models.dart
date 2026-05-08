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
    this.optionGroups,
    this.images,
    this.reviews,
    this.status,
    this.category,
    this.ordersCount,
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
  /// Flat list of all options (legacy — kept for backward compat).
  final List<ServiceOption>? options;
  /// Structured option groups — use this for rendering in the buyer details view.
  final List<ServiceOptionGroup>? optionGroups;
  final List<ServiceImage>? images;
  final List<ServiceReview>? reviews;
  final String? status;
  final String? category;
  final int? ordersCount;

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
      // Backend may return `imageUrl` (old) or `thumbnailImageUrl` (new list response).
      imageUrl: (json['imageUrl'] as String?) ??
          (json['thumbnailImageUrl'] as String?) ??
          '',
      serviceDescription: json['serviceDescription'] as String?,
      address: json['address'] as String?,
      provider: json['provider'] is Map
          ? ServiceProvider.fromJson(json['provider'] as Map<String, dynamic>)
          : null,
      options: _parseOptions(json),
      optionGroups: _parseOptionGroups(json),
      images: json['images'] is List
          ? (json['images'] as List<dynamic>)
              .map((e) => ServiceImage.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      reviews: _parseReviews(json),
      status: json['status'] as String?,
      category: json['category'] is Map 
          ? (json['category'] as Map<String, dynamic>)['nameAr'] as String?
          : json['category'] as String?,
      ordersCount: json['ordersCount'] as int? ?? 0,
    );
  }
  static List<ServiceOption>? _parseOptions(Map<String, dynamic> json) {
    final directOptions = json['options'] ?? json['Options'];
    if (directOptions is List) {
      return directOptions
          .map((e) => ServiceOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final optionGroups = json['optionGroups'] ?? json['OptionGroups'];
    if (optionGroups is List) {
      final opts = <ServiceOption>[];
      for (final g in optionGroups) {
        if (g is Map<String, dynamic>) {
          final gOptions = g['options'] ?? g['Options'];
          if (gOptions is List) {
            opts.addAll(
              gOptions.map((e) {
                final eMap = e as Map<String, dynamic>;
                return ServiceOption(
                  id: (eMap['id'] ?? eMap['Id']) as int? ?? 0,
                  serviceOptionName: (eMap['name'] ?? eMap['Name'] ?? eMap['serviceOptionName'])?.toString() ?? '',
                  price: (eMap['price'] ?? eMap['Price']) as num? ?? 0,
                );
              }),
            );
          }
        }
      }
      return opts.isNotEmpty ? opts : null;
    }
    return null;
  }

  /// Parses the structured optionGroups array, preserving group name + isRequired.
  static List<ServiceOptionGroup>? _parseOptionGroups(Map<String, dynamic> json) {
    final raw = json['optionGroups'] ?? json['OptionGroups'];
    if (raw is! List || raw.isEmpty) return null;
    final groups = <ServiceOptionGroup>[];
    for (final g in raw) {
      if (g is Map<String, dynamic>) {
        groups.add(ServiceOptionGroup.fromJson(g));
      }
    }
    return groups.isEmpty ? null : groups;
  }

  static List<ServiceReview>? _parseReviews(Map<String, dynamic> json) {
    dynamic list = json['reviews'] ?? json['serviceReviews'];
    if (list is! List<dynamic> || list.isEmpty) return null;
    final out = <ServiceReview>[];
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        out.add(ServiceReview.fromJson(e));
      }
    }
    return out.isEmpty ? null : out;
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
      id: (json['id'] ?? json['Id']) as int? ?? 0,
      serviceOptionName: (json['serviceOptionName'] ?? json['ServiceOptionName'] ?? json['name'] ?? json['Name'])?.toString() ?? '',
      price: (json['price'] ?? json['Price']) as num? ?? 0,
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
      id: json['id'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}

/// A structured option group as returned by the API.
/// [isRequired] = true → buyer must pick exactly one (radio).
/// [isRequired] = false → buyer can pick zero or more (checkbox add-ons).
class ServiceOptionGroup {
  ServiceOptionGroup({
    required this.id,
    required this.name,
    required this.isRequired,
    required this.options,
  });

  final int id;
  final String name;
  final bool isRequired;
  final List<ServiceOption> options;

  factory ServiceOptionGroup.fromJson(Map<String, dynamic> json) {
    final rawOpts = json['options'] ?? json['Options'];
    final opts = <ServiceOption>[];
    if (rawOpts is List) {
      for (final e in rawOpts) {
        if (e is Map<String, dynamic>) opts.add(ServiceOption.fromJson(e));
      }
    }
    return ServiceOptionGroup(
      id: (json['id'] ?? json['Id']) as int? ?? 0,
      name: (json['name'] ?? json['Name'])?.toString() ?? '',
      isRequired: json['isRequired'] == true,
      options: opts,
    );
  }
}

/// Review row when API includes a list on the service payload.
class ServiceReview {
  ServiceReview({
    required this.rating,
    this.reviewerName,
    this.comment,
    this.createdAt,
  });

  final num rating;
  final String? reviewerName;
  final String? comment;
  final String? createdAt;

  factory ServiceReview.fromJson(Map<String, dynamic> json) {
    final name = json['reviewerName'] as String? ??
        json['userName'] as String? ??
        json['fullName'] as String? ??
        json['customerName'] as String?;
    final text = json['comment'] as String? ??
        json['text'] as String? ??
        json['review'] as String? ??
        json['content'] as String?;
    final date = json['createdAt'] as String? ??
        json['date'] as String? ??
        json['reviewDate'] as String?;
    return ServiceReview(
      rating: json['rating'] as num? ?? 0,
      reviewerName: name,
      comment: text,
      createdAt: date,
    );
  }
}

/// GET /api/services/home/{no} — grouped sections when backend exposes this route.
class HomeServicesBuckets {
  HomeServicesBuckets({
    required this.topDiscounts,
    required this.recommended,
    required this.mostPurchased,
    required this.regular,
  });

  final List<ServiceItem> topDiscounts;
  final List<ServiceItem> recommended;
  final List<ServiceItem> mostPurchased;
  final List<ServiceItem> regular;

  bool get isEmpty =>
      topDiscounts.isEmpty &&
      recommended.isEmpty &&
      mostPurchased.isEmpty &&
      regular.isEmpty;

  factory HomeServicesBuckets.fromJson(Map<String, dynamic> json) {
    List<ServiceItem> parseList(String key) {
      final list = json[key] as List<dynamic>? ?? [];
      return list
          .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return HomeServicesBuckets(
      topDiscounts: parseList('topDiscounts'),
      recommended: parseList('recommended'),
      mostPurchased: parseList('mostPurchased'),
      regular: parseList('regular'),
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

