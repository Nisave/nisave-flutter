import 'package:flutter/material.dart';
import 'package:nisave/services/api_service.dart';
import 'package:nisave/models/shared_preferences_manager.dart';

class LoginState with ChangeNotifier {
  final ApiService apiService = ApiService();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String phoneNumber, String pin) async {
    try {
      var response = await apiService.login(phoneNumber, pin);
      if (response['accessToken'] != null) {
        await SharedPreferencesManager.setUserDetails(
          response['user']['firstName'],
          response['user']['lastName'],
          response['accessToken'],
          phoneNumber,
          response['user']['wallet_amount'].toString(),
        );
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> checkLoginStatus() async {
    _isLoggedIn = SharedPreferencesManager.isLoggedIn();
    notifyListeners();
  }

  Future<void> logout() async {
    await SharedPreferencesManager.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
