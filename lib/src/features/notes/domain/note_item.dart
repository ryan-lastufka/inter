class NoteItem {
  final String id;
  String title;
  final String path; 
  String content; 
  NoteItem({
    required this.id,
    required this.title,
    required this.path,
    this.content = '',
  });
  NoteItem copyWith({
    String? id,
    String? title,
    String? path,
    String? content,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      content: content ?? this.content,
    );
  }
}
