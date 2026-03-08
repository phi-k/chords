import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tab_source.dart';

class SourceManager {
  static const String _key = 'chords_tab_sources';

  static Future<List<TabSource>> getSources() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? sourcesJson = prefs.getStringList(_key);
    if (sourcesJson == null) {
      dev.log('📂 Aucune source enregistrée', name: 'SourceManager');
      return [];
    }
    final sources =
        sourcesJson.map((json) => TabSource.fromJson(json)).toList();
    dev.log('📂 ${sources.length} source(s) chargée(s)', name: 'SourceManager');
    return sources;
  }

  static Future<TabSource?> getActiveSource() async {
    final sources = await getActiveSources();
    return sources.isNotEmpty ? sources.first : null;
  }

  static Future<List<TabSource>> getActiveSources() async {
    final sources = await getSources();
    final active = sources.where((s) => s.isActive).toList();
    dev.log('🟢 ${active.length} source(s) active(s)', name: 'SourceManager');
    return active;
  }

  static Future<void> saveSource(TabSource newSource) async {
    dev.log('💾 Sauvegarde de la source: ${newSource.name}',
        name: 'SourceManager');
    List<TabSource> sources = await getSources();

    if (sources.isEmpty) {
      newSource = newSource.copyWith(isActive: true);
      dev.log('🟢 Première source, activée: ${newSource.name}',
          name: 'SourceManager');
    }

    final index = sources.indexWhere((s) => s.id == newSource.id);
    if (index >= 0) {
      dev.log('🔄 Mise à jour de la source existante', name: 'SourceManager');
      sources[index] = newSource;
    } else {
      dev.log('➕ Ajout d\'une nouvelle source', name: 'SourceManager');
      sources.add(newSource);
    }

    await _saveAll(sources);
    dev.log('✅ Source sauvegardée avec succès', name: 'SourceManager');
  }

  static Future<void> deleteSource(String id) async {
    dev.log('🗑️ Suppression de la source: $id', name: 'SourceManager');
    List<TabSource> sources = await getSources();
    sources.removeWhere((s) => s.id == id);
    await _saveAll(sources);
    dev.log('✅ Source supprimée avec succès', name: 'SourceManager');
  }

  static Future<void> toggleSourceActive(String id) async {
    dev.log('🔄 Toggle source active: $id', name: 'SourceManager');
    List<TabSource> sources = await getSources();
    sources = sources.map((s) {
      if (s.id == id) return s.copyWith(isActive: !s.isActive);
      return s;
    }).toList();
    await _saveAll(sources);
    final active = sources.where((s) => s.isActive).map((s) => s.name).toList();
    dev.log('🟢 Sources actives: $active', name: 'SourceManager');
  }

  static Future<void> setActiveSource(String id) async {
    await toggleSourceActive(id);
  }

  static Future<void> _saveAll(List<TabSource> sources) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = sources.map((s) => s.toJson()).toList();
    await prefs.setStringList(_key, jsonList);
  }
}
