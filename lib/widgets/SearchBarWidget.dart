import 'package:flutter/material.dart';
import '../modele/ProductSuggestion.dart';
import '../service/ApiService.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool hasSearched;
  final Function(String) onSearch;
  final VoidCallback onClear;
  final bool isloading;
  final Function(bool) onFocusChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.hasSearched,
    required this.onSearch,
    required this.onClear,
    required this.isloading,
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
      setState(() => _isFocused = _focusNode.hasFocus);
      widget.onFocusChanged(_focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // --- FONCTION POUR LA SURBRILLANCE ---
  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(text, style: const TextStyle(fontSize: 14));
    }

    final int startIndex = text.toLowerCase().indexOf(query.toLowerCase());
    final int endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue), // Couleur et gras
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<ProductSuggestion>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      displayStringForOption: (ProductSuggestion option) => option.nom,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) return const Iterable.empty();
        return await ApiService().getSuggestions();
      },
      onSelected: (ProductSuggestion selection) {
        widget.onSearch(selection.nom);
        _focusNode.unfocus();
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: (value) => widget.onSearch(value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: (widget.hasSearched || _isFocused || widget.isloading)
                  ? IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  controller.clear();
                  widget.onClear();
                  focusNode.unfocus();
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final ProductSuggestion option = options.elementAt(index);
                  return ListTile(
                    // Appel de la fonction de surbrillance ici
                    title: _buildHighlightedText(option.nom, widget.controller.text),
                    trailing: Text(
                      option.nom,
                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
