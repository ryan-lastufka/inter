import 'note_item.dart';

class FolderItem {
  final String id;
  final String title;
  final List<NoteItem> notes;
  bool isExpanded; 
  FolderItem({
    required this.id,
    required this.title,
    required this.notes,
    this.isExpanded = true,
  });
}
