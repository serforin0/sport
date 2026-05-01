import 'package:flutter/material.dart';

class SearchSelectionPage extends StatefulWidget {
  final String title;
  final List<String> initialItems;

  const SearchSelectionPage({
    Key? key,
    required this.title,
    required this.initialItems,
  }) : super(key: key);

  @override
  State<SearchSelectionPage> createState() => _SearchSelectionPageState();
}

class _SearchSelectionPageState extends State<SearchSelectionPage> {
  late List<String> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.initialItems);
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.initialItems);
      } else {
        _filteredItems = widget.initialItems
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Looking at mockups, the search screen has a white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black87),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: widget.title,
            hintStyle: const TextStyle(color: Colors.black38),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.black38),
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: _filteredItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _filteredItems[index],
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
            onTap: () {
              Navigator.of(context).pop(_filteredItems[index]);
            },
          );
        },
      ),
    );
  }
}
