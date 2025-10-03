import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:inter/src/features/analysis/application/analysis_service.dart';
import 'package:inter/src/features/notes/data/notes_service.dart';
import '../domain/folder_item.dart';
import '../domain/note_item.dart';
part 'notes_provider.g.dart';

@Riverpod(keepAlive: true)
NotesService notesService(Ref ref) {
  return NotesService();
}

@Riverpod(keepAlive: true)
class Notes extends _$Notes {
  @override
  Future<List<FolderItem>> build() async {
    final notesService = ref.watch(notesServiceProvider);
    final folders = await notesService.loadFoldersAndNotes();
    if (!folders.any((f) => f.id == 'uncategorized')) {
      final uncategorized = await notesService.createFolder('Uncategorized',id:'uncategorized');
      folders.insert(0, uncategorized);
    }
    if (ref.read(selectedNoteIdProvider) == null && folders.isNotEmpty && folders.first.notes.isNotEmpty) {
      ref.read(selectedNoteIdProvider.notifier).select(folders.first.notes.first.id);
    }
    return folders;
  }
  Future<void> _reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(notesServiceProvider).loadFoldersAndNotes());
  }
  Future<void> createNewNote([String? folderId]) async {
    final notesService = ref.read(notesServiceProvider);
    folderId ??= state.value!.firstWhere((f) => f.id == 'uncategorized').id;
    final folder = state.value!.firstWhere((f) => f.id == folderId);
    final newNote = await notesService.createNote(folder, 'New Note');
    await _reload();
    ref.read(selectedNoteIdProvider.notifier).select(newNote.id);
  }
  Future<void> createNewFolder(String title) async {
    await ref.read(notesServiceProvider).createFolder(title);
    await _reload();
  }
  Future<void> deleteNote(String noteId) async {
    final notesService = ref.read(notesServiceProvider);
    final note = _findNoteById(noteId);
    if (note != null) {
      await notesService.deleteNote(note);
      await _reload();
    }
  }
  Future<void> deleteFolder(String folderId) async {
    final notesService = ref.read(notesServiceProvider);
    final folder = state.value?.firstWhere((f) => f.id == folderId);
    if (folder != null) {
      await notesService.deleteFolder(folder);
      await _reload();
    }
  }
  Future<void> renameNote(String noteId, String newTitle) async {
    final notesService = ref.read(notesServiceProvider);
    final note = _findNoteById(noteId);
    if (note != null) {
      await notesService.renameNote(note, newTitle);
      await _reload();
    }
  }
  Future<void> renameFolder(String folderId, String newTitle) async {
    final notesService = ref.read(notesServiceProvider);
    final folder = state.value?.firstWhere((f) => f.id == folderId);
    if (folder != null) {
      await notesService.renameFolder(folder, newTitle);
      await _reload();
    }
  }
  Future<void> moveNote(String noteId, int oldFolderIndex, int newFolderIndex) async {
      final notesService = ref.read(notesServiceProvider);
      final note = _findNoteById(noteId);
      final newFolder = state.value![newFolderIndex];
      if (note != null) {
        await notesService.moveNote(note, newFolder);
        await _reload();
      }
  }
  Future<void> updateNote(NoteItem note) async {
    final notesService = ref.read(notesServiceProvider);
    await notesService.updateNote(note);
  }
  NoteItem? _findNoteById(String noteId) {
    for (final folder in state.value!) {
      for (final note in folder.notes) {
        if (note.id == noteId) return note;
      }
    }
    return null;
  }
}

@riverpod
class SelectedNoteId extends _$SelectedNoteId {
  @override
  String? build() => null;
  void select(String? noteId) {
    state = noteId;
  }
}

@riverpod
Future<NoteItem?> selectedNote(Ref ref) async {
  final notesService = ref.watch(notesServiceProvider);
  final selectedId = ref.watch(selectedNoteIdProvider);
  final folders = ref.watch(notesProvider).value;
  if (selectedId == null || folders == null) return null;
  for (var folder in folders) {
    for (var note in folder.notes) {
      if (note.id == selectedId) {
        final content = await notesService.readNoteContent(note);
        return note.copyWith(content: content);
      }
    }
  }
  return null;
}

@riverpod
Future<AnalysisResult?> noteAnalysis(Ref ref) async {
  final note = await ref.watch(selectedNoteProvider.future);
  if (note == null) {
    return null;
  }
  final analysisService = await ref.watch(analysisServiceProvider.future);
  return analysisService.analyze(note.content);
}
