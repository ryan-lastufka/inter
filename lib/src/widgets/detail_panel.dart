import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inter/src/features/notes/application/notes_provider.dart';
import 'common/detail_info_row.dart';

class DetailPanel extends ConsumerWidget {
  const DetailPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ref
                .watch(noteAnalysisProvider)
                .when(
                  data: (analysis) {
                    if (analysis == null) {
                      return const Center(
                        child: Text('No analysis available.'),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailInfoRow(
                          label: 'Word Count',
                          value: analysis.wordCount.toString(),
                        ),
                        const SizedBox(height: 8),
                        DetailInfoRow(
                          label: 'Reading Time',
                          value: '${analysis.readingTimeMinutes} min',
                        ),
                        const SizedBox(height: 8),
                        DetailInfoRow(
                          label: 'Reading Level',
                          value: analysis.readingLevel,
                        ),
                        const Divider(height: 40),
                        const Text(
                          'Extractive Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Summary feature coming soon...', 
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Center(child: Text('Error loading analysis: $error')),
                ),
          ],
        ),
      ),
    );
  }
}
