import 'package:flutter/foundation.dart';
import 'package:manzili_mobile/data/repositories/admin_repository.dart';
import 'package:manzili_mobile/data/models/admin_models.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _userDetails;
  Map<String, dynamic>? get userDetails => _userDetails;

  bool _isUnblocking = false;
  bool get isUnblocking => _isUnblocking;

  Future<void> fetchUserDetails(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    _userDetails = null;
    notifyListeners();

    final (data, error) = await _repository.getUserDetails(userId);

    _isLoading = false;
    if (error != null) {
      _errorMessage = error;
    } else {
      _userDetails = data;
    }
    notifyListeners();
  }

  Future<(bool, String?)> unblockUser(int userId) async {
    _isUnblocking = true;
    notifyListeners();

    final (success, error) = await _repository.unblockUser(userId);

    _isUnblocking = false;
    if (error != null) {
      notifyListeners();
      return (false, error);
    }

    // Refresh user details to reflect changes
    if (_userDetails != null && _userDetails!['id'] == userId) {
      _userDetails!['isBlocked'] = false;
      _userDetails!['blockedUntil'] = null;
      _userDetails!['blockReason'] = null;
    }
    
    notifyListeners();
    return (true, null);
  }

  bool _isBlocking = false;
  bool get isBlocking => _isBlocking;

  Future<(bool, String?)> blockUser(int userId, String reason, DateTime blockedUntil) async {
    _isBlocking = true;
    notifyListeners();

    final (success, error) = await _repository.blockUser(userId, reason, blockedUntil);

    _isBlocking = false;
    if (error != null) {
      notifyListeners();
      return (false, error);
    }

    if (_userDetails != null && _userDetails!['id'] == userId) {
      _userDetails!['isBlocked'] = true;
      _userDetails!['blockedUntil'] = blockedUntil.toIso8601String();
      _userDetails!['blockReason'] = reason;
    }
    
    notifyListeners();
    return (true, null);
  }

  AdminDashboardStats? _dashboardStats;
  AdminDashboardStats? get dashboardStats => _dashboardStats;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final (data, error) = await _repository.getDashboardStats();
    _isLoading = false;
    if (error != null) _errorMessage = error;
    else _dashboardStats = data;
    notifyListeners();
  }

  AdminUsersResponse? _usersResponse;
  AdminUsersResponse? get usersResponse => _usersResponse;

  String? _selectedRole; // null = all, 'Buyer', 'Provider', 'Admin'
  bool? _selectedIsBlocked; // null = all, true = blocked only, false = active only

  String? get selectedRole => _selectedRole;
  bool? get selectedIsBlocked => _selectedIsBlocked;

  void setUserFilters({String? role, bool? isBlocked}) {
    _selectedRole = role;
    _selectedIsBlocked = isBlocked;
    fetchUsers(role: role, isBlocked: isBlocked);
  }

  Future<void> fetchUsers({int page = 1, int pageSize = 10, String? role, bool? isBlocked, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final (data, error) = await _repository.getUsers(page: page, pageSize: pageSize, role: role, isBlocked: isBlocked, search: search);
    _isLoading = false;
    if (error != null) _errorMessage = error;
    else _usersResponse = data;
    notifyListeners();
  }

  AdminFinancialsResponse? _financialsResponse;
  AdminFinancialsResponse? get financialsResponse => _financialsResponse;

  Future<void> fetchFinancials({int page = 1, int pageSize = 10, DateTime? from, DateTime? to, int? buyerId, int? providerId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final (data, error) = await _repository.getFinancials(page: page, pageSize: pageSize, from: from, to: to, buyerId: buyerId, providerId: providerId);
    _isLoading = false;
    if (error != null) _errorMessage = error;
    else _financialsResponse = data;
    notifyListeners();
  }

  AdminOrdersResponse? _ordersResponse;
  AdminOrdersResponse? get ordersResponse => _ordersResponse;

  Future<void> fetchOrders({int page = 1, int pageSize = 10, String? status, int? buyerId, int? providerId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final (data, error) = await _repository.getOrders(page: page, pageSize: pageSize, status: status, buyerId: buyerId, providerId: providerId);
    _isLoading = false;
    if (error != null) _errorMessage = error;
    else _ordersResponse = data;
    notifyListeners();
  }

  AdminServicesResponse? _servicesResponse;
  AdminServicesResponse? get servicesResponse => _servicesResponse;

  Future<void> fetchServices({int page = 1, int pageSize = 10, int? providerId, String? status, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final (data, error) = await _repository.getServices(page: page, pageSize: pageSize, providerId: providerId, status: status, search: search);
    _isLoading = false;
    if (error != null) _errorMessage = error;
    else _servicesResponse = data;
    notifyListeners();
  }
}
