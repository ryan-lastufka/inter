import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../domain/folder_item.dart';
import '../domain/note_item.dart';

class NotesService {
  final _uuid = const Uuid();
  Future<Directory> _getRootDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory(p.join(appDir.path, 'InterNotes'));
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    return notesDir;
  }
  Future<List<FolderItem>> loadFoldersAndNotes() async {
    final rootDir = await _getRootDirectory();
    final entities = rootDir.listSync();
    final folders = <FolderItem>[];
    for (final entity in entities) {
      if (entity is Directory) {
        final metaFile = File(p.join(entity.path, 'group.meta'));
        if (await metaFile.exists()) {
          final metaContent = jsonDecode(await metaFile.readAsString());
          final notes = await _loadNotesFromFolder(entity);
          folders.add(FolderItem(
            id: p.basename(entity.path),
            title: metaContent['title'] ?? 'Untitled Folder',
            path: entity.path,
            notes: notes,
          ));
        }
      }
    }
    return folders;
  }
  Future<List<NoteItem>> _loadNotesFromFolder(Directory folderDir) async {
    final notes = <NoteItem>[];
    final entities = folderDir.listSync();
    for (final entity in entities) {
      if (entity is File && p.extension(entity.path) == '.md') {
        notes.add(NoteItem(
          id: p.basenameWithoutExtension(entity.path),
          title: p.basenameWithoutExtension(entity.path),
          path: entity.path,
        ));
      }
    }
    return notes;
  }
  Future<NoteItem> createNote(FolderItem folder, String title) async {
    final safeTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
    final noteFile = File(p.join(folder.path, '$safeTitle.md'));
    final newNote = NoteItem(
      id: safeTitle,
      title: safeTitle,
      path: noteFile.path,
      content: '# $safeTitle\n\n',
    );
    await noteFile.writeAsString(newNote.content);
    return newNote;
  }
  Future<FolderItem> createFolder(String title, {String? id}) async {
    final rootDir = await _getRootDirectory();
    final folderId = id ?? _uuid.v4();
    final folderDir = Directory(p.join(rootDir.path, folderId));
    await folderDir.create();
    final metaFile = File(p.join(folderDir.path, 'group.meta'));
    await metaFile.writeAsString(jsonEncode({'title': title}));
    return FolderItem(
      id: folderId,
      title: title,
      path: folderDir.path,
      notes: []
    );
  }
  Future<void> deleteNote(NoteItem note) async {
    final file = File(note.path);
    if (await file.exists()) {
      await file.delete();
    }
  }
  Future<void> deleteFolder(FolderItem folder) async {
    final dir = Directory(folder.path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
  Future<NoteItem> renameNote(NoteItem note, String newTitle) async {
    final safeTitle = newTitle.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
    final newPath = p.join(p.dirname(note.path), '$safeTitle.md');
    await File(note.path).rename(newPath);
    return NoteItem(
        id: safeTitle, title: safeTitle, path: newPath, content: note.content);
  }
  Future<void> renameFolder(FolderItem folder, String newTitle) async {
    final metaFile = File(p.join(folder.path, 'group.meta'));
    if (await metaFile.exists()) {
      await metaFile.writeAsString(jsonEncode({'title': newTitle}));
    }
  }
  Future<NoteItem> moveNote(NoteItem note, FolderItem newFolder) async {
    final newPath = p.join(newFolder.path, p.basename(note.path));
    await File(note.path).rename(newPath);
    return note.copyWith(path: newPath);
  }
  Future<String> readNoteContent(NoteItem note) async {
    final file = File(note.path);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return '';
  }
  Future<void> updateNote(NoteItem note) async {
    final file = File(note.path);
    await file.writeAsString(note.content);
  }
}
