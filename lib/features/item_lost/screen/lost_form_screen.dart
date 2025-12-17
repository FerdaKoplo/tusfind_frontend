import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/models/item_model.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';

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
      final categories = await categoryRepo.getCategories();
      final items = await itemRepo.getItems();

      setState(() {
        _categories = categories;
        _items = items;

        if (isEdit) {
          final lost = widget.existing!;
          _categoryId = lost.category?.id;
          _itemId = lost.item?.id;
          _location = lost.lostLocation;
          _description = lost.description;

          _filteredItems =
              _items.where((i) => i.category?.id == _categoryId).toList();
        }

        _loadingData = false;
      });
    } catch (e) {
      setState(() => _loadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load data')),
      );
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.primaryLight, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        icon: Icons.report,
        showBackButton: true,
        title: isEdit ? 'Edit Lost Item' : 'Report Lost Item',
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: _inputDecoration('Category'),
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
                        .where((i) => i.category?.id == _categoryId)
                        .toList();
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _itemId,
                decoration: _inputDecoration('Item'),
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
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextFormField(
                    decoration: _inputDecoration('Item Name'),
                    validator: (v) {
                      if (_useCustomItem && (v == null || v.isEmpty)) {
                        return 'Item name is required';
                      }
                      return null;
                    },
                    onSaved: (v) => _customItemName = v,
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _location,
                decoration: _inputDecoration('Lost Location'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _location = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: _inputDecoration('Description'),
                maxLines: 3,
                onSaved: (v) => _description = v,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _loading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    isEdit ? 'Update' : 'Submit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
