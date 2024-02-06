import 'package:flutter/material.dart';

class OrderTypeProvider extends ChangeNotifier {
  String orderType = '';
  void setOrderType(String type) {
    orderType = type;
    notifyListeners();
  }
}
