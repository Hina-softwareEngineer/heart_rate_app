import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heart_rate/utils/AuthDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavBarBloc extends ChangeNotifier {
  int selectedIndex = 0;

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  int get currentIndex => selectedIndex;
}
