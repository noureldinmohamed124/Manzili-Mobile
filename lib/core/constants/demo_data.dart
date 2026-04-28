import 'package:manzili_mobile/data/models/order_models.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/data/models/seller_models.dart';

/// Temporary demo data used ONLY for showcase mode when APIs fail.
/// Remove after backend coverage is complete.
class DemoData {
  DemoData._();

  static List<ServiceItem> services() {
    return [
      ServiceItem(
        id: 101,
        title: 'بوكسات سينابون — طازة من البيت',
        providerName: 'Karim Hassan',
        basePrice: 300,
        rating: 4.7,
        imageUrl: 'mahashi_real_1.jpg',
        serviceDescription: 'بوكس سينابون سخن وطري.. ينفع هدية أو عزومة سريعة.',
        address: 'مدينة نصر',
        provider: null,
        options: null,
        images: null,
        reviews: null,
      ),
      ServiceItem(
        id: 102,
        title: 'كحك وبسكوت العيد (سمن بلدي)',
        providerName: 'Abdo Sherif',
        basePrice: 250,
        rating: 4.5,
        imageUrl: 'kahk_real_1.jpg',
        serviceDescription: 'كحك وبيتي فور وبسكوت على أصوله.. طعم زمان.',
        address: 'الهرم',
        provider: null,
        options: null,
        images: null,
        reviews: null,
      ),
      ServiceItem(
        id: 103,
        title: 'خدمة كروشيه حسب المقاس (شيلان وملابس شتوي)',
        providerName: 'Mona Crochet',
        basePrice: 700,
        rating: 4.9,
        imageUrl: 'kahk_ai_1.jpg',
        serviceDescription: 'تفصيل يدوي حسب المقاس.. خامات ممتازة وتوصيل سريع.',
        address: 'المعادي',
        provider: null,
        options: null,
        images: null,
        reviews: null,
      ),
    ];
  }

  static List<SellerServiceListItem> sellerServices() {
    return [
      SellerServiceListItem(
        id: 2,
        title: 'خدمة تصميم إكسسوارات نحاس',
        image: 'bags_real_1.jpg',
        category: 'اكسسوارات',
        rating: 4.6,
        ordersCount: 3,
        status: 'Active',
        basePrice: 200,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      SellerServiceListItem(
        id: 3,
        title: 'خدمة تجهيز بوكسات سينابون',
        image: 'mahashi_real_1.jpg',
        category: 'حلويات',
        rating: 4.8,
        ordersCount: 5,
        status: 'Draft',
        basePrice: 300,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  static SellerDashboardStats sellerDashboard() {
    return SellerDashboardStats(
      totalServices: 2,
      activeOrders: 3,
      completedOrders: 1,
      totalRevenue: 2350.14,
      averageRating: 4.8,
    );
  }

  static List<OrderListItem> orders() {
    return [
      OrderListItem(
        id: 1,
        serviceName: 'خدمة تجهيز بوكسات سينابون',
        customizationDetails: 'عايز السينابون يكون عليه صوص ابيض زيادة',
        totalPrice: 300.0,
        status: 'Request',
        providerName: 'Karim Hassan',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        options: [
          OrderListOption(groupOption: 'الحجم', option: 'متوسط', quantity: 1),
          OrderListOption(groupOption: 'التغليف', option: 'هدية', quantity: 1),
        ],
      ),
      OrderListItem(
        id: 2,
        serviceName: 'كحك وبسكوت العيد',
        customizationDetails: 'عايز نص كيلو كحك ونص بسكوت',
        totalPrice: 250.0,
        status: 'Delivered',
        providerName: 'Abdo Sherif',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        options: const [],
      ),
    ];
  }

  static PaymentSummaryData paymentSummary() {
    return PaymentSummaryData(
      services: [
        PaymentSummaryService(
          orderId: 1,
          image: 'mahashi_real_1.jpg',
          title: 'خدمة تجهيز بوكسات سينابون',
          quantity: 1,
          price: 300,
          options: [
            PaymentSummaryOption(name: 'الحجم: متوسط', quantity: 1, price: 0),
          ],
        ),
      ],
      address: PaymentSummaryAddress(
        addressPreview: 'مدينة نصر - شارع الطيران',
        phone: '0100 000 0000',
      ),
      priceBreakdown: PaymentSummaryBreakdown(
        subtotal: 300,
        deliveryFees: 30,
        total: 330,
      ),
    );
  }
}

