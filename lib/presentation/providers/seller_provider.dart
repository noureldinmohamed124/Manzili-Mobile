import 'package:flutter/material.dart';
import 'package:manzili_mobile/data/models/service_models.dart';

import 'package:manzili_mobile/data/models/seller_models.dart';
import 'package:manzili_mobile/data/repositories/seller_repository.dart';

class SellerProvider extends ChangeNotifier {
  final SellerRepository _repository = SellerRepository();

  bool _isLoadingDashboard = false;
  bool get isLoadingDashboard => _isLoadingDashboard;

  String? _dashboardError;
  String? get dashboardError => _dashboardError;

  SellerDashboardStats? _stats;
  SellerDashboardStats? get stats => _stats;

  bool _isLoadingServices = false;
  bool get isLoadingServices => _isLoadingServices;

  String? _servicesError;
  String? get servicesError => _servicesError;

  List<SellerServiceListItem> _sellerServices = [];
  List<SellerServiceListItem> get sellerServices => _sellerServices;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  String? _detailsError;
  String? get detailsError => _detailsError;

  SellerServiceDetails? _currentService;
  SellerServiceDetails? get currentService => _currentService;

  Future<void> fetchDashboardStats() async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    try {
      final (data, err) = await _repository.getDashboardStats();
      if (err != null) {
        _dashboardError = err;
      } else {
        _stats = data;
      }
    } catch (e) {
      _dashboardError = e.toString();
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  Future<void> fetchSellerServices({int page = 1, int pageSize = 10, String? status}) async {
    _isLoadingServices = true;
    _servicesError = null;
    notifyListeners();

    try {
      final (data, err) = await _repository.getSellerServices(page: page, pageSize: pageSize, status: status);
      if (err != null) {
        _servicesError = err;
      } else {
        _sellerServices = data;
      }
    } catch (e) {
      _servicesError = e.toString();
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  Future<void> fetchSellerServiceById(int id) async {
    _isLoadingDetails = true;
    _detailsError = null;
    notifyListeners();

    try {
      final (data, err) = await _repository.getSellerServiceById(id);
      if (err != null) {
        _detailsError = err;
        _currentService = null;
      } else {
        _currentService = data;
      }
    } catch (e) {
      _detailsError = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<(bool, String?)> createService(CreateServiceRequest request, List<String> imagePaths) async {
    return await _repository.createService(request, imagePaths);
  }

  bool _isRepricing = false;
  bool get isRepricing => _isRepricing;

  Future<(bool, String?)> repriceOrder(int orderId, double newPrice, String reason) async {
    _isRepricing = true;
    notifyListeners();
    final res = await _repository.repriceOrder(orderId, newPrice, reason);
    _isRepricing = false;
    notifyListeners();
    return res;
  }

  bool _isRejecting = false;
  bool get isRejecting => _isRejecting;

  Future<(bool, String?)> rejectOrder(int orderId, String reason) async {
    _isRejecting = true;
    notifyListeners();
    final res = await _repository.rejectOrder(orderId, reason);
    _isRejecting = false;
    notifyListeners();
    return res;
  }

  bool _isApproving = false;
  bool get isApproving => _isApproving;

  Future<(bool, String?)> approveOrder(int orderId) async {
    _isApproving = true;
    notifyListeners();
    final res = await _repository.approveOrder(orderId);
    _isApproving = false;
    notifyListeners();
    return res;
  }

  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;

  String? _ordersError;
  String? get ordersError => _ordersError;

  SellerOrderListResponse? _ordersResponse;
  SellerOrderListResponse? get ordersResponse => _ordersResponse;

  Future<void> fetchSellerOrders({String? status, int page = 1, int pageSize = 10}) async {
    _isLoadingOrders = true;
    _ordersError = null;
    notifyListeners();

    final (data, error) = await _repository.getSellerOrders(status: status, page: page, pageSize: pageSize);
    _isLoadingOrders = false;
    if (error != null) _ordersError = error;
    else _ordersResponse = data;
    notifyListeners();
  }

  bool _isLoadingOrderDetails = false;
  bool get isLoadingOrderDetails => _isLoadingOrderDetails;

  String? _orderDetailsError;
  String? get orderDetailsError => _orderDetailsError;

  SellerOrderDetails? _currentOrder;
  SellerOrderDetails? get currentOrder => _currentOrder;

  Future<void> fetchSellerOrderById(int orderId) async {
    _isLoadingOrderDetails = true;
    _orderDetailsError = null;
    notifyListeners();

    final (data, error) = await _repository.getSellerOrderById(orderId);
    _isLoadingOrderDetails = false;
    if (error != null) _orderDetailsError = error;
    else _currentOrder = data;
    notifyListeners();
  }

  bool _isUpdatingStatus = false;
  bool get isUpdatingStatus => _isUpdatingStatus;

  Future<(bool, String?)> updateOrderStatus(int orderId, String status) async {
    _isUpdatingStatus = true;
    notifyListeners();
    final res = await _repository.updateOrderStatus(orderId, status);
    _isUpdatingStatus = false;
    notifyListeners();
    return res;
  }

  bool _isUpdatingService = false;
  bool get isUpdatingService => _isUpdatingService;

  Future<(bool, String?)> updateService(int serviceId, CreateServiceRequest request, List<String> imagePaths) async {
    _isUpdatingService = true;
    notifyListeners();
    final res = await _repository.updateService(serviceId, request, imagePaths);
    _isUpdatingService = false;
    notifyListeners();
    return res;
  }

  bool _isDeletingService = false;
  bool get isDeletingService => _isDeletingService;

  Future<(bool, String?)> deleteService(int serviceId) async {
    _isDeletingService = true;
    notifyListeners();
    final res = await _repository.deleteService(serviceId);
    _isDeletingService = false;
    notifyListeners();
    return res;
  }
}
