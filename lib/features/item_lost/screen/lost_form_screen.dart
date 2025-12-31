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
      final results = await Future.wait([
        categoryRepo.getCategories(),
        itemRepo.getItems(),
      ]);

      if (!mounted) return;

      setState(() {
        _categories = results[0] as List<Category>;
        _items = results[1] as List<Item>;

        if (isEdit) {
          final lost = widget.existing!;
          _categoryId = lost.category?.id;
          _itemId = lost.item?.id;
          _location = lost.lostLocation;
          _description = lost.description;

          _filteredItems = _items
              .where((i) => i.category?.id == _categoryId)
              .toList();

          if (lost.item == null && lost.customItemName != null) {
            _useCustomItem = true;
            _customItemName = lost.customItemName;
            _itemId = -1;
          }
        }

        _loadingData = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingData = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load data')));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      int finalItemId;

      if (_useCustomItem && _customItemName != null) {
        final itemRepo = ItemRepository(widget.repo.api);

        final newItem = await itemRepo.createItem(
          name: _customItemName!,
          categoryId: _categoryId,
          brand: null,
          color: null,
        );

        finalItemId = newItem.id;
      } else {
        finalItemId = _itemId!;
      }
      if (isEdit) {
        await widget.repo.updateLostItem(
          widget.existing!.id,
          categoryId: _categoryId,
          itemId: finalItemId,
          lostLocation: _location,
          description: _description,
        );
      } else {
        await widget.repo.createLostItem(
          categoryId: _categoryId!,
          itemId: finalItemId,
          lostLocation: _location,
          description: _description,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        icon: isEdit ? Icons.edit_note : Icons.report_gmailerrorred,
        showBackButton: true,
        title: isEdit ? 'Edit Laporan Kehilangan' : 'Lapor Kehilangan',
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          icon: Icon(
                            Icons.category_outlined,
                            color: AppColor.primary,
                          ),
                          border: InputBorder.none,
                        ),
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        validator: (v) => v == null ? 'Pilih kategori' : null,
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
                    ),

                    _buildFieldContainer(
                      child: DropdownButtonFormField<int>(
                        value: _itemId,
                        decoration: const InputDecoration(
                          labelText: 'Nama Barang',
                          icon: Icon(
                            Icons.inventory_2_outlined,
                            color: AppColor.primary,
                          ),
                          border: InputBorder.none,
                        ),
                        hint: const Text("Pilih Barang"),
                        items: [
                          ..._filteredItems.map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                          const DropdownMenuItem<int>(
                            value: -1,
                            child: Text(
                              '+ Lainnya / Tidak ada di list',
                              style: TextStyle(
                                color: AppColor.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        validator: (v) => (v == null && !_useCustomItem)
                            ? 'Pilih barang'
                            : null,
                        onChanged: (value) {
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
                      ),
                    ),

                    // Custom Item Name Input (Animated)
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
                      crossFadeState: _useCustomItem
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),

                    const SizedBox(height: 16),

                    // --- SECTION 2: LOCATION & DESCRIPTION ---
                    _buildSectionTitle("LOKASI & KETERANGAN"),

                    _buildFieldContainer(
                      child: TextFormField(
                        initialValue: _location,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi Kehilangan',
                          hintText: "Contoh: Kantin Asrama",
                          icon: Icon(
                            Icons.location_off_outlined,
                            color: AppColor.primary,
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Lokasi wajib diisi'
                            : null,
                        onSaved: (v) => _location = v,
                      ),
                    ),

                    _buildFieldContainer(
                      child: TextFormField(
                        initialValue: _description,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi Tambahan',
                          hintText: "Ciri-ciri, waktu kejadian, dll...",
                          icon: Icon(
                            Icons.description_outlined,
                            color: AppColor.primary,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: 4,
                        onSaved: (v) => _description = v,
                      ),
                    ),

                    const SizedBox(height: 80), // Space for FAB
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
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
