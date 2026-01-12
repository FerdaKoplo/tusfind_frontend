import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/repositories/admin_category_repository.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/action_modal.dart'; // Import this
import 'package:tusfind_frontend/core/widgets/confirmation_dialog.dart'; // Import this
import 'package:tusfind_frontend/features/admin/screen/admin_categogry_form_screen.dart';

class AdminCategoryListScreen extends StatefulWidget {
  final String token;

  const AdminCategoryListScreen({super.key, required this.token});

  @override
  State<AdminCategoryListScreen> createState() =>
      _AdminCategoryListScreenState();
}

class _AdminCategoryListScreenState extends State<AdminCategoryListScreen> {
  late AdminCategoryRepository _repository;
  late Future<List<Category>> _future;
  List<Category> allItems = [];
  List<Category> filteredItems = [];

  @override
  void initState() {
    super.initState();
    final apiService = ApiService(token: widget.token);
    _repository = AdminCategoryRepository(apiService);
    _future = _repository.getCategories();
  }

  void _refresh() {
    setState(() {
      _future = _repository.getCategories();
      filteredItems.clear();
    });
  }

  Future<void> _navigateToAddEdit({Category? category}) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdminCategoryFormScreen(token: widget.token, category: category),
      ),
    );

    if (result == true) {
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan")));
    }
  }

  void _deleteCategory(int id) async {
    Navigator.pop(context);

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: "Hapus Kategori?",
        subtitle:
            "Tindakan ini tidak dapat dibatalkan. Data yang dihapus akan hilang permanen.",
        confirmLabel: "Hapus",
        isDestructive: true,
      ),
    );

    if (confirm == true) {
      try {
        await _repository.deleteCategory(id);
        _refresh();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Kategori dihapus")));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _showOptions(Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ActionModal(
          title: category.name,
          children: [
            ActionModalOption(
              icon: Icons.edit_note_rounded,
              color: Colors.blue,
              title: "Edit Kategori",
              subtitle: "Ubah nama atau deskripsi",
              onTap: () {
                Navigator.pop(context);
                _navigateToAddEdit(category: category);
              },
            ),
            ActionModalOption(
              icon: Icons.delete_outline_rounded,
              color: Colors.red,
              title: "Hapus Kategori",
              subtitle: "Data akan dihapus permanen",
              isDestructive: true,
              onTap: () => _deleteCategory(category.id),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AppAppBar(
        icon: Icons.category_rounded,
        title: 'Kelola Kategori',
      ),
      body: FutureBuilder<List<Category>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          allItems = snapshot.data!;
          List<Category> displayList = filteredItems;

          if (displayList.isEmpty && allItems.isNotEmpty) {
            displayList = List.from(allItems);
            displayList.sort((a, b) => b.id.compareTo(a.id));
          }

          if (displayList.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: displayList.length,
              itemBuilder: (_, index) {
                final category = displayList[index];
                return _buildCategoryCard(category);
              },
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 130),
        child: FloatingActionButton.extended(
          backgroundColor: AppColor.primary,
          onPressed: () => _navigateToAddEdit(),
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: const Text("Tambah", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOptions(category),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.label_outline, color: AppColor.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (category.description != null &&
                          category.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          category.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    "#${category.id}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada kategori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Tap tombol + untuk menambah',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
