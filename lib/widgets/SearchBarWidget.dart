import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool hasSearched;
  final Function(String) onSearch;
  final VoidCallback onClear;
  // Ajout de callbacks pour prévenir la HomePage de cacher les icônes
  final Function(bool) onFocusChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.hasSearched,
    required this.onSearch,
    required this.onClear,
    required this.onFocusChanged,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      // Notifie le parent pour cacher le logo/panier
      widget.onFocusChanged(_focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 40,
      // Si focus, il prend plus de place (géré par le parent via Expanded/Flexible)
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onSubmitted: widget.onSearch,
        textInputAction: TextInputAction.search, // Affiche la loupe sur le clavier
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon: (widget.hasSearched || _isFocused)
              ? IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              widget.onClear();
              _focusNode.unfocus(); // Ferme le clavier
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }
}
