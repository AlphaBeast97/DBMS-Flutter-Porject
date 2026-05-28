import 'dart:convert';

import 'package:http/http.dart' as http;

class TechFixApi {
  TechFixApi({
    required this.baseUrl,
    required this.email,
    required this.password,
  });

  final String baseUrl;
  final String email;
  final String password;

  Map<String, String> get _headers {
    final auth = base64Encode(utf8.encode('$email:$password'));
    return {'Authorization': 'Basic $auth', 'Content-Type': 'application/json'};
  }

  Future<Map<String, dynamic>> authenticateEmployee() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/employee'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Auth failed: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getRepairJobs({String? status}) async {
    final uri = Uri.parse(
      '$baseUrl/api/repair-jobs',
    ).replace(queryParameters: status == null ? null : {'status': status});
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load repair jobs');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getCustomerDetail(int customerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customers/$customerId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Customer lookup failed');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }
}
