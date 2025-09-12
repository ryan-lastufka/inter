import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum StorageOption { local, googleDrive }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StorageOption _storageOption = StorageOption.local;
  bool _darkModeEnabled = false;
  String _fontSize = 'Medium';
  final TextEditingController _notionApiKeyController = TextEditingController();

  @override
  void dispose() {
    _notionApiKeyController.dispose();
    super.dispose();
  }
  void _handleStorageOptionChange(StorageOption? value) {
    if (value != null) {
      setState(() {
        _storageOption = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Storage',
            children: [
              RadioGroup<StorageOption>(
                groupValue: _storageOption,
                onChanged: _handleStorageOptionChange,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text('Local Device Storage'),
                      leading: const Radio<StorageOption>(
                        value: StorageOption.local,
                      ),
                      onTap: () =>
                          _handleStorageOptionChange(StorageOption.local),
                    ),
                    ListTile(
                      title: const Text('Google Drive Sync'),
                      leading: const Radio<StorageOption>(
                        value: StorageOption.googleDrive,
                      ),
                      onTap: () =>
                          _handleStorageOptionChange(StorageOption.googleDrive),
                    ),
                  ],
                ),
              ),
              if (_storageOption == StorageOption.local)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  child: TextField(
                    controller:
                        TextEditingController(text: '/Documents/Inter/Notes'),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Storage Path',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
            ],
          ),
          _SettingsSection(
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: const Text('Enable Dark Mode'),
                value: _darkModeEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
              ListTile(
                title: const Text('Default Font Size'),
                trailing: DropdownButton<String>(
                  value: _fontSize,
                  onChanged: (String? newValue) {
                    setState(() {
                      _fontSize = newValue!;
                    });
                  },
                  items: <String>['Small', 'Medium', 'Large']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Integrations',
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _notionApiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Notion API Key',
                    hintText: 'secret_...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
