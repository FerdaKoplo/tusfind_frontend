import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/models/item_model.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart'; // Ensure this exists

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

  String? _customItemName;
  bool _useCustomItem = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final results = await Future.wait([
      widget.categoryRepo.getCategories(),
      widget.itemRepo.getItems(),
    ]);

    if (!mounted) return;

    setState(() {
      _categories = results[0] as List<Category>;
      _allItems = results[1] as List<Item>;
    });

    if (isEdit) {
      final found = widget.existing!;
      _categoryId = found.category?.id;
      _itemId = found.item?.id;
      _location = found.foundLocation;
      _description = found.description;

      _filterItems(_categoryId);

      if (found.item == null && found.customItemName != null) {
        _useCustomItem = true;
        _customItemName = found.customItemName;
        _itemId = -1;
      }
    }
  }

  void _filterItems(int? categoryId) {
    if (categoryId == null) return;

    setState(() {
      _loadingItems = true;
      _filteredItems = _allItems
          .where((i) => i.category?.id == categoryId)
          .toList();

      if (!isEdit || _categoryId != widget.existing?.category?.id) {
        _itemId = null;
        _useCustomItem = false;
      }

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
          itemId: _useCustomItem ? null : _itemId,
          customItemName: _useCustomItem ? _customItemName : null,
          foundLocation: _location,
          description: _description,
        );
      } else {
        await widget.repo.createFoundItem(
          categoryId: _categoryId!,
          itemId: _useCustomItem ? null : _itemId,
          customItemName: _useCustomItem ? _customItemName : null,
          foundLocation: _location,
          description: _description,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppAppBar(
        title: isEdit ? 'Edit Laporan Penemuan' : 'Lapor Penemuan',
        showBackButton: true,
        icon: isEdit ? Icons.edit_note : Icons.add_location_alt,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("DETAIL BARANG"),

              _buildFieldContainer(
                child: DropdownButtonFormField<int>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    icon: Icon(Icons.category_outlined, color: AppColor.primary),
                    border: InputBorder.none,
                  ),
                  items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _categoryId = v;
                      _filterItems(v);
                    });
                  },
                  validator: (v) => v == null ? 'Pilih kategori' : null,
                ),
              ),

              _buildFieldContainer(
                child: DropdownButtonFormField<int>(
                  value: _itemId,
                  decoration: const InputDecoration(
                    labelText: 'Nama Barang',
                    icon: Icon(Icons.inventory_2_outlined, color: AppColor.primary),
                    border: InputBorder.none,
                  ),
                  hint: Text(_loadingItems ? "Memuat..." : "Pilih Barang"),
                  items: [
                    ..._filteredItems.map((i) => DropdownMenuItem(value: i.id, child: Text(i.name))),
                    const DropdownMenuItem<int>(
                      value: -1,
                      child: Text(
                        '+ Lainnya / Tidak ada di list',
                        style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  onChanged: (_loadingItems || _categoryId == null)
                      ? null
                      : (value) {
                    setState(() {
                      if (value == -1) {
                        _itemId = -1;
                        _useCustomItem = true;
                      } else {
                        _itemId = value;
                        _useCustomItem = false;
                        _customItemName = null;
                      }
                    });
                  },
                  validator: (v) => (v == null && !_useCustomItem) ? 'Pilih barang' : null,
                ),
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildFieldContainer(
                  child: TextFormField(
                    initialValue: _customItemName,
                    decoration: const InputDecoration(
                      labelText: 'Sebutkan Nama Barang',
                      icon: Icon(Icons.edit, color: AppColor.primary),
                      border: InputBorder.none,
                    ),
                    validator: (v) {
                      if (_useCustomItem && (v == null || v.isEmpty)) {
                        return 'Nama barang wajib diisi';
                      }
                      return null;
                    },
                    onSaved: (v) => _customItemName = v,
                  ),
                ),
                crossFadeState: _useCustomItem ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle("LOKASI & KETERANGAN"),

              _buildFieldContainer(
                child: TextFormField(
                  initialValue: _location,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi Ditemukan',
                    hintText: "Contoh: Gedung TULT Lantai 3",
                    icon: Icon(Icons.location_on_outlined, color: AppColor.primary),
                    border: InputBorder.none,
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Lokasi wajib diisi' : null,
                  onSaved: (v) => _location = v ?? '',
                ),
              ),

              _buildFieldContainer(
                child: TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Tambahan',
                    hintText: "Warna, ciri-ciri khusus, kondisi...",
                    icon: Icon(Icons.description_outlined, color: AppColor.primary),
                    border: InputBorder.none,
                  ),
                  maxLines: 4,
                  onSaved: (v) => _description = v ?? '',
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: _loading
                ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
                : Text(
              isEdit ? 'PERBARUI LAPORAN' : 'KIRIM LAPORAN',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}