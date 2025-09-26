import 'note_item.dart';

class FolderItem {
  final String id;
  String title;
  final String path; 
  List<NoteItem> notes;
  bool isExpanded;
  FolderItem({
    required this.id,
    required this.title,
    required this.path,
    required this.notes,
    this.isExpanded = false,
  });
}
