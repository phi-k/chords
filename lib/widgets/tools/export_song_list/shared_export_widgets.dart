// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

Widget buildSectionTitle(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(title,
        style: TextStyle(
            fontFamily: 'Cormorant',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
        )),
  );
}

Widget buildChoiceChip(BuildContext context, List<String> labels, List<String> values,
    String groupValue, Function(String) onSelected) {
  return Wrap(
    spacing: 8.0,
    children: List<Widget>.generate(labels.length, (int index) {
      return ChoiceChip(
        label: Text(labels[index]),
        selected: groupValue == values[index],
        onSelected: (bool selected) {
          if (selected) onSelected(values[index]);
        },
        selectedColor: Theme.of(context).primaryColor.withAlpha(26),
        backgroundColor: Theme.of(context).colorScheme.surface,
        labelStyle: TextStyle(
            fontFamily: 'Cormorant',
            color: groupValue == values[index] ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
            fontWeight: groupValue == values[index]
                ? FontWeight.bold
                : FontWeight.normal),
        shape: StadiumBorder(
            side: BorderSide(
                color: groupValue == values[index]
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3))),
      );
    }),
  );
}

Widget buildSwitchOption(
    BuildContext context, String title, String subtitle, bool value, Function(bool) onChanged) {
  return SwitchListTile(
    title: Text(title,
        style: TextStyle(
            fontFamily: 'Cormorant', fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
    subtitle: subtitle.isNotEmpty
        ? Text(subtitle, style: TextStyle(fontFamily: 'Cormorant', color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))
        : null,
    value: value,
    onChanged: onChanged,
    activeThumbColor: Theme.of(context).primaryColor,
    contentPadding: EdgeInsets.zero,
  );
}

Widget buildRadioGroup(BuildContext context, Map<String, String> options, String groupValue,
    Function(String?) onChanged) {
  return RadioGroup<String>(
    groupValue: groupValue,
    onChanged: onChanged,
    child: Column(
      children: options.entries.map((entry) {
        return RadioListTile<String>(
          title: Text(entry.value,
              style: TextStyle(fontFamily: 'Cormorant', color: Theme.of(context).colorScheme.onSurface)),
          value: entry.key,
          activeColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    ),
  );
}
