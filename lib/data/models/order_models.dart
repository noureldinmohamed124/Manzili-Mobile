// POST /api/orders/request — body aligned with Manzili API spec.

class OrderOptionItem {
  OrderOptionItem({
    required this.optionId,
    required this.quantity,
  });

  final int optionId;
  final int quantity;

  Map<String, dynamic> toJson() => {
        'optionId': optionId,
        'quantity': quantity,
      };
}

class OrderOptionGroup {
  OrderOptionGroup({
    required this.groupId,
    required this.items,
  });

  final int groupId;
  final List<OrderOptionItem> items;

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderRequestBody {
  OrderRequestBody({
    required this.serviceId,
    required this.customizationText,
    this.customRequestImage,
    required this.quantity,
    required this.optionGroups,
  });

  final int serviceId;
  final String customizationText;
  final String? customRequestImage;
  final int quantity;
  final List<OrderOptionGroup> optionGroups;

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'customizationText': customizationText,
        if (customRequestImage != null && customRequestImage!.isNotEmpty)
          'customRequestImage': customRequestImage,
        'quantity': quantity,
        if (optionGroups.isNotEmpty)
          'optionGroups': optionGroups.map((e) => e.toJson()).toList(),
      };
}

// -----------------------------------------------------------------------------
// GET /api/orders/ response models
// -----------------------------------------------------------------------------

class OrderListOption {
  OrderListOption({
    required this.groupOption,
    required this.option,
    required this.quantity,
  });

  final String groupOption;
  final String option;
  final int quantity;

  factory OrderListOption.fromJson(Map<String, dynamic> json) {
    return OrderListOption(
      groupOption: json['groupOption']?.toString() ?? '',
      option: json['option']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class OrderListItem {
  OrderListItem({
    required this.id,
    required this.serviceName,
    required this.customizationDetails,
    required this.totalPrice,
    required this.status,
    required this.providerName,
    required this.createdAt,
    required this.options,
  });

  final int id;
  final String serviceName;
  final String customizationDetails;
  final double totalPrice;
  final String status;
  final String providerName;
  final DateTime? createdAt;
  final List<OrderListOption> options;

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    var optsList = <OrderListOption>[];
    if (json['options'] is List) {
      optsList = (json['options'] as List)
          .map((e) => OrderListOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return OrderListItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      serviceName: json['serviceName']?.toString() ?? '',
      customizationDetails: json['customizationDetails']?.toString() ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      options: optsList,
    );
  }
}

class PaginatedOrdersResponse {
  PaginatedOrdersResponse({
    required this.items,
    this.page = 1,
    this.pageSize = 10,
    this.totalPages = 1,
  });

  final List<OrderListItem> items;
  final int page;
  final int pageSize;
  final int totalPages;

  factory PaginatedOrdersResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderListItem>[];
    if (json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((e) => OrderListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return PaginatedOrdersResponse(
      items: itemsList,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

// -----------------------------------------------------------------------------
// GET /api/orders/payment-summary models
// -----------------------------------------------------------------------------

class PaymentSummaryOption {
  PaymentSummaryOption({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final double price;

  factory PaymentSummaryOption.fromJson(Map<String, dynamic> json) {
    return PaymentSummaryOption(
      name: json['Name']?.toString() ?? json['name']?.toString() ?? '',
      quantity: (json['Quantity'] as num?)?.toInt() ?? (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['Price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaymentSummaryService {
  PaymentSummaryService({
    required this.orderId,
    required this.image,
    required this.title,
    required this.quantity,
    required this.price,
    required this.options,
  });

  final int orderId;
  final String image;
  final String title;
  final int quantity;
  final double price;
  final List<PaymentSummaryOption> options;

  factory PaymentSummaryService.fromJson(Map<String, dynamic> json) {
    var optsList = <PaymentSummaryOption>[];
    final optsJson = json['Options'] ?? json['options'];
    if (optsJson is List) {
      optsList = optsJson
          .map((e) => PaymentSummaryOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return PaymentSummaryService(
      orderId: (json['OrderId'] as num?)?.toInt() ?? (json['orderId'] as num?)?.toInt() ?? 0,
      image: json['Image']?.toString() ?? json['image']?.toString() ?? '',
      title: json['Title']?.toString() ?? json['title']?.toString() ?? '',
      quantity: (json['Quantity'] as num?)?.toInt() ?? (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['Price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      options: optsList,
    );
  }
}

class PaymentSummaryAddress {
  PaymentSummaryAddress({
    required this.addressPreview,
    required this.phone,
  });

  final String addressPreview;
  final String phone;

  factory PaymentSummaryAddress.fromJson(Map<String, dynamic> json) {
    return PaymentSummaryAddress(
      addressPreview: json['AddressPreview']?.toString() ?? json['addressPreview']?.toString() ?? '',
      phone: json['Phone']?.toString() ?? json['phone']?.toString() ?? '',
    );
  }
}

class PaymentSummaryBreakdown {
  PaymentSummaryBreakdown({
    required this.subtotal,
    required this.deliveryFees,
    required this.total,
  });

  final double subtotal;
  final double deliveryFees;
  final double total;

  factory PaymentSummaryBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentSummaryBreakdown(
      subtotal: (json['Subtotal'] as num?)?.toDouble() ?? (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFees: (json['DeliveryFees'] as num?)?.toDouble() ?? (json['deliveryFees'] as num?)?.toDouble() ?? 0.0,
      total: (json['Total'] as num?)?.toDouble() ?? (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaymentSummaryData {
  PaymentSummaryData({
    required this.services,
    this.address,
    this.priceBreakdown,
  });

  final List<PaymentSummaryService> services;
  final PaymentSummaryAddress? address;
  final PaymentSummaryBreakdown? priceBreakdown;

  factory PaymentSummaryData.fromJson(Map<String, dynamic> json) {
    var srvsList = <PaymentSummaryService>[];
    final srvsJson = json['Services'] ?? json['services'];
    if (srvsJson is List) {
      srvsList = srvsJson
          .map((e) => PaymentSummaryService.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    
    final addrJson = json['Address'] ?? json['address'];
    final breakdownJson = json['PriceBreakdown'] ?? json['priceBreakdown'];

    return PaymentSummaryData(
      services: srvsList,
      address: addrJson != null ? PaymentSummaryAddress.fromJson(addrJson) : null,
      priceBreakdown: breakdownJson != null ? PaymentSummaryBreakdown.fromJson(breakdownJson) : null,
    );
  }
}
