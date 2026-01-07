import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/models/item_model.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/toast.dart';

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
  bool _loadingData = true;
  bool _loadingItems = false;

  String? _customItemName;
  bool _useCustomItem = false;

  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final results = await Future.wait([
        widget.categoryRepo.getCategories(),
        widget.itemRepo.getItems(),
      ]);

      if (!mounted) return;

      setState(() {
        _categories = results[0] as List<Category>;
        _allItems = results[1] as List<Item>;

        if (isEdit) {
          final found = widget.existing!;
          _categoryId = found.category?.id;
          _itemId = found.item?.id;
          _location = found.foundLocation;
          _description = found.description;

          _filteredItems = _allItems.where((i) => i.category?.id == _categoryId).toList();

          if (found.item == null && found.customItemName != null) {
            _useCustomItem = true;
            _customItemName = found.customItemName;
            _itemId = -1;
          }
        }
        _loadingData = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  void _filterItems(int? categoryId) {
    if (categoryId == null) return;
    setState(() {
      _loadingItems = true;
      _filteredItems = _allItems.where((i) => i.category?.id == categoryId).toList();
      if (!isEdit || _categoryId != widget.existing?.category?.id) {
        _itemId = null;
        _useCustomItem = false;
      }
      _loadingItems = false;
    });
  }

  Future<void> _pickImage() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
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
          images: _selectedImages, // Multi-image support
        );
      }

      if (mounted) {
        TusToast.show(context, isEdit ? "Laporan diperbarui!" : "Laporan terbuat!", type: ToastType.success);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) TusToast.show(context, "Error: $e", type: ToastType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColor.primary, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, top: 20),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppAppBar(
        title: isEdit ? 'Edit Laporan Penemuan' : 'Lapor Penemuan',
        showBackButton: true,
        icon: isEdit ? Icons.edit_note : Icons.add_location_alt,
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("FOTO BARANG", Icons.camera_alt_rounded),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                child: Column(
                  children: [
                    if (_selectedImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                          itemBuilder: (context, index) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_selectedImages[index], width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4, right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedImages.removeAt(index)),
                                  child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    else
                      const Text("Belum ada foto dipilih", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text("TAMBAH FOTO"),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionTitle("DETAIL BARANG", Icons.inventory_2_rounded),
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: _inputDecoration("Kategori", Icons.category_rounded),
                items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) {
                  setState(() { _categoryId = v; _filterItems(v); });
                },
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _itemId,
                decoration: _inputDecoration("Nama Barang", Icons.shopping_bag_rounded),
                hint: Text(_loadingItems ? "Memuat..." : "Pilih Barang"),
                items: [
                  ..._filteredItems.map((i) => DropdownMenuItem(value: i.id, child: Text(i.name))),
                  const DropdownMenuItem<int>(value: -1, child: Text("+ Lainnya", style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold))),
                ],
                onChanged: (_loadingItems || _categoryId == null) ? null : (v) {
                  setState(() {
                    if (v == -1) { _itemId = -1; _useCustomItem = true; }
                    else { _itemId = v; _useCustomItem = false; _customItemName = null; }
                  });
                },
                validator: (v) => (v == null && !_useCustomItem) ? 'Pilih barang' : null,
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextFormField(
                    initialValue: _customItemName,
                    decoration: _inputDecoration("Nama Barang Custom", Icons.edit_note_rounded),
                    validator: (v) => (_useCustomItem && (v == null || v.isEmpty)) ? 'Wajib diisi' : null,
                    onSaved: (v) => _customItemName = v,
                  ),
                ),
                crossFadeState: _useCustomItem ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              _buildSectionTitle("LOKASI & KETERANGAN", Icons.location_on_rounded),
              TextFormField(
                initialValue: _location,
                decoration: _inputDecoration("Lokasi Ditemukan", Icons.map_rounded),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                onSaved: (v) => _location = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: _inputDecoration("Deskripsi", Icons.notes_rounded),
                maxLines: 4,
                onSaved: (v) => _description = v,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white),
        child: SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(isEdit ? 'PERBARUI' : 'KIRIM', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}