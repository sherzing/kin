import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/presentation/widgets/markdown_editor.dart';

void main() {
  group('MarkdownEditor', () {
    testWidgets('renders with text field and toolbar', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(controller: controller),
          ),
        ),
      );

      // Should have toolbar and text field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.format_bold), findsOneWidget);
      expect(find.byIcon(Icons.format_italic), findsOneWidget);
      expect(find.byIcon(Icons.title), findsOneWidget);
      expect(find.byIcon(Icons.format_list_bulleted), findsOneWidget);
      expect(find.byIcon(Icons.format_list_numbered), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
      expect(find.byIcon(Icons.preview), findsOneWidget);

      controller.dispose();
    });

    testWidgets('displays hint text', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(
              controller: controller,
              hintText: 'Enter your notes here',
            ),
          ),
        ),
      );

      expect(find.text('Enter your notes here'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('bold button inserts markdown', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(controller: controller),
          ),
        ),
      );

      // Tap bold button
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(controller.text, equals('****'));

      controller.dispose();
    });

    testWidgets('italic button inserts markdown', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(controller: controller),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_italic));
      await tester.pump();

      expect(controller.text, equals('__'));

      controller.dispose();
    });

    testWidgets('heading button inserts markdown', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(controller: controller),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.title));
      await tester.pump();

      expect(controller.text, equals('# '));

      controller.dispose();
    });

    testWidgets('bullet list button inserts markdown', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(controller: controller),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_list_bulleted));
      await tester.pump();

      expect(controller.text, equals('- '));

      controller.dispose();
    });

    testWidgets('numbered list button inserts markdown', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(controller: controller),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_list_numbered));
      await tester.pump();

      expect(controller.text, equals('1. '));

      controller.dispose();
    });

    testWidgets('link button inserts markdown', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(controller: controller),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.link));
      await tester.pump();

      expect(controller.text, equals('[](url)'));

      controller.dispose();
    });

    testWidgets('preview button toggles preview mode', (tester) async {
      final controller = TextEditingController(text: '**Bold text**');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(controller: controller),
          ),
        ),
      );

      // Initially in edit mode - should show TextField
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.preview), findsOneWidget);

      // Tap preview button
      await tester.tap(find.byIcon(Icons.preview));
      await tester.pumpAndSettle();

      // Now in preview mode - should show edit icon and no TextField
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      controller.dispose();
    });

    testWidgets('preview mode shows empty state for empty content',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(controller: controller),
          ),
        ),
      );

      // Tap preview button
      await tester.tap(find.byIcon(Icons.preview));
      await tester.pumpAndSettle();

      expect(find.text('Nothing to preview'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('toolbar buttons are disabled in preview mode', (tester) async {
      final controller = TextEditingController(text: 'Some text');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(controller: controller),
          ),
        ),
      );

      // Enter preview mode
      await tester.tap(find.byIcon(Icons.preview));
      await tester.pumpAndSettle();

      // Tap bold button (should be disabled)
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      // Text should not have changed
      expect(controller.text, equals('Some text'));

      controller.dispose();
    });

    testWidgets('respects minLines and maxLines', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownEditor(
              controller: controller,
              minLines: 3,
              maxLines: 8,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.minLines, equals(3));
      expect(textField.maxLines, equals(8));

      controller.dispose();
    });
  });
}
