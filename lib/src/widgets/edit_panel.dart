import 'package:flutter/material.dart';

class EditPanel extends StatelessWidget {
  const EditPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: const Center(
        child: Text(
          'Main Note Editor Area',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}
