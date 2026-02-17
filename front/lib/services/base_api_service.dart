import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base class for all API services
abstract class BaseApiService {
  
  BaseApiService(this.baseUrl);
  
  final String baseUrl;
  
  final http.Client httpClient = http.Client();
  
  /// Helper method to make GET requests
  Future<T> get<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl$endpoint'),
      );
      
      if (response.statusCode == 200) {
        final json = _parseJson(response.body);
        return parser(json);
      } else {
        throw Exception('Erro ao chamar API: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Helper method to make POST requests
  Future<T> post<T>(
    String endpoint, {
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: _encodeJson(body),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = _parseJson(response.body);
        return parser(json);
      } else {
        throw Exception('Erro ao chamar API: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Helper method to make PUT requests
  Future<T> put<T>(
    String endpoint, {
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      final response = await httpClient.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: _encodeJson(body),
      );
      
      if (response.statusCode == 200) {
        final json = _parseJson(response.body);
        return parser(json);
      } else {
        throw Exception('Erro ao chamar API: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Parse JSON response
  Map<String, dynamic> _parseJson(String body) =>
      json_decode(body) as Map<String, dynamic>? ?? {};
  
  /// Encode JSON request
  String _encodeJson(Map<String, dynamic> body) => json_encode(body);
}

/// Simple JSON encoding/decoding
String json_encode(Map<String, dynamic> data) => _mapToJson(data);

Map<String, dynamic> json_decode(String jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>;

String _mapToJson(Map<String, dynamic> map) {
  final entries = map.entries.map((e) {
    final key = '"${e.key}"';
    final value = _valueToJson(e.value);
    return '$key:$value';
  }).join(',');
  return '{$entries}';
}

String _valueToJson(dynamic value) {
  if (value == null) {
    return 'null';
  }
  if (value is String) {
    return '"$value"';
  }
  if (value is num) {
    return value.toString();
  }
  if (value is bool) {
    return value.toString();
  }
  if (value is Map) {
    return _mapToJson(value as Map<String, dynamic>);
  }
  if (value is List) {
    return '[${value.map(_valueToJson).join(',')}]';
  }
  return value.toString();
}
