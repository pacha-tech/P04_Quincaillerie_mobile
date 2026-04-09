
/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/modele/ProductSuggestion.dart';
import '../../provider/SuggestionProvider.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool hasSearched;
  final Function(String) onSearch;
  final VoidCallback onClear;
  //final bool isloading;
  final Function(bool) onFocusChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.hasSearched,
    required this.onSearch,
    required this.onClear,
    //required this.isloading,
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
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
        widget.onFocusChanged(_focusNode.hasFocus);
      }
    });
    // Charge les suggestions au démarrage si nécessaire
    Future.microtask(() =>
        context.read<SuggestionProvider>().loadSuggestions());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // --- FONCTION POUR LA SURBRILLANCE ---
  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(text, style: const TextStyle(fontSize: 14, color: Colors.black));
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
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // On récupère les suggestions une seule fois dans le build
    final allProducts = context.watch<SuggestionProvider>().suggestions;

    return RawAutocomplete<ProductSuggestion>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      displayStringForOption: (ProductSuggestion option) => option.nom,

      // LOGIQUE DE FILTRAGE
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable.empty();

        return allProducts.where((ProductSuggestion option) {
          return option.nom.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
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
              suffixIcon: (widget.hasSearched || _isFocused)
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
            color: Colors.white,
            child: Container(
              // On ajuste la largeur pour qu'elle corresponde à la barre
              width: MediaQuery.of(context).size.width - 40,
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final ProductSuggestion option = options.elementAt(index);
                  return ListTile(
                    title: _buildHighlightedText(option.nom, widget.controller.text),
                    // Optionnel : afficher la catégorie ou l'unité à droite
                    trailing: Text(
                      option.unite ?? "",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import '../../data/modele/ProductSuggestion.dart';
import '../../provider/SuggestionProvider.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool hasSearched;
  final Function(String) onSearch;
  final VoidCallback onClear;
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
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
        widget.onFocusChanged(_focusNode.hasFocus);
      }
    });
    Future.microtask(
            () => context.read<SuggestionProvider>().loadSuggestions());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // ── Surbrillance de la partie recherchée ────────────────────────────────────
  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      );
    }

    final int start = text.toLowerCase().indexOf(query.toLowerCase());
    final int end = start + query.length;

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = context.watch<SuggestionProvider>().suggestions;

    return RawAutocomplete<ProductSuggestion>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      displayStringForOption: (option) => option.nom,

      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) return const Iterable.empty();
        return allProducts.where((option) =>
            option.nom.toLowerCase().contains(value.text.toLowerCase()));
      },

      onSelected: (ProductSuggestion selection) {
        widget.onSearch(selection.nom);
        _focusNode.unfocus();
      },

      // ── Champ texte ──────────────────────────────────────────────────────
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          decoration: BoxDecoration(
            // Fond blanc semi-transparent sur l'appbar sombre
            color: _isFocused
                ? Colors.white
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isFocused
                  ? Colors.white
                  : Colors.white.withOpacity(0.0),
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: widget.onSearch,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontSize: 13,
              color: _isFocused ? AppColors.textPrimary : Colors.white,
            ),
            decoration: InputDecoration(
              hintText: "Rechercher un produit...",
              hintStyle: TextStyle(
                fontSize: 12,
                color: _isFocused ? Colors.grey.shade400 : Colors.white60,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 17,
                color: _isFocused ? AppColors.primary : Colors.white70,
              ),
              suffixIcon: (widget.hasSearched || _isFocused)
                  ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: _isFocused
                      ? AppColors.textMuted
                      : Colors.white70,
                ),
                onPressed: () {
                  controller.clear();
                  widget.onClear();
                  focusNode.unfocus();
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        );
      },

      // ── Liste de suggestions ──────────────────────────────────────────────
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(16),
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              constraints: const BoxConstraints(maxHeight: 260),
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border:
                Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 52,
                  ),
                  itemBuilder: (context, index) {
                    final ProductSuggestion option =
                    options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            // Icône de suggestion
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.06),
                                borderRadius:
                                BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildHighlightedText(
                                option.nom,
                                widget.controller.text,
                              ),
                            ),
                            if (option.unite != null &&
                                option.unite!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withOpacity(0.06),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Text(
                                  option.unite!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}