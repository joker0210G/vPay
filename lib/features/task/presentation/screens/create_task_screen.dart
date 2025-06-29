import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vpay/features/task/providers/task_provider.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart';
import 'package:vpay/features/task/domain/task_model.dart'; // For TaskCategory and extension

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _tagsController = TextEditingController(); // Added tags controller
  TaskCategory _selectedCategory = TaskCategory.academicSupport;
  bool _isLoading = false;

  final List<TaskCategory> _categories = [
    TaskCategory.academicSupport,
    TaskCategory.campusErrands,
    TaskCategory.techHelp,
    TaskCategory.eventSupport,
    TaskCategory.other,
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                autofocus: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid number for the amount';
                  }
                  if (amount <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: _categories.map((TaskCategory category) {
                  return DropdownMenuItem<TaskCategory>(
                    value: category,
                    child: Text(category.displayName),
                  );
                }).toList(),
                onChanged: (TaskCategory? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude (Optional)'),
                keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null; // Optional
                  if (double.tryParse(value.trim()) == null) return 'Invalid latitude';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude (Optional)'),
                keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null; // Optional
                  if (double.tryParse(value.trim()) == null) return 'Invalid longitude';
                  return null;
                },
              ),
              const SizedBox(height: 16), // Added SizedBox
              TextFormField( // Added Tags TextFormField
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma-separated, optional)'),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && user != null) {
                        setState(() => _isLoading = true);
                        double amountValue;
                        try {
                          amountValue = double.parse(_amountController.text);
                        } on FormatException {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Invalid amount format. Please enter a valid number.')),
                          );
                          setState(() => _isLoading = false);
                          return;
                        }

                        final String latText = _latitudeController.text.trim();
                        final String lonText = _longitudeController.text.trim();
                        double? latitude;
                        double? longitude;

                        try {
                          if (latText.isNotEmpty) latitude = double.parse(latText);
                          if (lonText.isNotEmpty) longitude = double.parse(lonText);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid latitude or longitude format.')),
                            );
                            setState(() => _isLoading = false);
                          }
                          return; 
                        }

                        final String tagsText = _tagsController.text.trim();
                        final List<String> tags = tagsText.isNotEmpty
                            ? tagsText.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList()
                            : [];

                        final taskRepository = ref.read(taskRepositoryProvider);
                        try {
                          await taskRepository.createTask(
                            creatorId: user.id,
                            title: _titleController.text,
                            description: _descriptionController.text,
                            amount: amountValue,
                            category: _selectedCategory.toJson(),
                            latitude: latitude,
                            longitude: longitude,
                            tags: tags, // Passed tags
                          );
                          if (!mounted) return; // Moved check before context usage
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task created successfully!')),
                          );
                          if (!mounted) return; // Added check before context.pop()
                          context.pop();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error creating task: $e')),
                          );
                        } finally {
                          if (!mounted) return;
                          setState(() => _isLoading = false);
                        }
                      }
                    },

                      child: const Text('Create Task'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _tagsController.dispose(); // Disposed tags controller
    super.dispose();
  }
}
