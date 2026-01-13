import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/providers/providers.dart';
import '../../data/database/database.dart';

/// Screen for adding or editing a contact.
class ContactFormScreen extends ConsumerStatefulWidget {
  const ContactFormScreen({
    super.key,
    this.contactId,
  });

  /// If provided, we're editing an existing contact. Otherwise, creating new.
  final String? contactId;

  bool get isEditing => contactId != null;

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _jobTitleController = TextEditingController();

  String? _avatarPath;
  DateTime? _birthday;
  int _cadenceDays = 30;
  bool _isLoading = false;
  bool _isInitialized = false;

  static const List<int> _cadencePresets = [7, 14, 30, 90];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  void _initializeFromContact(Contact contact) {
    if (_isInitialized) return;
    _isInitialized = true;

    _nameController.text = contact.name;
    _phoneController.text = contact.phone ?? '';
    _emailController.text = contact.email ?? '';
    _jobTitleController.text = contact.jobTitle ?? '';
    _avatarPath = contact.avatarLocalPath;
    _cadenceDays = contact.cadenceDays;
    if (contact.birthday != null) {
      _birthday = DateTime.fromMillisecondsSinceEpoch(contact.birthday!);
    }
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_avatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () {
                  setState(() => _avatarPath = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image == null) return;

    // Copy image to app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory(p.join(appDir.path, 'avatars'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
    final savedPath = p.join(avatarsDir.path, fileName);
    await File(image.path).copy(savedPath);

    setState(() => _avatarPath = savedPath);
  }

  Future<void> _pickBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Birthday',
    );

    if (date != null) {
      setState(() => _birthday = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(contactNotifierProvider.notifier);

      if (widget.isEditing) {
        await notifier.update(
          widget.contactId!,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          jobTitle: _jobTitleController.text.trim().isEmpty
              ? null
              : _jobTitleController.text.trim(),
          avatarLocalPath: _avatarPath,
          birthday: _birthday,
          cadenceDays: _cadenceDays,
        );
      } else {
        await notifier.create(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          jobTitle: _jobTitleController.text.trim().isEmpty
              ? null
              : _jobTitleController.text.trim(),
          avatarLocalPath: _avatarPath,
          birthday: _birthday,
          cadenceDays: _cadenceDays,
        );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If editing, load contact data
    if (widget.isEditing) {
      final contactAsync = ref.watch(contactProvider(widget.contactId!));
      return contactAsync.when(
        data: (contact) {
          if (contact == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Contact Not Found')),
              body: const Center(child: Text('Contact not found')),
            );
          }
          _initializeFromContact(contact);
          return _buildForm(context);
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Loading...')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Error: $error')),
        ),
      );
    }

    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Contact' : 'New Contact'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AvatarPicker(
              avatarPath: _avatarPath,
              onTap: _pickAvatar,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jobTitleController,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                prefixIcon: Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 16),
            _BirthdayPicker(
              birthday: _birthday,
              onTap: _pickBirthday,
              onClear: () => setState(() => _birthday = null),
            ),
            const SizedBox(height: 24),
            _CadenceSelector(
              selectedDays: _cadenceDays,
              presets: _cadencePresets,
              onChanged: (days) => setState(() => _cadenceDays = days),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.avatarPath,
    required this.onTap,
  });

  final String? avatarPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage:
                  avatarPath != null ? FileImage(File(avatarPath!)) : null,
              child: avatarPath == null
                  ? Icon(
                      Icons.person,
                      size: 48,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BirthdayPicker extends StatelessWidget {
  const _BirthdayPicker({
    required this.birthday,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? birthday;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.cake),
      title: const Text('Birthday'),
      subtitle: Text(
        birthday != null
            ? '${birthday!.month}/${birthday!.day}/${birthday!.year}'
            : 'Not set',
      ),
      trailing: birthday != null
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClear,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _CadenceSelector extends StatelessWidget {
  const _CadenceSelector({
    required this.selectedDays,
    required this.presets,
    required this.onChanged,
  });

  final int selectedDays;
  final List<int> presets;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Frequency',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'How often would you like to stay in touch?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((days) {
            final isSelected = selectedDays == days;
            return ChoiceChip(
              label: Text(_formatCadence(days)),
              selected: isSelected,
              onSelected: (_) => onChanged(days),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Custom:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                value: selectedDays.toDouble(),
                min: 1,
                max: 180,
                divisions: 179,
                label: _formatCadence(selectedDays),
                onChanged: (value) => onChanged(value.round()),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                _formatCadence(selectedDays),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCadence(int days) {
    if (days == 1) return '1 day';
    if (days == 7) return '1 week';
    if (days == 14) return '2 weeks';
    if (days == 30) return '1 month';
    if (days == 90) return '3 months';
    if (days == 180) return '6 months';
    return '$days days';
  }
}
