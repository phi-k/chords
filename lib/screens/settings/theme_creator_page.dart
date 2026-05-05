import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'dart:io';
import '../../l10n/app_localizations.dart';
import '../../models/app_theme.dart';
import '../../providers/settings_provider.dart';

class ThemeCreatorPage extends ConsumerStatefulWidget {
  final AppTheme? existingTheme;

  const ThemeCreatorPage({super.key, this.existingTheme});

  @override
  ConsumerState<ThemeCreatorPage> createState() => _ThemeCreatorPageState();
}

class _ThemeCreatorPageState extends ConsumerState<ThemeCreatorPage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _coverCtrl = TextEditingController();

  Color _primaryColor = Colors.red;
  Color _bgColor = Colors.black;
  Color _textColor = Colors.white;
  bool _hasContrastWarning = false;

  double _calculateContrast(Color c1, Color c2) {
    final l1 = c1.computeLuminance();
    final l2 = c2.computeLuminance();
    return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05);
  }

  void _updateContrast() {
    setState(() {
      _hasContrastWarning = _calculateContrast(_bgColor, _textColor) < 4.5;
    });
  }

  Future<void> _pickCoverImage() async {
    final messenger = ScaffoldMessenger.of(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      try {
        final sourceFile = File(result.files.single.path!);
        final appDocDir = await getApplicationDocumentsDirectory();
        final coversDir = Directory('${appDocDir.path}/theme_covers');

        if (!await coversDir.exists()) {
          await coversDir.create(recursive: true);
        }

        final fileName =
            'cover_${DateTime.now().millisecondsSinceEpoch}${sourceFile.path.split('.').last}';
        final destFile = File('${coversDir.path}/$fileName');

        await sourceFile.copy(destFile.path);

        setState(() {
          _coverCtrl.text = 'local://${destFile.path}';
        });
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la copie de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _enterCoverUrl() async {
    final urlController = TextEditingController(text: _coverCtrl.text);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Saisir l\'URL de la photo',
          style:
              TextStyle(fontFamily: 'Cormorant', fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: urlController,
          style: const TextStyle(fontFamily: 'UbuntuMono'),
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _coverCtrl.text = urlController.text;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingTheme != null) {
      _nameCtrl.text = widget.existingTheme!.nameKey;
      _descCtrl.text = widget.existingTheme!.descKey;
      _coverCtrl.text = widget.existingTheme!.coverUrl;
      _primaryColor = widget.existingTheme!.primaryColor;
      _bgColor = widget.existingTheme!.backgroundColor;
      _textColor = widget.existingTheme!.textColor;
    }
    _updateContrast();
  }

  void _pickColor(
      String title, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'Cormorant')),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
        ],
      ),
    );
  }

  void _saveTheme() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.themeNameRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newTheme = AppTheme(
      id: widget.existingTheme?.id ??
          'custom_${DateTime.now().millisecondsSinceEpoch}',
      nameKey: _nameCtrl.text,
      descKey: _descCtrl.text,
      coverUrl: _coverCtrl.text,
      primaryColor: _primaryColor,
      backgroundColor: _bgColor,
      textColor: _textColor,
      isBuiltIn: false,
    );

    if (widget.existingTheme != null) {
      ref.read(settingsProvider.notifier).updateCustomTheme(newTheme);
    } else {
      ref.read(settingsProvider.notifier).addCustomTheme(newTheme);
    }
    ref.read(settingsProvider.notifier).setTheme(newTheme.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeBg = Theme.of(context).scaffoldBackgroundColor;
    final themeTxt = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        title: Text(
            widget.existingTheme != null
                ? "Modifier le thème"
                : loc.themeCreatorTitle,
            style: const TextStyle(
                fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildPreview(),
          const SizedBox(height: 30),
          TextField(
            controller: _nameCtrl,
            style: TextStyle(color: themeTxt, fontFamily: 'Cormorant'),
            decoration: InputDecoration(
                labelText: loc.themeNameHint,
                labelStyle: TextStyle(color: themeTxt)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            style: TextStyle(color: themeTxt, fontFamily: 'Cormorant'),
            decoration: InputDecoration(
                labelText: loc.themeDescHint,
                labelStyle: TextStyle(color: themeTxt)),
          ),
          const SizedBox(height: 16),
          Text(
            'Image de couverture',
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeTxt,
            ),
          ),
          const SizedBox(height: 12),
          if (_coverCtrl.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _coverCtrl.text.length > 50
                          ? '${_coverCtrl.text.substring(0, 47)}...'
                          : _coverCtrl.text,
                      style: TextStyle(
                        fontFamily: 'UbuntuMono',
                        fontSize: 12,
                        color: themeTxt,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _coverCtrl.clear()),
                    child: Icon(Icons.close, color: themeTxt, size: 18),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickCoverImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Importer une photo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _enterCoverUrl,
                  icon: const Icon(Icons.link),
                  label: const Text('Saisir l\'URL'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _colorRow(
              loc.themeColorPrimary,
              _primaryColor,
              (c) => setState(() {
                    _primaryColor = c;
                  })),
          const SizedBox(height: 16),
          _colorRow(
              loc.themeColorBackground,
              _bgColor,
              (c) => setState(() {
                    _bgColor = c;
                    _updateContrast();
                  })),
          const SizedBox(height: 16),
          _colorRow(
              loc.themeColorText,
              _textColor,
              (c) => setState(() {
                    _textColor = c;
                    _updateContrast();
                  })),
          if (_hasContrastWarning) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Contrast faible entre le texte et le fond (${_calculateContrast(_bgColor, _textColor).toStringAsFixed(2)}:1). Recommandé: ≥4.5:1',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontFamily: 'Cormorant',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveTheme,
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(loc.commonSave,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: 'Cormorant',
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _textColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: _textColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Titre de la chanson",
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              Icon(Icons.favorite, color: _primaryColor),
            ],
          ),
          Text(
            "Artiste d'exemple",
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 16,
              color: _textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMockChord("Am"),
              const SizedBox(width: 8),
              _buildMockChord("F"),
              const SizedBox(width: 8),
              _buildMockChord("C"),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Et les paroles de la chanson",
            style: TextStyle(
              fontFamily: 'UbuntuMono',
              fontSize: 16,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockChord(String chord) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        chord,
        style: TextStyle(
          fontFamily: 'UbuntuMono',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _colorRow(String title, Color color, Function(Color) onChanged) {
    return InkWell(
      onTap: () => _pickColor(title, color, onChanged),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Cormorant',
                    fontSize: 18)),
            Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}
