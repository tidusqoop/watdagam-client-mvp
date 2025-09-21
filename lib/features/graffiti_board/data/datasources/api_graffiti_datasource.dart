import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/graffiti_note.dart';
import 'graffiti_datasource.dart';

/// API implementation of GraffitiDataSource using HTTP requests
/// This is a template implementation for future API integration
class ApiGraffitiDataSource implements GraffitiDataSource {
  final String baseUrl;
  final http.Client _httpClient;

  // API endpoints
  static const String _notesEndpoint = '/api/graffiti-notes';

  // Request timeout
  static const Duration _timeout = Duration(seconds: 10);

  ApiGraffitiDataSource(this.baseUrl, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Common headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add authentication headers here when needed
    // 'Authorization': 'Bearer $token',
  };

  @override
  Future<List<GraffitiNote>> getAllNotes() async {
    try {
      final uri = Uri.parse('$baseUrl$_notesEndpoint');
      final response = await _httpClient
          .get(uri, headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Expected API response format:
        // {
        //   "success": true,
        //   "data": [...graffiti_notes...],
        //   "total": 5
        // }
        final List<dynamic> notesJson = jsonData['data'] ?? [];

        return notesJson
            .map((noteJson) => GraffitiNoteJson.fromJson(noteJson as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          'Failed to load notes: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Request timeout', statusCode: 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  @override
  Future<GraffitiNote> createNote(GraffitiNote note) async {
    try {
      final uri = Uri.parse('$baseUrl$_notesEndpoint');
      final body = json.encode(note.toJson());

      final response = await _httpClient
          .post(uri, headers: _headers, body: body)
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Expected API response format:
        // {
        //   "success": true,
        //   "data": {...created_note...}
        // }
        return GraffitiNoteJson.fromJson(jsonData['data'] as Map<String, dynamic>);
      } else {
        throw ApiException(
          'Failed to create note: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Request timeout', statusCode: 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  @override
  Future<GraffitiNote> updateNote(GraffitiNote note) async {
    try {
      final uri = Uri.parse('$baseUrl$_notesEndpoint/${note.id}');
      final body = json.encode(note.toJson());

      final response = await _httpClient
          .put(uri, headers: _headers, body: body)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return GraffitiNoteJson.fromJson(jsonData['data'] as Map<String, dynamic>);
      } else {
        throw ApiException(
          'Failed to update note: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Request timeout', statusCode: 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      final uri = Uri.parse('$baseUrl$_notesEndpoint/$id');

      final response = await _httpClient
          .delete(uri, headers: _headers)
          .timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          'Failed to delete note: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Request timeout', statusCode: 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  @override
  Future<GraffitiNote?> getNoteById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl$_notesEndpoint/$id');
      final response = await _httpClient
          .get(uri, headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return GraffitiNoteJson.fromJson(jsonData['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ApiException(
          'Failed to get note: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Request timeout', statusCode: 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Dispose HTTP client
  void dispose() {
    _httpClient.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (${statusCode})' : ''}';
}