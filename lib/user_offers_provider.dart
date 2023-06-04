import 'package:flutter/foundation.dart';

class UserOffersProvider with ChangeNotifier {
  List<Map<String, dynamic>> _userOffers = [];

  List<Map<String, dynamic>> get userOffers => _userOffers;

  void updateUserOffers(List<Map<String, dynamic>> updatedUserOffers) {
    _userOffers = updatedUserOffers;
    notifyListeners();
  }
}
