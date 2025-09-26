import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class EditPanel extends StatefulWidget {
  const EditPanel({super.key});

  @override
  State<EditPanel> createState() => _EditPanelState();
}

class _EditPanelState extends State<EditPanel> {
  late final TextEditingController _controller;
  String _markdownText = '# inter markdown title\n\nThis is regular text.\n\n- type on the bottom\n- rendered live to the top pane\n- wip, *real* implementation will be line by line';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _markdownText);
    _controller.addListener(() {
      setState(() {
        _markdownText = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('write notes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: MarkdownBody(
                data: _markdownText,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16, height: 1.5),
                  h1: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  h2: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  code: TextStyle(
                    backgroundColor: Colors.grey[200],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[50],
              child: TextField(
                controller: _controller,
                maxLines: null, 
                expands: true, 
                decoration: const InputDecoration(
                  hintText: 'Start writing your note...',
                  border: InputBorder.none, 
                ),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
