import 'package:flutter/material.dart';

class EditPanel extends StatelessWidget {
  const EditPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: TextField(
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Start writing your note...',
        ),
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }
}
