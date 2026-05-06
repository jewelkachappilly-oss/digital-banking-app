import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class Api {
  // Android emulator: 10.0.2.2. Real phone: replace with PC IP using --dart-define=API_BASE_URL=http://192.168.x.x:8000
  static const String base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

  static Map<String, dynamic> _decode(http.Response res) {
    final data = jsonDecode(res.body.isEmpty ? '{}' : res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) throw ApiException(data['error']?.toString() ?? 'Server error');
    return data;
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String pin) async {
    final res = await http.post(Uri.parse('$base/accounts/register/'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'name': name, 'email': email, 'password': password, 'pin': pin}));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    final res = await http.post(Uri.parse('$base/accounts/login/'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': identifier, 'identifier': identifier, 'password': password}));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> profile(int userId) async {
    final res = await http.get(Uri.parse('$base/accounts/profile/$userId/'));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> sendOtp(int userId) async {
    final res = await http.get(Uri.parse('$base/payments/otp/?user_id=$userId'));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> pay(int sender, String upi, double amount, String pin, String otp, {String remark = 'UPI Payment'}) async {
    final res = await http.post(Uri.parse('$base/payments/pay/'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'sender': sender, 'upi': upi, 'amount': amount, 'pin': pin, 'otp': otp, 'remark': remark}));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> servicePay(int userId, String service, double amount, {String customer = ''}) async {
    final res = await http.post(Uri.parse('$base/payments/service-pay/'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'user_id': userId, 'service': service, 'amount': amount, 'customer': customer}));
    return _decode(res);
  }

  static Future<List<dynamic>> transactions(int userId) async {
    final res = await http.get(Uri.parse('$base/payments/transactions/$userId/'));
    final data = _decode(res);
    return data['transactions'] as List<dynamic>;
  }
}
