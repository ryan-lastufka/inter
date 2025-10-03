import 'package:flutter/material.dart';

class EditorSection extends StatefulWidget {
  final String text;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  const EditorSection({
    super.key,
    required this.text,
    this.onChanged,
    this.onEditingComplete,
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
    _controller = TextEditingController(text: widget.text);
    _focusNode.requestFocus();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant EditorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != _controller.text && widget.text.length < _controller.text.length) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onEditingComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        autofocus: true,
        style: const TextStyle(fontSize: 16, height: 1.5),
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        onEditingComplete: widget.onEditingComplete,
      ),
    );
  }
}
