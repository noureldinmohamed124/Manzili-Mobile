class AdminDashboardStats {
  AdminDashboardStats({
    required this.totalUsers,
    required this.totalProviders,
    required this.totalBuyers,
    required this.totalServices,
    required this.activeServices,
    required this.pendingServices,
    required this.totalOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.pendingPayments,
    required this.totalRevenue,
  });

  final int totalUsers;
  final int totalProviders;
  final int totalBuyers;
  final int totalServices;
  final int activeServices;
  final int pendingServices;
  final int totalOrders;
  final int activeOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int pendingPayments;
  final double totalRevenue;

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      totalProviders: (json['totalProviders'] as num?)?.toInt() ?? 0,
      totalBuyers: (json['totalBuyers'] as num?)?.toInt() ?? 0,
      totalServices: (json['totalServices'] as num?)?.toInt() ?? 0,
      activeServices: (json['activeServices'] as num?)?.toInt() ?? 0,
      pendingServices: (json['pendingServices'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      activeOrders: (json['activeOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      pendingPayments: (json['pendingPayments'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AdminFinancialsResponse {
  AdminFinancialsResponse({
    required this.totalRevenue,
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final double totalRevenue;
  final List<AdminFinancialItem> items;
  final int totalCount;
  final int page;
  final int pageSize;

  factory AdminFinancialsResponse.fromJson(Map<String, dynamic> json) {
    return AdminFinancialsResponse(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List?)?.map((e) => AdminFinancialItem.fromJson(e)).toList() ?? [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
    );
  }
}

class AdminFinancialItem {
  AdminFinancialItem({
    required this.transactionId,
    required this.orderId,
    required this.serviceTitle,
    required this.buyerName,
    required this.providerName,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  final int transactionId;
  final int orderId;
  final String serviceTitle;
  final String buyerName;
  final String providerName;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;

  factory AdminFinancialItem.fromJson(Map<String, dynamic> json) {
    return AdminFinancialItem(
      transactionId: (json['transactionId'] as num?)?.toInt() ?? 0,
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      serviceTitle: json['serviceTitle']?.toString() ?? '',
      buyerName: json['buyerName']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class AdminOrdersResponse {
  AdminOrdersResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<AdminOrderItem> items;
  final int totalCount;
  final int page;
  final int pageSize;

  factory AdminOrdersResponse.fromJson(Map<String, dynamic> json) {
    return AdminOrdersResponse(
      items: (json['items'] as List?)?.map((e) => AdminOrderItem.fromJson(e)).toList() ?? [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
    );
  }
}

class AdminOrderItem {
  AdminOrderItem({
    required this.orderId,
    required this.serviceId,
    required this.serviceTitle,
    required this.buyerId,
    required this.buyerName,
    required this.providerId,
    required this.providerName,
    required this.totalPrice,
    required this.currentStatus,
    required this.createdAt,
  });

  final int orderId;
  final int serviceId;
  final String serviceTitle;
  final int buyerId;
  final String buyerName;
  final int providerId;
  final String providerName;
  final double totalPrice;
  final String currentStatus;
  final DateTime? createdAt;

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      serviceId: (json['serviceId'] as num?)?.toInt() ?? 0,
      serviceTitle: json['serviceTitle']?.toString() ?? '',
      buyerId: (json['buyerId'] as num?)?.toInt() ?? 0,
      buyerName: json['buyerName']?.toString() ?? '',
      providerId: (json['providerId'] as num?)?.toInt() ?? 0,
      providerName: json['providerName']?.toString() ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      currentStatus: json['currentStatus']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class AdminServicesResponse {
  AdminServicesResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<AdminServiceItem> items;
  final int totalCount;
  final int page;
  final int pageSize;

  factory AdminServicesResponse.fromJson(Map<String, dynamic> json) {
    return AdminServicesResponse(
      items: (json['items'] as List?)?.map((e) => AdminServiceItem.fromJson(e)).toList() ?? [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
    );
  }
}

class AdminServiceItem {
  AdminServiceItem({
    required this.id,
    required this.title,
    required this.basePrice,
    required this.status,
    required this.providerId,
    required this.providerName,
    required this.createdAt,
  });

  final int id;
  final String title;
  final double basePrice;
  final String status;
  final int providerId;
  final String providerName;
  final DateTime? createdAt;

  factory AdminServiceItem.fromJson(Map<String, dynamic> json) {
    return AdminServiceItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      providerId: (json['providerId'] as num?)?.toInt() ?? 0,
      providerName: json['providerName']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class AdminUsersResponse {
  AdminUsersResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<AdminUserItem> items;
  final int totalCount;
  final int page;
  final int pageSize;

  factory AdminUsersResponse.fromJson(Map<String, dynamic> json) {
    return AdminUsersResponse(
      items: (json['items'] as List?)?.map((e) => AdminUserItem.fromJson(e)).toList() ?? [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
    );
  }
}

class AdminUserItem {
  AdminUserItem({
    required this.id,
    required this.fullName,
    required this.email,
    required this.profilePicture,
    required this.role,
    required this.isBlocked,
    required this.blockedUntil,
    required this.createdAt,
  });

  final int id;
  final String fullName;
  final String email;
  final String profilePicture;
  final String role;
  final bool isBlocked;
  final DateTime? blockedUntil;
  final DateTime? createdAt;

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'];
    String parsedRole = 'Unknown';
    if (rawRole is String) parsedRole = rawRole;
    else if (rawRole is num) {
      if (rawRole == 0) parsedRole = 'Buyer';
      else if (rawRole == 1) parsedRole = 'Admin';
      else if (rawRole == 2) parsedRole = 'Provider';
    }

    return AdminUserItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePicture: json['profilePicture']?.toString() ?? '',
      role: parsedRole,
      isBlocked: json['isBlocked'] == true,
      blockedUntil: DateTime.tryParse(json['blockedUntil']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
