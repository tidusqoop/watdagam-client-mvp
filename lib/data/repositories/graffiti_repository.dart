import 'package:flutter/material.dart';
import '../models/graffiti_note.dart';
import '../datasources/graffiti_datasource.dart';
import '../datasources/mock_graffiti_datasource.dart';

/// Repository for managing graffiti notes data
/// Acts as a single source of truth and abstracts the data source implementation
class GraffitiRepository {
  final GraffitiDataSource _dataSource;

  GraffitiRepository(this._dataSource);

  /// Get all graffiti notes
  Future<List<GraffitiNote>> getNotes() async {
    try {
      return await _dataSource.getAllNotes();
    } catch (e) {
      // Log error here in production
      print('Repository error - getNotes: $e');

      // For MVP, return empty list on error
      // In production, you might want to:
      // - Try fallback data source
      // - Cache previous results
      // - Show user-friendly error
      return [];
    }
  }

  /// Add a new graffiti note
  Future<GraffitiNote> addNote(GraffitiNote note) async {
    try {
      // Validate note before adding
      _validateNote(note);

      return await _dataSource.createNote(note);
    } catch (e) {
      print('Repository error - addNote: $e');
      rethrow; // Re-throw so UI can handle the error appropriately
    }
  }

  /// Update an existing graffiti note
  Future<GraffitiNote> updateNote(GraffitiNote note) async {
    try {
      _validateNote(note);

      return await _dataSource.updateNote(note);
    } catch (e) {
      print('Repository error - updateNote: $e');
      rethrow;
    }
  }

  /// Remove a graffiti note
  Future<void> removeNote(String id) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Note ID cannot be empty');
      }

      await _dataSource.deleteNote(id);
    } catch (e) {
      print('Repository error - removeNote: $e');
      rethrow;
    }
  }

  /// Get a single note by ID
  Future<GraffitiNote?> getNoteById(String id) async {
    try {
      if (id.isEmpty) {
        return null;
      }

      return await _dataSource.getNoteById(id);
    } catch (e) {
      print('Repository error - getNoteById: $e');
      return null;
    }
  }

  /// Validate note data
  void _validateNote(GraffitiNote note) {
    if (note.content.trim().isEmpty) {
      throw ArgumentError('Note content cannot be empty');
    }

    if (note.size.width <= 0 || note.size.height <= 0) {
      throw ArgumentError('Note size must be positive');
    }

    if (note.opacity < 0.0 || note.opacity > 1.0) {
      throw ArgumentError('Note opacity must be between 0.0 and 1.0');
    }
  }

  /// Business logic: Create note with auto-generated ID and timestamp
  Future<GraffitiNote> createNoteWithDefaults({
    required String content,
    required Color backgroundColor,
    required Offset position,
    Size? size,
    String? author,
    AuthorAlignment? authorAlignment,
    double? opacity,
    double? cornerRadius,
  }) async {
    final note = GraffitiNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      backgroundColor: backgroundColor,
      position: position,
      size: size ?? const Size(140, 100),
      author: author,
      authorAlignment: authorAlignment ?? AuthorAlignment.center,
      opacity: opacity ?? 0.7,
      cornerRadius: cornerRadius ?? 12.0,
    );

    return await addNote(note);
  }

  /// Business logic: Update note position (for drag operations)
  Future<GraffitiNote> updateNotePosition(String id, Offset newPosition) async {
    final note = await getNoteById(id);
    if (note == null) {
      throw ArgumentError('Note with id $id not found');
    }

    final updatedNote = note.copyWith(position: newPosition);
    return await updateNote(updatedNote);
  }

  /// Optimized drag update: immediate cache update + optional delayed persistence
  Future<GraffitiNote> updateNotePositionOptimized(String id, Offset newPosition) async {
    final note = await getNoteById(id);
    if (note == null) {
      throw ArgumentError('Note with id $id not found');
    }

    final updatedNote = note.copyWith(position: newPosition);

    // Try immediate update if datasource supports it
    try {
      if (_dataSource is dynamic && 
          (_dataSource as dynamic).updateNoteImmediate != null) {
        return await (_dataSource as dynamic).updateNoteImmediate(updatedNote);
      }
    } catch (e) {
      // Fallback to regular update if immediate update fails
      print('Immediate update failed, falling back to regular update: $e');
    }

    return await updateNote(updatedNote);
  }

  /// Synchronous cache-only update for immediate UI response
  void updateNoteInCacheOnly(GraffitiNote note) {
    try {
      if (_dataSource is dynamic && 
          (_dataSource as dynamic).updateNoteInCacheOnly != null) {
        (_dataSource as dynamic).updateNoteInCacheOnly(note);
      }
    } catch (e) {
      print('Cache-only update failed: $e');
    }
  }

  /// Business logic: Update note size (for resize operations)
  Future<GraffitiNote> updateNoteSize(String id, Size newSize) async {
    final note = await getNoteById(id);
    if (note == null) {
      throw ArgumentError('Note with id $id not found');
    }

    final updatedNote = note.copyWith(size: newSize);
    return await updateNote(updatedNote);
  }
}