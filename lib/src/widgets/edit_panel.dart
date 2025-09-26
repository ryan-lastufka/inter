import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../features/notes/application/notes_provider.dart';

class EditPanel extends ConsumerStatefulWidget {
  const EditPanel({super.key});

  @override
  ConsumerState<EditPanel> createState() => _EditPanelState();
}

class _EditPanelState extends ConsumerState<EditPanel> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _currentlyDisplayedNoteId = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }
  void _onTextChanged() {
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final note = ref.read(selectedNoteProvider).value;
      if (note != null && note.content != _controller.text) {
        final updatedNote = note.copyWith(content: _controller.text);
        await ref.read(notesProvider.notifier).updateNote(updatedNote);
        ref.invalidate(selectedNoteProvider);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedNoteAsync = ref.watch(selectedNoteProvider);
    return selectedNoteAsync.when(
      data: (note) {
        if (note == null) {
          return Center(
            child: Text(
              'Select a note to begin editing',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        }
        if (note.id != _currentlyDisplayedNoteId) {
          _controller.text = note.content;
          _currentlyDisplayedNoteId = note.id;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(note.title), 
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.black87,
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: MarkdownBody(
                    data: _controller.text, 
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading note: $err')),
    );
  }
}
