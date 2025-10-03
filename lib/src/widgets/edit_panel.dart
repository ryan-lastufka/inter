import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/notes/application/notes_provider.dart';
import 'editor_section.dart'; 
import 'editor_block.dart';
import 'rendered_section.dart'; 

class EditPanel extends ConsumerStatefulWidget {
  const EditPanel({super.key});

  @override
  ConsumerState<EditPanel> createState() => _EditPanelState();
}

class _EditPanelState extends ConsumerState<EditPanel> {
  String _currentlyDisplayedNoteId = '';
  List<EditorBlock> _sections = []; 
  bool _isInitialized = false;
  int? _editingIndex; 
  int? _nextCursorPosition;
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    _focusScopeNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusScopeNode.removeListener(_onFocusChange);
    _focusScopeNode.dispose();
    super.dispose();
  }
  void _onFocusChange() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return; 
      print("[EditPanel] _onFocusChange: FocusScope hasFocus = ${_focusScopeNode.hasFocus}, _editingIndex = $_editingIndex");
      if (!_focusScopeNode.hasFocus && _editingIndex != null) {
        print("[EditPanel] _onFocusChange: TRIGGERING MERGE AND CLEANUP.");
        final currentContent = _sections.map((b) => b.content).join('\n');
        final newSections = _parseContentIntoSections(currentContent);
        setState(() { _sections = newSections; _editingIndex = null; print("[EditPanel] _onFocusChange: setState finished for merge."); });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("[EditPanel] build: Rebuilding EditPanel. _editingIndex is $_editingIndex");
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
          _sections = _parseContentIntoSections(note.content);
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
          body: FocusScope(
            node: _focusScopeNode,
            child: Column(
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
                                  final cursorPosition = _nextCursorPosition;
                                  _nextCursorPosition = null;
                                  return EditorSection(
                                    key: ValueKey(
                                        '${_currentlyDisplayedNoteId}_$index'),
                                    initialCursorPosition: cursorPosition,
                                    text: _sections[index].content,
                                    onChanged: (text) =>
                                        _updateSection(index, text, note.id),
                                    onDeleteEmpty: () {
                                      _deleteSectionAndFocusPrevious(index, note.id);
                                    },
                                    onMergeWithPrevious: () {
                                      _mergeSectionWithPrevious(index, note.id);
                                    },
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      print("[EditPanel] onTap: Tapped on rendered section at index $index.");
                                      _setEditingIndex(index);
                                    },
                                    child: Container(
                                      color: Colors.transparent, 
                                      width: double.infinity,
                                      constraints: const BoxConstraints(minHeight: 24.0), 
                                      child: RenderedSection(
                                        text: _sections[index].content.isEmpty
                                            ? ' ' 
                                            : _sections[index].content,
                                      ),
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
                      : const Center(child: Text("No content.")),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading note: $err')),
    );
  }
  List<EditorBlock> _parseContentIntoSections(String content) {
    if (content.isEmpty) {
      return [EditorBlock(content: '', startLine: 0)];
    }
    final lines = content.split('\n');
    final sections = <EditorBlock>[];
    StringBuffer? currentSection;
    bool inCodeBlock = false;
    int currentSectionStartLine = 0;
    void endSection() {
      if (currentSection != null) {
        sections.add(EditorBlock(
          content: currentSection.toString().trimRight(),
          startLine: currentSectionStartLine,
        ));
        currentSection = null;
      }
    }
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith('```')) {
        if (!inCodeBlock) {
          endSection(); 
          inCodeBlock = true;
          currentSectionStartLine = i;
          currentSection = StringBuffer()..writeln(line);          
        } else {
          currentSection!.writeln(line);
          endSection(); 
          inCodeBlock = false;
        }
      } else if (inCodeBlock) {
        currentSection!.writeln(line);
      } else if (line.trim().isEmpty) {
        endSection();
        sections.add(EditorBlock(content: '', startLine: i)); 
      } else {
        if (currentSection == null) {
          currentSectionStartLine = i;
          currentSection = StringBuffer();
        }
        currentSection!.writeln(line);
      }
    }
    endSection(); 
    return sections.isEmpty ? [EditorBlock(content: '', startLine: 0)] : sections;
  }
  void _setEditingIndex(int? index) {
    if (_editingIndex != index) {
      print("[EditPanel] _setEditingIndex: Changing from $_editingIndex to $index");
      setState(() {
        if (index != null) _nextCursorPosition = null; 
        _editingIndex = index;
      });
    }
  }
  Timer? _debounce;
  void _updateSection(int index, String text, String noteId) async {
    final isCodeBlock = _sections[index].content.contains('```');
    if (text.contains('\n') && !isCodeBlock) {
      print("[EditPanel] _updateSection: Newline detected at index $index. Re-parsing content.");
      final parts = text.split('\n');
      final originalBlock = _sections[index];
      final expectedNewLineStart = originalBlock.startLine + parts.first.split('\n').length;
      _sections[index] = EditorBlock(content: parts.first, startLine: originalBlock.startLine);
      for (var i = 1; i < parts.length; i++) {
        _sections.insert(index + i, EditorBlock(content: parts[i], startLine: 0));
      }
      final currentContent = _sections.map((b) => b.content).join('\n');
      final newSections = _parseContentIntoSections(currentContent);
      int newEditingIndex = newSections.indexWhere((block) => block.startLine >= expectedNewLineStart);
      if (newEditingIndex == -1) newEditingIndex = newSections.length - 1; 
      setState(() { _sections = newSections; _editingIndex = newEditingIndex; print("[EditPanel] _updateSection: setState finished for newline. New index is $newEditingIndex"); });
      _saveSections(noteId);
    } else {
      setState(() {
        _sections[index] = EditorBlock(content: text, startLine: _sections[index].startLine);
      });
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _saveSections(noteId);
    });
  }
  void _mergeSectionWithPrevious(int index, String noteId) {
    if (index > 0) {
      print("[EditPanel] _mergeSectionWithPrevious: Merging section at $index with ${index - 1}.");
      final previousBlock = _sections[index - 1];
      final currentBlock = _sections[index];
      final mergedContent = previousBlock.content + currentBlock.content;
      final newCursorPosition = previousBlock.content.length;
      _sections[index - 1] = EditorBlock(content: mergedContent, startLine: previousBlock.startLine);
      _sections.removeAt(index);
      _nextCursorPosition = newCursorPosition;
      setState(() { _editingIndex = index - 1; print("[EditPanel] _mergeSectionWithPrevious: Setting next cursor position to $_nextCursorPosition"); });
      _saveSections(noteId);
    }
  }
  void _deleteSectionAndFocusPrevious(int index, String noteId) {
    if (index > 0) {
      print("[EditPanel] _deleteSectionAndFocusPrevious: Deleting section at $index, focusing ${index - 1}.");
      setState(() {
        _sections.removeAt(index);
        _editingIndex = index - 1;
      });
      _saveSections(noteId);
    }
  }
  Future<void> _saveSections(String noteId) async {
    print("[EditPanel] _saveSections: Saving note content.");
    final note = ref.read(selectedNoteProvider).value;
    if (note != null) {
      final updatedContent = _sections.map((b) => b.content).join('\n');
      final updatedNote = note.copyWith(content: updatedContent);
      await ref.read(notesProvider.notifier).updateNote(updatedNote);
      ref.invalidate(selectedNoteProvider); 
    }
  }
}
