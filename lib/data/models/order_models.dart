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
        'optionGroups': optionGroups.map((e) => e.toJson()).toList(),
      };
}
