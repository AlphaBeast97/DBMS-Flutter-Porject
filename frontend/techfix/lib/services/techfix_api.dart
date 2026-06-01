/// HTTP client wrapping all TechFix backend REST endpoints.
///
/// Every method calls one backend route, parses JSON responses,
/// and throws [Exception] on non-2xx status codes with a
/// human-readable error message extracted from the response body.
///
/// Authentication uses HTTP Basic Auth with the email/password
/// passed to the constructor. The [createOwner] method is the only
/// public endpoint (no auth header required).
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:techfix/models/inventory_usage.dart';
import 'package:techfix/models/repair_job.dart';

class TechFixApi {
  TechFixApi({
    required this.baseUrl,
    required this.email,
    required this.password,
  });

  final String baseUrl;
  final String email;
  final String password;

  /// Builds HTTP Basic Auth header from stored credentials.
  Map<String, String> get _headers {
    final auth = base64Encode(utf8.encode('$email:$password'));
    return {'Authorization': 'Basic $auth', 'Content-Type': 'application/json'};
  }

  /// Parses error response JSON and returns a formatted message
  /// like `"Error 400: Invalid credentials."`.
  String _getErrorMessage(int statusCode, String response) {
    try {
      final body = jsonDecode(response) as Map<String, dynamic>;
      final message = body['message'] ?? body['error'] ?? response;
      return 'Error $statusCode: $message';
    } catch (_) {
      return 'Error $statusCode: ${response.isEmpty ? 'Unknown error' : response}';
    }
  }

  // ==============================
  //  AUTHENTICATION
  // ==============================

  /// POST /api/auth/employee
  /// Authenticates with email+password Basic Auth.
  /// Returns employee object: {employee_id, organization_id, name, email, role}.
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

  /// POST /api/auth/customer
  /// Authenticates with email-only Basic Auth (no password).
  /// Returns customer object: {customer_id, organization_id, name, phone, email}.
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

  // ==============================
  //  CUSTOMERS
  // ==============================

  /// GET /api/customers/:customerId
  /// Returns full customer profile with devices, repair jobs, and inventory usage.
  /// Used by employee/manager screens to view customer history.
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

  /// GET /api/customers/me
  /// Returns the authenticated customer's own data.
  /// Used by the customer self-service portal.
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

  /// POST /api/customers
  /// Creates a new customer under the authenticated employee's organization.
  /// Returns the new customer_id.
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

  // ==============================
  //  DEVICES
  // ==============================

  /// POST /api/devices
  /// Registers a new device under an existing customer.
  /// Returns the new device_id.
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

  // ==============================
  //  REPAIR JOBS
  // ==============================

  /// GET /api/repair-jobs
  /// Lists repair jobs. Optional query params:
  /// - status: filter by status (Pending, Repairing, Ready, Delivered, Cancelled)
  /// - organization_id: owner/manager view (all org jobs)
  /// Without org_id, returns only the authenticated employee's jobs.
  Future<List<Map<String, dynamic>>> getRepairJobs({String? status, int? organizationId}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (organizationId != null) queryParams['organization_id'] = organizationId.toString();
    final uri = Uri.parse(
      '$baseUrl/api/repair-jobs',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  /// POST /api/repair-jobs
  /// Creates a new repair job for a device.
  /// Returns the new job_id.
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

  /// PUT /api/repair-jobs/:jobId
  /// Updates the status of a repair job (e.g., Pending → Repairing).
  /// Returns the updated job data.
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

  /// PUT /api/repair-jobs/:jobId/description
  /// Updates the description (and optionally estimated cost) of a job.
  /// Returns the updated job data.
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

  /// POST /api/repair-jobs/:jobId/cancel
  /// Cancels a pending repair job (customer-only action).
  /// Returns the updated job data.
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

  // ==============================
  //  INVENTORY USAGE
  // ==============================

  /// POST /api/inventory-usage
  /// Logs a part used on a repair job.
  /// Returns the new usage_id.
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

  // ==============================
  //  EMPLOYEES
  // ==============================

  /// POST /api/employees/owner
  /// Public endpoint — creates a new organization + owner in one call.
  /// No auth header required. Returns org_id and owner_employee_id.
  Future<Map<String, dynamic>> createOwner({
    required String organizationName,
    required String ownerName,
    required String ownerEmail,
    required String password,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      Uri.parse('$baseUrl/api/employees/owner'),
      headers: headers,
      body: jsonEncode({
        'organization_name': organizationName,
        'owner_name': ownerName,
        'owner_email': ownerEmail,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_getErrorMessage(response.statusCode, response.body));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  /// POST /api/employees
  /// Creates a new employee under the authenticated owner's organization.
  /// Returns the new employee_id.
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

  // ==============================
  //  UTILITY: batch usage fetch
  // ==============================

  /// Fetches inventory usage for a list of jobs, grouped by job ID.
  /// Iterates over unique customer IDs in the job list and calls
  /// [getCustomerDetail] for each. Used by technician and manager screens.
  static Future<Map<int, List<InventoryUsage>>> fetchUsagesForJobs(
    TechFixApi api,
    List<RepairJob> jobs,
  ) async {
    final map = <int, List<InventoryUsage>>{};
    final customerIds = jobs.map((j) => j.customerId).whereType<int>().toSet();
    for (final cid in customerIds) {
      try {
        final detail = await api.getCustomerDetail(cid);
        final usageList = (detail['inventory_usage'] ?? []) as List<dynamic>;
        for (final u in usageList) {
          final inv = InventoryUsage.fromApi(u as Map<String, dynamic>);
          map.putIfAbsent(inv.jobId, () => []).add(inv);
        }
      } catch (_) {}
    }
    return map;
  }
}
