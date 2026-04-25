import 'package:flutter/foundation.dart';
import 'package:manzili_mobile/data/models/order_models.dart';
import 'package:manzili_mobile/data/repositories/orders_repository.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersRepository _repository = OrdersRepository();

  List<OrderListItem> _orders = [];
  PaymentSummaryData? _paymentSummary;
  
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalPages = 1;

  List<OrderListItem> get orders => _orders;
  PaymentSummaryData? get paymentSummary => _paymentSummary;
  
  bool get isLoading => _isLoading;
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
      _errorMessage = error;
      if (page == 1) _orders.clear();
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
      _errorMessage = error;
      _paymentSummary = null;
    } else {
      _paymentSummary = response;
    }

    notifyListeners();
  }
}
