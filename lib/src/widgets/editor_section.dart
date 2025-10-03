import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditorSection extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final VoidCallback? onDeleteEmpty;
  final VoidCallback? onMergeWithPrevious;
  final int? initialCursorPosition;
  const EditorSection({
    super.key,
    required this.text,
    required this.onChanged,
    this.onDeleteEmpty,
    this.onMergeWithPrevious,
    this.initialCursorPosition,
  });

  @override
  State<EditorSection> createState() => _EditorSectionState();
}

class _EditorSectionState extends State<EditorSection> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print("[EditorSection] initState: Creating editor for text: '${widget.text}' with key: ${widget.key}");
    _controller = TextEditingController(text: widget.text);
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.initialCursorPosition ?? _controller.text.length),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("[EditorSection] initState: Requesting focus for key: ${widget.key}.");
      FocusScope.of(context).requestFocus(_focusNode);
    });
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }
  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_focusNode.hasFocus) {
        print("[EditorSection] _handleKeyEvent: Backspace detected. Controller text: '${_controller.text}', Selection: ${_controller.selection}");
        if (_controller.text.isEmpty && widget.onDeleteEmpty != null) {
          widget.onDeleteEmpty!();
          return true; 
        } else if (_controller.selection.baseOffset == 0 && _controller.selection.extentOffset == 0 && widget.onMergeWithPrevious != null) {
          widget.onMergeWithPrevious!();
          return true; 
        }
      }
    }
    return false;
  }

  @override
  void didUpdateWidget(covariant EditorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("[EditorSection] didUpdateWidget: key: ${widget.key}, old text: '${oldWidget.text}', new text: '${widget.text}', controller text: '${_controller.text}'");
    if (widget.text != _controller.text) {
      _controller.text = widget.text;
      final newOffset = widget.initialCursorPosition ?? _controller.text.length;
      final newSelection = TextSelection.fromPosition(TextPosition(offset: newOffset.clamp(0, _controller.text.length)));
      print("[EditorSection] didUpdateWidget: Setting selection to offset ${newSelection.baseOffset} for text length ${_controller.text.length}");
      _controller.selection = newSelection;
    }
  }

  @override
  void dispose() {
    print("[EditorSection] dispose: Disposing editor for text: '${_controller.text}' with key: ${widget.key}");
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("[EditorSection] build: Building editor for text: '${widget.text}' with key: ${widget.key}");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: TextField(
        focusNode: _focusNode, 
        controller: _controller,
        maxLines: null,
        autofocus: false, 
        style: const TextStyle(fontSize: 16, height: 1.5),
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: widget.onChanged,
      ),
    );
  }
}
