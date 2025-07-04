import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import '../../core/error/exceptions.dart';
import '../../core/storage/secure_storage.dart';

class ApiClient {
  final http.Client httpClient;
  final SecureStorage secureStorage;
  final String baseUrl;

  ApiClient({
    required this.httpClient,
    required this.secureStorage,
    required this.baseUrl,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await secureStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  String _buildUrl(String endpoint, {Map<String, String>? queryParams}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams).toString();
    }
    return uri.toString();
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final headers = await _getHeaders();

      final response = await httpClient.get(
        Uri.parse(url),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders();

      final response = await httpClient.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders();

      final response = await httpClient.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders();

      final response = await httpClient.delete(
        Uri.parse(url),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> multipartPost(
      String endpoint, {
        required Map<String, String> fields,
        required Map<String, String> files,
      }) async {
    try {
      final token = await secureStorage.getToken();
      final url = _buildUrl(endpoint);

      final request = http.MultipartRequest('POST', Uri.parse(url));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields.addAll(fields);

      // Add files
      for (final entry in files.entries) {
        final file = File(entry.value);
        final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
        final mediaType = MediaType.parse(mimeType);

        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            contentType: mediaType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return null;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      final errorBody = response.body.isNotEmpty
          ? json.decode(response.body)
          : {'message': 'Unknown error occurred'};
      throw ServerException(
        message: errorBody['message'] ?? 'Server error: ${response.statusCode}',
      );
    }
  }
}