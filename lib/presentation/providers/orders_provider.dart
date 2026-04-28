import 'package:flutter/foundation.dart';
import 'package:manzili_mobile/core/constants/demo_data.dart';
import 'package:manzili_mobile/data/models/order_models.dart';
import 'package:manzili_mobile/data/repositories/orders_repository.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersRepository _repository = OrdersRepository();

  List<OrderListItem> _orders = [];
  PaymentSummaryData? _paymentSummary;
  
  bool _isLoading = false;
  bool _isSubmittingPaymentProof = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalPages = 1;

  List<OrderListItem> get orders => _orders;
  PaymentSummaryData? get paymentSummary => _paymentSummary;
  
  bool get isLoading => _isLoading;
  bool get isSubmittingPaymentProof => _isSubmittingPaymentProof;
  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  Future<void> fetchOrders({String? status, int page = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final (response, error) = await _repository.getOrders(
      status: status,
      page: page,
      pageSize: _pageSize,
    );

    _isLoading = false;

    if (error != null) {
      // Showcase fallback: provide demo orders so the flow is usable.
      _errorMessage = null;
      if (page == 1) {
        _orders = DemoData.orders();
        _currentPage = 1;
        _totalPages = 1;
      }
    } else if (response != null) {
      if (page == 1) {
        _orders = response.items;
      } else {
        _orders.addAll(response.items);
      }
      _currentPage = response.page;
      _totalPages = response.totalPages;
    }

    notifyListeners();
  }

  Future<void> fetchPaymentSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final (response, error) = await _repository.getPaymentSummary();

    _isLoading = false;

    if (error != null) {
      // Showcase fallback.
      _errorMessage = null;
      _paymentSummary = DemoData.paymentSummary();
    } else {
      _paymentSummary = response;
    }

    notifyListeners();
  }

  Future<bool> submitPaymentProof({
    required String paymentScreenshot,
    String? notes,
  }) async {
    if (_paymentSummary == null) {
      _errorMessage = 'مفيش ملخص دفع عشان نعرف الطلبات';
      notifyListeners();
      return false;
    }
    final orderIds =
        _paymentSummary!.services.map((e) => e.orderId).where((id) => id > 0).toList();
    if (orderIds.isEmpty) {
      _errorMessage = 'مفيش طلبات صالحة لإرسال الإثبات';
      notifyListeners();
      return false;
    }
    if (paymentScreenshot.trim().isEmpty) {
      _errorMessage = 'ارفع/ابعت صورة الإيصال الأول';
      notifyListeners();
      return false;
    }

    _isSubmittingPaymentProof = true;
    _errorMessage = null;
    notifyListeners();

    final (_, err) = await _repository.submitPaymentProof(
      orderIds: orderIds,
      paymentScreenshot: paymentScreenshot.trim(),
      notes: notes,
    );

    _isSubmittingPaymentProof = false;
    if (err != null) {
      _errorMessage = err;
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }
}
