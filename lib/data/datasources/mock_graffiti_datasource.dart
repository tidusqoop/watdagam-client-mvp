import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/graffiti_note.dart';
import 'graffiti_datasource.dart';

/// Mock implementation of GraffitiDataSource using JSON file
/// Simulates API responses with realistic delays
class MockGraffitiDataSource implements GraffitiDataSource {
  List<GraffitiNote>? _cachedNotes;
  static const String _jsonAssetPath = 'lib/data/mock/graffiti_notes.json';

  // Simulate network delay for realistic testing
  static const Duration _networkDelay = Duration(milliseconds: 500);

  @override
  Future<List<GraffitiNote>> getAllNotes() async {
    // Simulate network delay
    await Future.delayed(_networkDelay);

    if (_cachedNotes != null) {
      return List.from(_cachedNotes!);
    }

    try {
      // Load JSON from assets
      final String jsonString = await rootBundle.loadString(_jsonAssetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _cachedNotes = (jsonData['graffiti_notes'] as List)
          .map((noteJson) => GraffitiNoteJson.fromJson(noteJson as Map<String, dynamic>))
          .toList();

      return List.from(_cachedNotes!);
    } catch (e) {
      print('Error loading mock data: $e');
      // Return empty list if JSON loading fails
      _cachedNotes = [];
      return [];
    }
  }

  @override
  Future<GraffitiNote> createNote(GraffitiNote note) async {
    // Simulate network delay
    await Future.delayed(_networkDelay);

    _cachedNotes ??= await getAllNotes();

    // Ensure unique ID
    final newNote = note.copyWith(
      id: note.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : note.id
    );

    _cachedNotes!.add(newNote);
    return newNote;
  }

  @override
  Future<GraffitiNote> updateNote(GraffitiNote note) async {
    // Simulate network delay
    await Future.delayed(_networkDelay);

    _cachedNotes ??= await getAllNotes();

    final index = _cachedNotes!.indexWhere((n) => n.id == note.id);
    if (index == -1) {
      throw Exception('Note with id ${note.id} not found');
    }

    _cachedNotes![index] = note;
    return note;
  }

  @override
  Future<void> deleteNote(String id) async {
    // Simulate network delay
    await Future.delayed(_networkDelay);

    _cachedNotes ??= await getAllNotes();

    final initialLength = _cachedNotes!.length;
    _cachedNotes!.removeWhere((note) => note.id == id);

    if (_cachedNotes!.length == initialLength) {
      throw Exception('Note with id $id not found');
    }
  }

  /// Clear cache - useful for testing or force refresh
  void clearCache() {
    _cachedNotes = null;
  }

  /// Get current cache size - useful for debugging
  int get cacheSize => _cachedNotes?.length ?? 0;

  @override
  Future<GraffitiNote?> getNoteById(String id) async {
    _cachedNotes ??= await getAllNotes();

    try {
      return _cachedNotes!.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}