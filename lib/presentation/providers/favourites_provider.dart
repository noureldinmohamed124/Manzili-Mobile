import 'package:flutter/foundation.dart';
import 'package:manzili_mobile/data/models/service_models.dart';

/// Local favourites for showcase (until favourites API exists).
class FavouritesProvider extends ChangeNotifier {
  final Map<int, ServiceItem> _itemsById = {};

  List<ServiceItem> get items => _itemsById.values.toList();

  bool isFavourite(int serviceId) => _itemsById.containsKey(serviceId);

  void toggle(ServiceItem item) {
    if (_itemsById.containsKey(item.id)) {
      _itemsById.remove(item.id);
    } else {
      _itemsById[item.id] = item;
    }
    notifyListeners();
  }

  void remove(int serviceId) {
    _itemsById.remove(serviceId);
    notifyListeners();
  }

  void clear() {
    _itemsById.clear();
    notifyListeners();
  }
}

