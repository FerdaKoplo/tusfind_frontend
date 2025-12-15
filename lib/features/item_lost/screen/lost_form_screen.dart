import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/models/item_model.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';

// ivan
class LostFormScreen extends StatefulWidget {
  final ItemLostRepository repo;
  final ItemLost? existing;

  const LostFormScreen({super.key, required this.repo, this.existing});

  @override
  State<LostFormScreen> createState() => _LostFormScreenState();
}

class _LostFormScreenState extends State<LostFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _categoryId;
  int? _itemId;
  String? _location;
  String? _description;

  List<Category> _categories = [];
  List<Item> _items = [];
  List<Item> _filteredItems = [];

  bool _loading = false;
  bool _loadingData = true;

  String? _customItemName;
  bool _useCustomItem = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = widget.repo.api;

    final categoryRepo = CategoryRepository(api);
    final itemRepo = ItemRepository(api);

    try {
      debugPrint('Loading categories...');
      final categories = await categoryRepo.getCategories();
      debugPrint('Categories loaded: ${categories.length}');

      debugPrint('Loading items...');
      final items = await itemRepo.getItems();
      debugPrint('Items loaded: ${items.length}');

      setState(() {
        _categories = categories;
        _items = items;

        if (isEdit) {
          final lost = widget.existing!;
          _categoryId = lost.category?.id;
          _itemId = lost.item?.id;
          _location = lost.lostLocation;
          _description = lost.description;

          _filteredItems = _items
              .where((i) => i.category?.id == _categoryId)
              .toList();
        }

        _loadingData = false;
      });
    } catch (e, stack) {
      debugPrint('Load data error: $e');
      debugPrint(stack.toString());

      _loadingData = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load data')));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      if (isEdit) {
        await widget.repo.updateLostItem(
          widget.existing!.id,
          categoryId: _categoryId,
          itemId: _itemId,
          lostLocation: _location,
          description: _description,
        );
      } else {
        await widget.repo.createLostItem(
          categoryId: _categoryId!,
          itemId: _itemId,
          customItemName: _customItemName,
          lostLocation: _location,
          description: _description,
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Lost Item' : 'Report Lost Item'),
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          )
                          .toList(),
                      validator: (v) => v == null ? 'Required' : null,
                      onChanged: (value) {
                        setState(() {
                          _categoryId = value;
                          _itemId = null;

                          _filteredItems = _items
                              .where((item) => item.category?.id == _categoryId)
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      initialValue: _itemId,
                      decoration: const InputDecoration(labelText: 'Item'),
                      items: [
                        ..._filteredItems.map(
                          (item) => DropdownMenuItem<int>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        ),
                        const DropdownMenuItem<int>(
                          value: -1,
                          child: Text('Other / Not in list'),
                        ),
                      ],
                      validator: (v) => v == null ? 'Required' : null,
                      onChanged: (value) {
                        setState(() {
                          if (value == -1) {
                            _itemId = null;
                            _useCustomItem = true;
                          } else {
                            _itemId = value;
                            _useCustomItem = false;
                            _customItemName = null;
                          }
                        });
                      },
                    ),

                    if (_useCustomItem)
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Item name',
                        ),
                        validator: (v) {
                          if (_useCustomItem && (v == null || v.isEmpty)) {
                            return 'Item name is required';
                          }
                          return null;
                        },
                        onSaved: (v) => _customItemName = v,
                      ),

                    const SizedBox(height: 12),

                    TextFormField(
                      initialValue: _location,
                      decoration: const InputDecoration(
                        labelText: 'Lost Location',
                      ),
                      validator: (validate) =>
                          validate == null || validate.isEmpty
                          ? 'Required'
                          : null,
                      onSaved: (v) => _location = v,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      onSaved: (v) => _description = v,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? 'Update' : 'Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
