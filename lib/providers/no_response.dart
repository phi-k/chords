// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, String>>> performSearchWithFallback(
  String searchTerm,
  Future<List<Map<String, String>>> Function(String query) searchFunction,
) async {
  var results = await searchFunction(searchTerm);
  if (results.isNotEmpty) return results;

  String modifiedTerm = searchTerm.toUpperCase().trim();
  results = await searchFunction(modifiedTerm);
  if (results.isNotEmpty) return results;

  List<String> suggestions = await getSearchSuggestions(searchTerm);
  if (suggestions.isNotEmpty) {
    log("Salut ! J'ai essayé ta requête '$searchTerm' sans succès. Peut-être voulais-tu dire : ${suggestions.join(', ')}. Je teste la première suggestion pour toi...");
    results = await searchFunction(suggestions.first);
    if (results.isNotEmpty) return results;
  }

  log("On a tout fait pour trouver des résultats, mais il faut croire que ça n'a rien donné :(");
  return [];
}

Future<List<String>> getSearchSuggestions(String query) async {
  final prefs = await SharedPreferences.getInstance();
  final geminiApiKey = prefs.getString('gemini_key');
  if (geminiApiKey == null || geminiApiKey.isEmpty) {
    log("Info : La clé API Gemini n'est pas configurée dans les paramètres.");
    return [];
  }

  final url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey';

  try {
    var dio = Dio();
    final headers = {'Content-Type': 'application/json'};

    final systemPrompt =
        "Tu es un assistant expert en recherche de chansons. Réponds-moi exclusivement sous le format JSON suivant, sans aucune explication supplémentaire :\n\n{\n  \"suggestions\": [\n    \"Suggestion 1\",\n    \"Suggestion 2\",\n    \"Suggestion 3\"\n  ]\n}\n\nChaque suggestion doit être une chaîne de caractères placée dans le tableau. Si tu n'as aucune suggestion, renvoie :\n\n{\n  \"suggestions\": null\n}";

    final userPrompt =
        "Je cherche une chanson avec la requête '$query' mais je n'obtiens aucun résultat. Que devrais-je essayer de rechercher ?";

    final data = {
      "contents": [
        {
          "parts": [
            {"text": systemPrompt},
            {"text": userPrompt}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "maxOutputTokens": 100,
      }
    };

    Response response = await dio.post(url,
        data: json.encode(data), options: Options(headers: headers));

    if (response.statusCode == 200) {
      final candidates = response.data['candidates'];
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content']['parts'][0]['text'] as String;
        final jsonString =
            content.replaceAll('```json', '').replaceAll('```', '').trim();

        final Map<String, dynamic> jsonResponse = json.decode(jsonString);

        if (jsonResponse["suggestions"] is List) {
          List<String> suggestions =
              List<String>.from(jsonResponse["suggestions"]);
          return suggestions;
        }
      }
    }
  } catch (e) {
    log("Erreur lors de l'appel à Gemini : $e");
    if (e is DioException) {
      log("Détails de l'erreur Dio : ${e.response?.data}");
    }
  }
  return [];
}
