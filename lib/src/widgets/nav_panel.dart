import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:go_router/go_router.dart';
import '../features/notes/application/notes_provider.dart';
import '../features/notes/domain/folder_item.dart';
import '../features/notes/domain/note_item.dart';

class NavPanel extends ConsumerWidget {
  const NavPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsyncValue = ref.watch(notesProvider);
    final selectedNoteId = ref.watch(selectedNoteIdProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Inter', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: notesAsyncValue.when(
        data: (folders) => _buildListsView(context, ref, folders, selectedNoteId),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: _buildBottomAppBar(context, ref),
    );
  }
  Widget _buildListsView(BuildContext context, WidgetRef ref, List<FolderItem> folders, String? selectedNoteId) {
    final lists = folders.map((folder) {
      final children = folder.notes.isEmpty
          ? [_buildEmptyPlaceholder(context)]
          : folder.notes.map((note) => _buildNoteItem(context, ref, note, selectedNoteId)).toList();
      return DragAndDropList(
        key: ValueKey(folder.id),
        header: _buildFolderHeader(context, ref, folder),
        children: children,
      );
    }).toList();
    return DragAndDropLists(
      children: lists,
      onItemReorder: (oldItemIndex, oldListIndex, newItemIndex, newListIndex) {
        final noteId = folders[oldListIndex].notes[oldItemIndex].id;
        ref.read(notesProvider.notifier).moveNote(noteId, oldListIndex, newListIndex);
      },
      onListReorder: (oldListIndex, newListIndex) {
      },
      listDragHandle: const DragHandle(
        verticalAlignment: DragHandleVerticalAlignment.top,
        child: Padding( 
          padding: EdgeInsets.symmetric(horizontal: 16.0), 
          child: Icon(Icons.drag_handle), 
        ),
      ),
      itemDragHandle: DragHandle(
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(Icons.drag_indicator, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha:0.5)),
        ),
      ),
    );
  }
  DragAndDropItem _buildEmptyPlaceholder(BuildContext context) {
    return DragAndDropItem(
      canDrag: false,
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text('Drop notes here',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      ),
    );
  }
  Widget _buildFolderHeader(BuildContext context, WidgetRef ref, FolderItem folder) {
    return GestureDetector(
      onLongPress: () => _showItemActions(context, ref, folder.title,
        onRename: () => _showRenameDialog(context, ref, "Rename Folder", folder.title, (newName) {
          ref.read(notesProvider.notifier).renameFolder(folder.id, newName);
        }),
        onDelete: () {
          ref.read(notesProvider.notifier).deleteFolder(folder.id);
        },
      ),
      child: ListTile(
        title: Text(folder.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
  DragAndDropItem _buildNoteItem(BuildContext context, WidgetRef ref, NoteItem note, String? selectedNoteId) {
    return DragAndDropItem(
      key: ValueKey(note.id),
      child: Dismissible(
        key: ValueKey('${note.id}_dismiss'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (dir) => _showConfirmDialog(context, 'Delete "${note.title}"?'),
        onDismissed: (dir) => ref.read(notesProvider.notifier).deleteNote(note.id),
        background: _buildDeleteBackground(),
        child: GestureDetector(
          onLongPress: () => _showItemActions(context, ref, note.title,
            onRename: () => _showRenameDialog(context, ref, "Rename Note", note.title, (newName) {
              ref.read(notesProvider.notifier).renameNote(note.id, newName);
            }),
            onDelete: () => ref.read(notesProvider.notifier).deleteNote(note.id),
          ),
          child: ListTile(
            leading: const Icon(Icons.notes_rounded),
            title: Text(note.title),
            selected: note.id == selectedNoteId,
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha:0.4),
            onTap: () => ref.read(selectedNoteIdProvider.notifier).select(note.id),
          ),
        ),
      ),
    );
  }
  BottomAppBar _buildBottomAppBar(BuildContext context, WidgetRef ref) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            onPressed: () => ref.read(notesProvider.notifier).createNewNote(),
            tooltip: 'New Note',
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _showRenameDialog(context, ref, "New Folder", "", (name) {
              ref.read(notesProvider.notifier).createNewFolder(name);
            }),
            tooltip: 'New Folder',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: const Icon(Icons.delete_forever, color: Colors.white),
    );
  }
  Future<void> _showItemActions(BuildContext context, WidgetRef ref, String title, {required VoidCallback onRename, required VoidCallback onDelete}) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(context);
              onRename();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete'),
            onTap: () {
               Navigator.pop(context);
               onDelete();
            },
          ),
        ],
      ),
    );
  }
  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref, String dialogTitle, String initialText, Function(String) onSubmit) {
    final controller = TextEditingController(text: initialText);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSubmit(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  Future<bool?> _showConfirmDialog(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
        ],
      ),
    );
  }
}
