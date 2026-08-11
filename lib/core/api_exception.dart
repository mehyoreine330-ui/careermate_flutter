import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown by [ApiService] on any non-2xx response or transport failure.
/// Carries the FastAPI `detail` message when the backend returned one,
/// so UI code can show a meaningful error instead of a raw stack trace.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromResponse(http.Response response) {
    String detail = 'Request failed with status ${response.statusCode}';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['detail'] != null) {
        detail = body['detail'].toString();
      }
    } catch (_) {
      // Response body wasn't JSON — fall back to the generic message above.
    }
    return ApiException(detail, statusCode: response.statusCode);
  }

  @override
  String toString() => 'ApiException(${statusCode ?? '-'}): $message';
}
