import 'package:flutter/material.dart';

class DriverNameProvider extends ChangeNotifier {
  String driverName = '';

  void setDriverName(String name) {
    driverName = name;
    notifyListeners();
  }
}
