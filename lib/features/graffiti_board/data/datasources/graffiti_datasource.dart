import '../models/graffiti_note.dart';

/// Abstract interface for graffiti note data operations
/// This allows switching between different data sources (Mock, API, Local DB, etc.)
abstract class GraffitiDataSource {
  /// Retrieve all graffiti notes
  Future<List<GraffitiNote>> getAllNotes();

  /// Create a new graffiti note
  Future<GraffitiNote> createNote(GraffitiNote note);

  /// Update an existing graffiti note
  Future<GraffitiNote> updateNote(GraffitiNote note);

  /// Delete a graffiti note by ID
  Future<void> deleteNote(String id);

  /// Get a single graffiti note by ID (optional for future use)
  Future<GraffitiNote?> getNoteById(String id) async {
    final notes = await getAllNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}