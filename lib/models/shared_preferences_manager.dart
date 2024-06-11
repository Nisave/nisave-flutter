import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static SharedPreferences? _prefs;

  static Future initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setUserDetails(String firstName, String lastName, String accessToken, String phoneNo, String walletBalance) async {
    return await _prefs!.setString('firstName', firstName) &&
           await _prefs!.setString('lastName', lastName) &&
           await _prefs!.setString('accessToken', accessToken) &&
           await _prefs!.setString('phoneNo', phoneNo) &&
           await _prefs!.setString('walletBalance', walletBalance) && // Saving wallet balance
           await _prefs!.setBool('isLoggedIn', true);
  }

  static String? getFirstName() => _prefs?.getString('firstName');
  static String? getLastName() => _prefs?.getString('lastName');
  static String? getAccessToken() => _prefs?.getString('accessToken');
  static String? getPhoneNo() => _prefs?.getString('phoneNo');
  static String? getWalletBalance() => _prefs?.getString('walletBalance'); // Retrieving wallet balance
  static bool isLoggedIn() => _prefs?.getBool('isLoggedIn') ?? false;

  static Future<void> logout() async {
    await _prefs!.clear();
  }
}
