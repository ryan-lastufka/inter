import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/notes/application/notes_provider.dart';
import 'editor_section.dart'; 
import 'rendered_section.dart'; 

class EditPanel extends ConsumerStatefulWidget {
  const EditPanel({super.key});

  @override
  ConsumerState<EditPanel> createState() => _EditPanelState();
}

class _EditPanelState extends ConsumerState<EditPanel> {
  String _currentlyDisplayedNoteId = '';
  List<String> _sections = []; 
  bool _isInitialized = false;
  int? _editingIndex; 

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
        if (!_isInitialized || note.id != _currentlyDisplayedNoteId) {
          _sections = note.content.split('\n');
          _currentlyDisplayedNoteId = note.id;
          _isInitialized = true;
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(
              note.title,
            ), 
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: _sections.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: _sections.length,
                          itemBuilder: (context, index) {
                            try {
                              if (index == _editingIndex) {
                                return EditorSection(
                                  key: ValueKey(
                                      '${_currentlyDisplayedNoteId}_$index'),
                                  text: _sections[index],
                                  onChanged: (text) =>
                                      _updateSection(index, text, note.id),
                                  onEditingComplete: () {
                                    _setEditingIndex(null);
                                  },
                                );
                              } else {
                                return GestureDetector(
                                  onTap: () => _setEditingIndex(index),
                                  child: RenderedSection(
                                    text: _sections[index],
                                  ),
                                );
                              }
                            } catch (e, stackTrace) {
                              return Text(
                                'Error rendering section: $e\n$stackTrace',
                              ); 
                            }
                          },
                        ),
                      )
                    : const Text("No content."),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading note: $err')),
    );
  }
  void _setEditingIndex(int? index) {
    setState(() {
      _editingIndex = index;
    });
  }
  Timer? _debounce;
  void _updateSection(int index, String text, String noteId) async {
    if (text.contains('\n')) {
      final parts = text.split('\n');
      setState(() {
        _sections[index] = parts.first; 
        for (var i = 1; i < parts.length; i++) {
          _sections.insert(index + i, parts[i]);
        }
        _editingIndex = index + parts.length - 1;
      });
    } else {
      setState(() {
        _sections[index] = text; 
      });
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _saveSections(noteId);
    });
  }
  Future<void> _saveSections(String noteId) async {
    final note = ref.read(selectedNoteProvider).value;
    if (note != null) {
      final updatedContent = _sections.join('\n');
      final updatedNote = note.copyWith(content: updatedContent);
      await ref.read(notesProvider.notifier).updateNote(updatedNote);
      ref.invalidate(selectedNoteProvider); 
    }
  }
}
