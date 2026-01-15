import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {

  final TextEditingController controller;
  final bool hasSearched;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.hasSearched,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSearch,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon: hasSearched
              ? IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onClear,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}