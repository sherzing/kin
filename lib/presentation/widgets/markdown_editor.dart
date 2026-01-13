import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// A markdown editor with toolbar and preview mode.
class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({
    super.key,
    required this.controller,
    this.hintText,
    this.minLines = 5,
    this.maxLines = 12,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final bool autofocus;

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  bool _isPreview = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _insertMarkdown(String before, String after) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (!selection.isValid) {
      // No selection, insert at end
      widget.controller.text = '$text$before$after';
      widget.controller.selection = TextSelection.collapsed(
        offset: text.length + before.length,
      );
      return;
    }

    final selectedText = selection.textInside(text);
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$before$selectedText$after',
    );

    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: selection.start + before.length + selectedText.length + after.length,
    );
    _focusNode.requestFocus();
  }

  void _insertBold() => _insertMarkdown('**', '**');
  void _insertItalic() => _insertMarkdown('_', '_');
  void _insertHeading() => _insertMarkdown('# ', '');
  void _insertBullet() => _insertMarkdown('- ', '');
  void _insertNumbered() => _insertMarkdown('1. ', '');
  void _insertLink() => _insertMarkdown('[', '](url)');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        _EditorToolbar(
          isPreview: _isPreview,
          onPreviewToggle: () => setState(() => _isPreview = !_isPreview),
          onBold: _insertBold,
          onItalic: _insertItalic,
          onHeading: _insertHeading,
          onBullet: _insertBullet,
          onNumbered: _insertNumbered,
          onLink: _insertLink,
        ),
        const SizedBox(height: 8),

        // Editor or Preview
        _isPreview
            ? _MarkdownPreview(content: widget.controller.text)
            : _MarkdownTextField(
                controller: widget.controller,
                focusNode: _focusNode,
                hintText: widget.hintText,
                minLines: widget.minLines,
                maxLines: widget.maxLines,
                autofocus: widget.autofocus,
              ),
      ],
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.isPreview,
    required this.onPreviewToggle,
    required this.onBold,
    required this.onItalic,
    required this.onHeading,
    required this.onBullet,
    required this.onNumbered,
    required this.onLink,
  });

  final bool isPreview;
  final VoidCallback onPreviewToggle;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onHeading;
  final VoidCallback onBullet;
  final VoidCallback onNumbered;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Bold',
              onPressed: onBold,
              enabled: !isPreview,
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Italic',
              onPressed: onItalic,
              enabled: !isPreview,
            ),
            _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.title,
              tooltip: 'Heading',
              onPressed: onHeading,
              enabled: !isPreview,
            ),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Bullet list',
              onPressed: onBullet,
              enabled: !isPreview,
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Numbered list',
              onPressed: onNumbered,
              enabled: !isPreview,
            ),
            _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.link,
              tooltip: 'Link',
              onPressed: onLink,
              enabled: !isPreview,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(width: 1),
            ),
            _ToolbarButton(
              icon: isPreview ? Icons.edit : Icons.preview,
              tooltip: isPreview ? 'Edit' : 'Preview',
              onPressed: onPreviewToggle,
              isActive: isPreview,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.enabled = true,
    this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool enabled;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        iconSize: 20,
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 1,
        height: 24,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _MarkdownTextField extends StatelessWidget {
  const _MarkdownTextField({
    required this.controller,
    required this.focusNode,
    this.hintText,
    required this.minLines,
    required this.maxLines,
    required this.autofocus,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      decoration: InputDecoration(
        hintText: hintText ?? 'Write your notes here...',
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _MarkdownPreview extends StatelessWidget {
  const _MarkdownPreview({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Nothing to preview',
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: const BoxConstraints(minHeight: 120),
      child: MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: Theme.of(context).textTheme.bodyMedium,
          h1: Theme.of(context).textTheme.headlineSmall,
          h2: Theme.of(context).textTheme.titleLarge,
          h3: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
