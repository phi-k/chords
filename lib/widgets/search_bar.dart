// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../screens/search_page.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String)? onTextChanged;
  final String? filterText;
  final int? filteredCount;
  final VoidCallback? onSearchSubmitted;

  const SearchBarWidget({
    super.key,
    this.onTextChanged,
    this.filterText,
    this.filteredCount,
    this.onSearchSubmitted,
  });

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  void _onSearch() {
    if (widget.onSearchSubmitted != null) {
      widget.onSearchSubmitted!();
    } else {
      final searchTerm = _controller.text;
      if (searchTerm.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(searchTerm: searchTerm),
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterText != null && widget.filterText != _controller.text) {
      _controller.text = widget.filterText!;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 18,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchBarHint,
                  hintStyle: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                onChanged: widget.onTextChanged,
                onSubmitted: (value) {
                  if ((widget.filteredCount ?? 0) == 0) {
                    _onSearch();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: _onSearch,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
