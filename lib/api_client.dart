import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  String serverUrl = 'http://157.22.204.49:8000';

  Future<List<dynamic>> getCars() async {
    final res = await http.get(Uri.parse('$serverUrl/cars'))
        .timeout(const Duration(seconds: 10));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> addMileage(int carId, int mileage, {String? notes}) async {
    final res = await http.post(
      Uri.parse('$serverUrl/mileages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'car_id': carId, 'mileage': mileage, 'notes': notes}),
    ).timeout(const Duration(seconds: 10));
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getMileages({int? carId}) async {
    final uri = Uri.parse('$serverUrl/mileages').replace(queryParameters: carId != null ? {'car_id': '$carId'} : null);
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> addPayment(int carId, double amount, {int? clientId, String? method}) async {
    final res = await http.post(
      Uri.parse('$serverUrl/payments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'car_id': carId, 'amount': amount, 'client_id': clientId, 'method': method}),
    ).timeout(const Duration(seconds: 10));
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getPayments({int? carId}) async {
    final uri = Uri.parse('$serverUrl/payments').replace(queryParameters: carId != null ? {'car_id': '$carId'} : null);
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    return jsonDecode(res.body);
  }
}