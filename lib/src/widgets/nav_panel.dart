import 'dart:developer';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/notes/domain/folder_item.dart';
import '../features/notes/domain/note_item.dart';

class NavPanel extends StatefulWidget {
  const NavPanel({super.key});

  @override
  State<NavPanel> createState() => _NavPanelState();
}

class _NavPanelState extends State<NavPanel> {
  String _selectedNoteId = '';
  static const String _uncategorizedFolderId = 'uncategorized';

  @override
  void initState() {
    super.initState();
    if (_folders.isNotEmpty && _folders.first.notes.isNotEmpty) {
      _selectedNoteId = _folders.first.notes.first.id;
    }
  }
  final List<FolderItem> _folders = [
    FolderItem(id: _uncategorizedFolderId, title: 'Uncategorized', notes: [
      NoteItem(id: 'n0a', title: 'Welcome Note'),
    ]),
    FolderItem(id: 'f1', title: 'Project Inter', notes: [
      NoteItem(id: 'n1a', title: 'Architecture Plan'),
      NoteItem(id: 'n1b', title: 'UI Mockups'),
    ]),
    FolderItem(id: 'f2', title: 'Meeting Notes', notes: []), 
    FolderItem(id: 'f3', title: 'Archived', notes: [
      NoteItem(id: 'n3a', title: 'Old Idea'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    log('--- Build method called ---');
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:
            const Text('Inter', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewNote,
        tooltip: 'Add New Note',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: DragAndDropLists(
              children: _buildLists(context),
              onItemReorder: _onItemReorder,
              onListReorder: _onListReorder,
              listDragHandle: const DragHandle(
                verticalAlignment: DragHandleVerticalAlignment.top,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
              ),
              itemDragHandle: DragHandle(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.drag_indicator, color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
  List<DragAndDropList> _buildLists(BuildContext context) {
    return _folders.map((folder) {
      final header = Padding(
        padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Text(folder.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      );
      final children = folder.notes.isEmpty
          ? [
              DragAndDropItem(
                canDrag: false,
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical:2.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Drop notes here',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
              )
            ]
          : folder.notes.map((note) {
              return DragAndDropItem(
                key: ValueKey(note.id), 
                child: Dismissible(
                  key: ValueKey('${note.id}_dismissible'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) =>
                      _showDeleteConfirmationDialog(note.title),
                  onDismissed: (direction) => _deleteNote(note.id),
                  background: _buildDeleteBackground(),
                  child: ListTile(
                    leading: const Icon(Icons.notes_rounded),
                    title: Text(note.title),
                    selected: note.id == _selectedNoteId,
                    selectedTileColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    onTap: () => _selectNote(note.id),
                  ),
                ),
              );
            }).toList();
      return DragAndDropList(
        key: ValueKey(folder.id), 
        header: header,
        children: children,
      );
    }).toList();
  }
  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: const Icon(Icons.delete_forever, color: Colors.white),
    );
  }
  void _debugPrintState(String trigger) {
    log('--- Triggered by: $trigger ---');
    for (var folder in _folders) {
      final noteTitles = folder.notes.map((n) => n.title).toList();
      log('Folder "${folder.title}": $noteTitles');
    }
    log('-----------------------------------');
  }
  void _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      final movedItem = _folders[oldListIndex].notes.removeAt(oldItemIndex);
      if (_folders[newListIndex].notes.isEmpty) {
        newItemIndex = 0;
      }
      _folders[newListIndex].notes.insert(newItemIndex, movedItem);
    });
    _debugPrintState('onItemReorder');
  }
  void _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      if (oldListIndex == 0 || newListIndex == 0) return;
      final movedList = _folders.removeAt(oldListIndex);
      _folders.insert(newListIndex, movedList);
    });
    _debugPrintState('onListReorder');
  }
  void _selectNote(String noteId) {
    setState(() {
      _selectedNoteId = noteId;
    });
  }
  void _addNewNote() {
    setState(() {
      final newNote = NoteItem(
        id: DateTime.now().toIso8601String(),
        title: 'New Note',
      );
      int folderIndex = -1;
      int noteIndex = -1;
      if (_selectedNoteId.isNotEmpty) {
        for (int i = 0; i < _folders.length; i++) {
          noteIndex =
              _folders[i].notes.indexWhere((n) => n.id == _selectedNoteId);
          if (noteIndex != -1) {
            folderIndex = i;
            break;
          }
        }
      }
      if (folderIndex != -1 && noteIndex != -1) {
        _folders[folderIndex].notes.insert(noteIndex + 1, newNote);
      } else {
        _folders
            .firstWhere((f) => f.id == _uncategorizedFolderId)
            .notes
            .add(newNote);
      }
      _selectedNoteId = newNote.id;
    });
    _debugPrintState('addNewNote');
  }
  void _deleteNote(String noteId) {
    setState(() {
      if (_selectedNoteId == noteId) {
        _selectNextNoteAfterDeletion(noteId);
      }
      for (var folder in _folders) {
        folder.notes.removeWhere((n) => n.id == noteId);
      }
    });
    _debugPrintState('deleteNote');
  }
  void _selectNextNoteAfterDeletion(String deletedNoteId) {
    int folderIndex = -1;
    int noteIndex = -1;
    for (int i = 0; i < _folders.length; i++) {
      noteIndex = _folders[i].notes.indexWhere((n) => n.id == deletedNoteId);
      if (noteIndex != -1) {
        folderIndex = i;
        break;
      }
    }
    if (folderIndex != -1) {
      if (_folders[folderIndex].notes.length > 1) {
        _selectedNoteId = noteIndex == _folders[folderIndex].notes.length - 1
            ? _folders[folderIndex].notes[noteIndex - 1].id
            : _folders[folderIndex].notes[noteIndex + 1].id;
      } else {
        _selectFirstAvailableNote();
      }
    }
  }
  void _selectFirstAvailableNote() {
    _selectedNoteId = '';
    for (final folder in _folders) {
      if (folder.notes.isNotEmpty) {
        _selectedNoteId = folder.notes.first.id;
        break;
      }
    }
  }
  Future<bool?> _showDeleteConfirmationDialog(String itemName) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "$itemName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
}
