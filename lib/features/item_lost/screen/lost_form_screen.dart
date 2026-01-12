import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/models/item_model.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/toast.dart';

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

  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Logic remains the same as provided in your snippet...
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
        TusToast.show(context, "Gagal memuat data", type: ToastType.error);
      }
    }
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
          images: _selectedImages,
        );
      }

      if (mounted) {
        TusToast.show(
          context,
          "Laporan berhasil dikirim!",
          type: ToastType.success,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) TusToast.show(context, "Error: $e", type: ToastType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- REFINED UI COMPONENTS ---

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, top: 20),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColor.primary, size: 20),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppAppBar(
        icon: isEdit ? Icons.edit_note : Icons.report_gmailerrorred,
        showBackButton: true,
        title: isEdit ? 'Edit Laporan' : 'Lapor Kehilangan',
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
                    // --- IMAGE SECTION ---
                    _buildSectionTitle("FOTO BARANG", Icons.camera_alt_rounded),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          if (_selectedImages.isNotEmpty)
                            SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                separatorBuilder: (ctx, i) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) => Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _selectedImages[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () => _selectedImages.removeAt(index),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_search_rounded,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Belum ada foto dipilih",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(
                                Icons.add_a_photo_outlined,
                                size: 18,
                              ),
                              label: const Text("TAMBAH FOTO"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColor.primary,
                                side: const BorderSide(color: AppColor.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- DETAIL SECTION ---
                    _buildSectionTitle(
                      "DETAIL BARANG",
                      Icons.inventory_2_rounded,
                    ),
                    DropdownButtonFormField<int>(
                      value: _categoryId,
                      decoration: _inputDecoration(
                        "Kategori",
                        Icons.category_rounded,
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _itemId,
                      decoration: _inputDecoration(
                        "Nama Barang",
                        Icons.shopping_bag_rounded,
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
                            "+ Lainnya / Tidak ada di list",
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
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextFormField(
                          initialValue: _customItemName,
                          decoration: _inputDecoration(
                            "Sebutkan Nama Barang",
                            Icons.edit_note_rounded,
                          ),
                          validator: (v) =>
                              (_useCustomItem && (v == null || v.isEmpty))
                              ? 'Nama barang wajib diisi'
                              : null,
                          onSaved: (v) => _customItemName = v,
                        ),
                      ),
                      crossFadeState: _useCustomItem
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),

                    // --- LOCATION SECTION ---
                    _buildSectionTitle(
                      "LOKASI & KETERANGAN",
                      Icons.location_on_rounded,
                    ),
                    TextFormField(
                      initialValue: _location,
                      decoration: _inputDecoration(
                        "Lokasi Terakhir",
                        Icons.map_rounded,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Lokasi wajib diisi' : null,
                      onSaved: (v) => _location = v,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _description,
                      decoration:
                          _inputDecoration(
                            "Deskripsi Tambahan",
                            Icons.notes_rounded,
                          ).copyWith(
                            hintText:
                                "Contoh: Ada gantungan kunci, warna sedikit pudar...",
                          ),
                      maxLines: 4,
                      onSaved: (v) => _description = v,
                    ),
                    const SizedBox(height: 120), // Bottom padding for button
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
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
                    isEdit ? 'SIMPAN PERUBAHAN' : 'KIRIM LAPORAN',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
