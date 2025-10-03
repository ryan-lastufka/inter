import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class RenderedSection extends StatelessWidget {
  final String text;
  const RenderedSection({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseTextStyle = const TextStyle(
      fontSize: 16,
      height: 1.5,
      color: Colors.black87,
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
        styleSheet: MarkdownStyleSheet.fromTheme(
          Theme.of(context),
        ).copyWith(p: baseTextStyle),
      ),
    );
  }
}
