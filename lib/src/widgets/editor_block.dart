class EditorBlock {
  final String content;
  final int startLine;
  EditorBlock({required this.content, required this.startLine});

  @override
  String toString() {
    return 'EditorBlock(startLine: $startLine, content: "$content")';
  }
}
