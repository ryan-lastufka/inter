import 'package:flutter/material.dart';

class DetailPanel extends StatelessWidget {
  const DetailPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: const [
            Text('Analysis Tools', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ListTile(title: Text('Word Count: ...')),
            ListTile(title: Text('Reading Time: ...')),
            ListTile(title: Text('Reading Level: ...')),
          ],
        ),
      ),
    );
  }
}
