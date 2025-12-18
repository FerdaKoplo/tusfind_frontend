import 'package:flutter/material.dart';
import 'package:tusfind_frontend/models/item_models.dart';
import 'package:tusfind_frontend/services/api_service.dart';

class ItemPage extends StatefulWidget {
  final String type; // lost / found
  const ItemPage({super.key, required this.type});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List<Item> items = [];
  bool loading = true;

  String? selectedCategory;
  String searchLocation = '';

  final categories = ['Dompet', 'HP', 'Tas'];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => loading = true);
    items = await ApiService.getItems(
      type: widget.type,
      category: selectedCategory,
      location: searchLocation,
    );
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.type.toUpperCase()} ITEMS")),
      body: Column(
        children: [

          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari lokasi...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                searchLocation = v;
                fetchData();
              },
            ),
          ),

          // 🔽 FILTER
          DropdownButton<String>(
            value: selectedCategory,
            hint: Text("Pilih Kategori"),
            items: categories.map((c) {
              return DropdownMenuItem(value: c, child: Text(c));
            }).toList(),
            onChanged: (v) {
              setState(() => selectedCategory = v);
              fetchData();
            },
          ),

          // 🔄 LIST + PULL TO REFRESH
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchData,
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (c, i) {
                        final item = items[i];
                        return Card(
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text(
                                "${item.category} • ${item.location}\n${item.date}"),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
