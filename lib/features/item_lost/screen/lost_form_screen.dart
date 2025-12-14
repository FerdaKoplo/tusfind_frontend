import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';



class LostFormScreen extends StatefulWidget {
  final ItemLostRepository repo;

  const LostFormScreen({super.key, required this.repo});

  @override
  State<LostFormScreen> createState() => _LostFormScreenState();
}

class _LostFormScreenState extends State<LostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _categoryId;
  int? _itemId;
  String? _location;
  String? _description;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      await widget.repo.createLostItem(
        categoryId: _categoryId!,
        itemId: _itemId!,
        lostLocation: _location,
        description: _description,
      );
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
      appBar: AppBar(title: const Text('Report Lost Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                onSaved: (v) => _location = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => _description = v,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child:
                _loading ? const CircularProgressIndicator() : const Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
