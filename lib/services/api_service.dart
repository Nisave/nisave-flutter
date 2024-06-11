import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String authBaseUrl = 'http://payments.nisave.co.ke:8080/auth';
  final String mpesaBaseUrl = 'http://payments.nisave.co.ke:8080/mpesa';
  final String otpBaseUrl = 'http://payments.nisave.co.ke:8080/otp';

  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    final Uri uri = Uri.parse('$authBaseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'phone_number': phoneNumber, 'password': password});

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login. ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(String phone, String firstName, String lastName, String password, String token) async {
    final Uri uri = Uri.parse('$authBaseUrl/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'phone_number': phone,
      'password': password,
      'token': token
    });

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register. ${response.body}');
    }
  }

  Future<http.Response> resetPassword(String phoneNumber) async {
    final Uri uri = Uri.parse('$authBaseUrl/resetPassword');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'phone_number': phoneNumber});

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to reset password. ${response.body}');
    }
    return response;
  }

  Future<http.Response> changePassword(String password, String token) async {
    final Uri uri = Uri.parse('$authBaseUrl/change-password');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $token',
    };
    final body = jsonEncode({'password': password});

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to change password. ${response.body}');
    }
    return response;
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final Uri uri = Uri.parse('$authBaseUrl/profile');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch profile. ${response.body}');
    }
  }

  Future<http.Response> sendSTKPushRequest(String accessToken, String body) async {
    final Uri uri = Uri.parse('$mpesaBaseUrl/stk-request');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $accessToken',
    };

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to send STK push request. ${response.body}');
    }
    return response;
  }

  Future<http.Response> sendB2CWalletRequest(String accessToken, String body) async {
    final Uri uri = Uri.parse('$mpesaBaseUrl/b2c-request/wallet');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $accessToken',
    };

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to send B2C wallet request. ${response.body}');
    }
    return response;
  }

  Future<http.Response> sendB2CFundraiserRequest(String accessToken, String body) async {
    final Uri uri = Uri.parse('$mpesaBaseUrl/b2c-request/fundraiser');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $accessToken',
    };

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to send B2C fundraiser request. ${response.body}');
    }
    return response;
  }

  Future<http.Response> sendB2BBuyGoodsRequest(String accessToken, String body) async {
    final Uri uri = Uri.parse('$mpesaBaseUrl/b2b-request/wallet/buygoods');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $accessToken',
    };

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to send B2B buy goods request. ${response.body}');
    }
    return response;
  }

  Future<http.Response> sendB2BPaybillRequest(String accessToken, String body) async {
    final Uri uri = Uri.parse('$mpesaBaseUrl/b2b-request/wallet/paybill');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $accessToken',
    };

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to send B2B paybill request. ${response.body}');
    }
    return response;
  }

  Future<http.Response> sendB2BFundraiserBuyGoodsRequest(String accessToken, String body) async {
    final Uri uri = Uri.parse('$mpesaBaseUrl/b2b-request/fundraiser/buygoods');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $accessToken',
    };

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to send B2B fundraiser buy goods request. ${response.body}');
    }
    return response;
  }

  Future<http.Response> sendB2BFundraiserPaybillRequest(String accessToken, String body) async {
    final Uri uri = Uri.parse('$mpesaBaseUrl/b2b-request/fundraiser/paybill');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $accessToken',
    };

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to send B2B fundraiser paybill request. ${response.body}');
    }
    return response;
  }

  Future<http.Response> requestOTP(String accessToken) async {
    final Uri uri = Uri.parse('$otpBaseUrl/request');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $accessToken',
    };

    final response = await http.post(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to request OTP. ${response.body}');
    }
    return response;
  }

  Future<http.Response> validateOTP(String accessToken, String otp) async {
    final Uri uri = Uri.parse('$otpBaseUrl/validation');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $accessToken',
    };
    final body = jsonEncode({'otp': otp});

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to validate OTP. ${response.body}');
    }
    return response;
  }

  Future<http.Response> sendRequest(String accessToken, String endpoint, Map<String, dynamic> body) async {
    final Uri uri = Uri.parse('$mpesaBaseUrl/$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $accessToken',
    };

    final response = await http.post(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode != 200) {
      throw Exception('Failed to send request. ${response.body}');
    }
    return response;
  }
}
