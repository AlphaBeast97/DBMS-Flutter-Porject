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

  // Build Basic Auth headers
  Map<String, String> get _headers {
    final auth = base64Encode(utf8.encode('$email:$password'));
    return {'Authorization': 'Basic $auth', 'Content-Type': 'application/json'};
  }

  // Helper method to parse error response with status code
  String _getErrorMessage(int statusCode, String response) {
    try {
      final body = jsonDecode(response) as Map<String, dynamic>;
      final message = body['message'] ?? body['error'] ?? response;
      return 'Error $statusCode: $message';
    } catch (_) {
      return 'Error $statusCode: ${response.isEmpty ? 'Unknown error' : response}';
    }
  }

  // ========== AUTHENTICATION ==========

  /// POST /api/auth/employee - Authenticate as employee
  Future<Map<String, dynamic>> authenticateEmployee() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/employee'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  /// POST /api/auth/customer - Authenticate as customer (email only in auth)
  Future<Map<String, dynamic>> authenticateCustomer(String email) async {
    final auth = base64Encode(utf8.encode('$email:'));
    final headers = {
      'Authorization': 'Basic $auth',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/customer'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  // ========== CUSTOMERS ==========

  /// GET /api/customers/:id - Get customer with devices and repair jobs
  Future<Map<String, dynamic>> getCustomerDetail(int customerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customers/$customerId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  /// GET /api/customers/me - Get authenticated customer's own data
  Future<Map<String, dynamic>> getCustomerMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customers/me'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  /// POST /api/customers - Create a new customer
  Future<int> createCustomer({
    required String name,
    required String phone,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/customers'),
      headers: _headers,
      body: jsonEncode({'name': name, 'phone': phone, 'email': email}),
    );

    if (response.statusCode != 201) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data']['customer_id'] as int;
  }

  // ========== DEVICES ==========

  /// POST /api/devices - Register a new device for a customer
  Future<int> createDevice({
    required int customerId,
    required String type,
    required String brand,
    required String model,
    required String serialNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/devices'),
      headers: _headers,
      body: jsonEncode({
        'customer_id': customerId,
        'type': type,
        'brand': brand,
        'model': model,
        'serial_number': serialNumber,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data']['device_id'] as int;
  }

  // ========== REPAIR JOBS ==========

  /// GET /api/repair-jobs - Get all repair jobs (optionally filtered by status)
  Future<List<Map<String, dynamic>>> getRepairJobs({String? status}) async {
    final uri = Uri.parse(
      '$baseUrl/api/repair-jobs',
    ).replace(queryParameters: status == null ? null : {'status': status});
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  /// POST /api/repair-jobs - Create a new repair job
  Future<int> createRepairJob({
    required int deviceId,
    required String description,
    required double estimatedCost,
    String status = 'Pending',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/repair-jobs'),
      headers: _headers,
      body: jsonEncode({
        'device_id': deviceId,
        'description': description,
        'estimated_cost': estimatedCost,
        'status': status,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data']['job_id'] as int;
  }

  /// PUT /api/repair-jobs/:job_id - Update repair job status
  Future<Map<String, dynamic>> updateRepairJobStatus({
    required int jobId,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/repair-jobs/$jobId'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  /// PUT /api/repair-jobs/:job_id/description - Update repair job description
  Future<Map<String, dynamic>> updateJobDescription({
    required int jobId,
    required String description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/repair-jobs/$jobId/description'),
      headers: _headers,
      body: jsonEncode({'description': description}),
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  /// POST /api/repair-jobs/:job_id/cancel - Cancel a repair job
  Future<Map<String, dynamic>> cancelRepairJob(int jobId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/repair-jobs/$jobId/cancel'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  // ========== INVENTORY USAGE ==========

  /// POST /api/inventory-usage - Log parts used on a repair job
  Future<int> logPartUsage({
    required int jobId,
    required String partName,
    required double partCost,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/inventory-usage'),
      headers: _headers,
      body: jsonEncode({
        'job_id': jobId,
        'part_name': partName,
        'part_cost': partCost,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data']['usage_id'] as int;
  }

  // ========== EMPLOYEES ==========

  /// POST /api/employees - Create a new employee (Owner/Manager only)
  Future<int> createEmployee({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/employees'),
      headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data']['employee_id'] as int;
  }

}
