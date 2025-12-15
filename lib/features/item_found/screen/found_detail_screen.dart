import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';
import 'package:tusfind_frontend/features/item_found/screen/found_form_screen.dart';

class FoundDetailScreen extends StatefulWidget {
  final ItemFoundRepository repo;
  final int id;

  const FoundDetailScreen({
    super.key,
    required this.repo,
    required this.id,
  });

  @override
  State<FoundDetailScreen> createState() => _FoundDetailScreenState();
}

class _FoundDetailScreenState extends State<FoundDetailScreen> {
  ItemFound? _item;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await widget.repo.getFoundItemDetail(widget.id);
      setState(() {
        _item = res;
        _loading = false;
      });
    } catch (e) {
      _loading = false;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _edit() async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoundFormScreen(
          repo: widget.repo,
          categoryRepo: CategoryRepository(widget.repo.api),
          itemRepo: ItemRepository(widget.repo.api),
          existing: _item,
        ),
      ),
    );

    if (refresh == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_item == null) {
      return const Scaffold(
        body: Center(child: Text('Item not found')),
      );
    }

    final item = _item!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Item Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _edit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _row('Item', item.item?.name),
            _row('Category', item.category?.name),
            _row('Found Location', item.foundLocation),
            _row('Description', item.description),
            _row('Status', item.status),
            // _row('Reported At', item.createdAt?.toString()),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value ?? '-'),
        ],
      ),
    );
  }
}
