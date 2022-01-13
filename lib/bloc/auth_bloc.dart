import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heart_rate/utils/AuthDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

enum AuthEvent {
  AUTH_PENDING,
  AUTH_SUCCESS,
  AUTH_FAILED,
  AUTH_LOADING,
}

class AuthenticationBloc extends ChangeNotifier {
  final Map<String, dynamic> authDetails = {
    "loading": 'idle',
    'isAuthenticated': false,
    'user': null,
    'error': ''
  };

  void auth_load() async {
    final prefs = await SharedPreferences.getInstance();
    String? getUser = prefs.getString('user');

    if (getUser != '' && getUser != null) {
      var authData = jsonDecode(jsonDecode(getUser));
      authDetails['loading'] = 'success';
      authDetails['isAuthenticated'] = true;
      authDetails['user'] = AuthDetails.fromJson(authData);

      notifyListeners();
    } else {
      authDetails['loading'] = 'error';
      authDetails['isAuthenticated'] = false;

      notifyListeners();
    }
  }

  void auth_pending() {
    authDetails['loading'] = 'pending';
    authDetails['isAuthenticated'] = false;

    notifyListeners();
  }

  void auth_success(data) async {
    authDetails['loading'] = 'success';
    authDetails['isAuthenticated'] = true;
    authDetails['user'] = data;

    final prefs = await SharedPreferences.getInstance();
    String jsonValue = jsonEncode(data.toJson());
    prefs.setString('user', jsonEncode(jsonValue));

    notifyListeners();
  }

  void auth_failure(data) {
    authDetails['loading'] = 'error';
    authDetails['isAuthenticated'] = false;
    authDetails['error'] = data;
    notifyListeners();
  }

  void logout_user() async {
    authDetails['loading'] = 'idle';
    authDetails['isAuthenticated'] = false;
    authDetails['error'] = null;
    authDetails['user'] = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    notifyListeners();
  }

  Map<String, dynamic> get authData => authDetails;
}
