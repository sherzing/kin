import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../data/database/database.dart';

/// Screen for managing circles (tags/groups).
class CircleListScreen extends ConsumerWidget {
  const CircleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circlesAsync = ref.watch(circlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circles'),
      ),
      body: circlesAsync.when(
        data: (circles) {
          if (circles.isEmpty) {
            return const _EmptyCirclesView();
          }
          return _CircleListView(circles: circles);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading circles: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCircleDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddCircleDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String name, Color color})>(
      context: context,
      builder: (context) => const _CircleFormDialog(),
    );

    if (result != null) {
      await ref.read(circleNotifierProvider.notifier).create(
            name: result.name,
            colorHex: _colorToHex(result.color),
          );
    }
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }
}

class _EmptyCirclesView extends StatelessWidget {
  const _EmptyCirclesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.label_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No circles yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create a circle for organizing contacts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _CircleListView extends ConsumerWidget {
  const _CircleListView({required this.circles});

  final List<Circle> circles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: circles.length,
      itemBuilder: (context, index) {
        final circle = circles[index];
        return _CircleListTile(circle: circle);
      },
    );
  }
}

class _CircleListTile extends ConsumerWidget {
  const _CircleListTile({required this.circle});

  final Circle circle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _hexToColor(circle.colorHex);

    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.label,
          color: _contrastColor(color),
          size: 18,
        ),
      ),
      title: Text(circle.name),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(context, ref, value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
      onTap: () => _showEditDialog(context, ref),
    );
  }

  Future<void> _handleMenuAction(
      BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'edit':
        await _showEditDialog(context, ref);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Circle?'),
            content: Text('Are you sure you want to delete "${circle.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await ref.read(circleNotifierProvider.notifier).delete(circle.id);
        }
        break;
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String name, Color color})>(
      context: context,
      builder: (context) => _CircleFormDialog(
        initialName: circle.name,
        initialColor: _hexToColor(circle.colorHex),
      ),
    );

    if (result != null) {
      await ref.read(circleNotifierProvider.notifier).update(
            circle.id,
            name: result.name,
            colorHex: _colorToHex(result.color),
          );
    }
  }

  Color _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return Colors.blue;
    }
    final hexCode = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Color _contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }
}

class _CircleFormDialog extends StatefulWidget {
  const _CircleFormDialog({
    this.initialName,
    this.initialColor,
  });

  final String? initialName;
  final Color? initialColor;

  @override
  State<_CircleFormDialog> createState() => _CircleFormDialogState();
}

class _CircleFormDialogState extends State<_CircleFormDialog> {
  late final TextEditingController _nameController;
  late Color _selectedColor;

  static const List<Color> _presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _nameController.addListener(_onNameChanged);
    _selectedColor = widget.initialColor ?? Colors.blue;
  }

  void _onNameChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Circle' : 'New Circle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Circle Name',
                hintText: 'e.g., Family, Work, Friends',
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _nameController.text.trim().isEmpty
              ? null
              : () => Navigator.pop(
                    context,
                    (name: _nameController.text.trim(), color: _selectedColor),
                  ),
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
