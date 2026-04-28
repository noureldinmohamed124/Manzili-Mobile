import 'package:flutter/foundation.dart';
import 'package:manzili_mobile/core/constants/demo_data.dart';
import 'package:manzili_mobile/data/models/seller_models.dart';
import 'package:manzili_mobile/data/repositories/seller_repository.dart';

class SellerProvider extends ChangeNotifier {
  final SellerRepository _repo = SellerRepository();

  bool _isLoadingServices = false;
  bool _isLoadingDetails = false;
  bool _isLoadingDashboard = false;

  String? _servicesError;
  String? _detailsError;
  String? _dashboardError;

  List<SellerServiceListItem> _services = [];
  SellerServiceDetails? _currentService;
  SellerDashboardStats? _stats;

  bool get isLoadingServices => _isLoadingServices;
  bool get isLoadingDetails => _isLoadingDetails;
  bool get isLoadingDashboard => _isLoadingDashboard;

  String? get servicesError => _servicesError;
  String? get detailsError => _detailsError;
  String? get dashboardError => _dashboardError;

  List<SellerServiceListItem> get services => _services;
  SellerServiceDetails? get currentService => _currentService;
  SellerDashboardStats? get stats => _stats;

  Future<void> fetchSellerServices({
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    _isLoadingServices = true;
    _servicesError = null;
    notifyListeners();

    final (items, err) = await _repo.getSellerServices(
      status: status,
      page: page,
      pageSize: pageSize,
    );

    _isLoadingServices = false;
    if (err != null) {
      // Showcase fallback: keep UI usable even if API is down.
      _servicesError = null;
      _services = DemoData.sellerServices();
    } else {
      _services = items;
    }
    notifyListeners();
  }

  Future<void> fetchSellerServiceById(int id) async {
    _isLoadingDetails = true;
    _detailsError = null;
    _currentService = null;
    notifyListeners();

    final (service, err) = await _repo.getSellerServiceById(id);
    _isLoadingDetails = false;

    if (err != null) {
      _detailsError = err;
    } else {
      _currentService = service;
    }
    notifyListeners();
  }

  Future<void> fetchDashboardStats() async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    final (stats, err) = await _repo.getDashboardStats();
    _isLoadingDashboard = false;

    if (err != null) {
      // Showcase fallback.
      _dashboardError = null;
      _stats = DemoData.sellerDashboard();
    } else {
      _stats = stats;
    }
    notifyListeners();
  }
}

