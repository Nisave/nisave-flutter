import 'package:flutter/material.dart';
import 'package:nisave/services/api_service.dart';

class RegisterState with ChangeNotifier {
  final ApiService apiService = ApiService();

  Future<bool> register(String phone, String firstName, String lastName, String pin, String token) async {
    try {
      var response = await apiService.register(phone, firstName, lastName, pin, token);
      if (response['status'] == 'Success') {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }
}
