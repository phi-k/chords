// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

Widget buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(title, style: const TextStyle(fontFamily: 'Cormorant', fontSize: 18, fontWeight: FontWeight.bold)),
  );
}

Widget buildChoiceChip(List<String> labels, List<String> values, String groupValue, Function(String) onSelected) {
  return Wrap(
    spacing: 8.0,
    children: List<Widget>.generate(labels.length, (int index) {
      return ChoiceChip(
        label: Text(labels[index]),
        selected: groupValue == values[index],
        onSelected: (bool selected) { if (selected) onSelected(values[index]); },
        selectedColor: Colors.red.withAlpha(26),
        backgroundColor: Colors.grey.shade100,
        labelStyle: TextStyle(fontFamily: 'Cormorant', color: groupValue == values[index] ? Colors.red : Colors.black, fontWeight: groupValue == values[index] ? FontWeight.bold : FontWeight.normal),
        shape: StadiumBorder(side: BorderSide(color: groupValue == values[index] ? Colors.red : Colors.grey.shade300)),
      );
    }),
  );
}

Widget buildSwitchOption(String title, String subtitle, bool value, Function(bool) onChanged) {
  return SwitchListTile(
    title: Text(title, style: const TextStyle(fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
    subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontFamily: 'Cormorant')) : null,
    value: value,
    onChanged: onChanged,
    activeThumbColor: Colors.red,
    contentPadding: EdgeInsets.zero,
  );
}

Widget buildRadioGroup(Map<String, String> options, String groupValue, Function(String?) onChanged) {
  return RadioGroup<String>(
    groupValue: groupValue,
    onChanged: onChanged,
    child: Column(
      children: options.entries.map((entry) {
        return RadioListTile<String>(
          title: Text(entry.value, style: const TextStyle(fontFamily: 'Cormorant')),
          value: entry.key,
          activeColor: Colors.red,
        );
      }).toList(),
    ),
  );
}