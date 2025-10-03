import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class RenderedSection extends StatelessWidget {
  final String text;
  const RenderedSection({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final customMarkdownStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: const TextStyle(fontSize: 16, height: 1.5),
      code: TextStyle(
        color: isDarkMode ? Colors.deepOrange.shade300 : Colors.deepOrange.shade800,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        fontFamily: 'monospace',
        fontSize: 14,
      ),
      blockquoteDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(left: BorderSide(width: 5, color: theme.dividerColor)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: MarkdownBody(
        data: text,
        extensionSet: md.ExtensionSet(
          md.ExtensionSet.gitHubFlavored.blockSyntaxes,
          <md.InlineSyntax>[
            md.EmojiSyntax(),
            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
          ],
        ),
        styleSheet: customMarkdownStyle,
      ),
    );
  }
}
