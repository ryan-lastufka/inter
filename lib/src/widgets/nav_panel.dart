import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavPanel extends StatelessWidget {
  const NavPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                ListTile(title: Text('Folder 1')),
                ListTile(title: Text('Note A'), selected: true),
                ListTile(title: Text('Note B')),
                ListTile(title: Text('Folder 2')),
                ListTile(title: Text('Note C')),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }
}
