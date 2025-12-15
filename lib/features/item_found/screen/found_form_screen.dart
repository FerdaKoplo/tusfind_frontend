import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/models/item_model.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';

// ivan
class FoundFormScreen extends StatefulWidget {
  final ItemFoundRepository repo;
  final CategoryRepository categoryRepo;
  final ItemRepository itemRepo;
  final ItemFound? existing;

  const FoundFormScreen({
    super.key,
    required this.repo,
    required this.categoryRepo,
    required this.itemRepo,
    this.existing,
  });

  @override
  State<FoundFormScreen> createState() => _FoundFormScreenState();
}

class _FoundFormScreenState extends State<FoundFormScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Category> _categories = [];
  List<Item> _allItems = [];
  List<Item> _filteredItems = [];

  int? _categoryId;
  int? _itemId;
  String? _location;
  String? _description;

  bool _loading = false;
  bool _loadingItems = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // Fetch categories and items
    final categories = await widget.categoryRepo.getCategories();
    final items = await widget.itemRepo.getItems();

    setState(() {
      _categories = categories;
      _allItems = items;
    });

    if (isEdit) {
      final found = widget.existing!;
      _categoryId = found.category?.id;
      _itemId = found.item?.id;
      _location = found.foundLocation;
      _description = found.description;

      _filterItems(_categoryId);
    }
  }

  void _filterItems(int? categoryId) {
    if (categoryId == null) return;

    setState(() {
      _loadingItems = true;
      _filteredItems = _allItems
          .where((i) => i.category?.id == categoryId)
          .toList();
      _itemId = null;
      _loadingItems = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      if (isEdit) {
        await widget.repo.updateFoundItem(
          widget.existing!.id,
          categoryId: _categoryId,
          itemId: _itemId,
          foundLocation: _location,
          description: _description,
        );
      } else {
        await widget.repo.createFoundItem(
          categoryId: _categoryId!,
          itemId: _itemId!,
          foundLocation: _location,
          description: _description,
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Found Item' : 'Report Found Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  _categoryId = v;
                  _filterItems(v);
                },
                validator: (v) => v == null ? 'Select category' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                value: _itemId,
                decoration: const InputDecoration(labelText: 'Item'),
                items: _filteredItems
                    .map(
                      (i) => DropdownMenuItem(
                    value: i.id,
                    child: Text(i.name),
                  ),
                )
                    .toList(),
                onChanged: _loadingItems ? null : (v) => setState(() => _itemId = v),
                validator: (v) => v == null ? 'Select item' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Found Location'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _location = v,
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
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
