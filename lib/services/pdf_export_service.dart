// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/bottom_bar_model.dart';
import '../data/collections/song.dart';

class PdfExportService {
  static Future<void> exportSongToPdf({
    required String title,
    required String artist,
    required String difficulty,
    required String capo,
    required String tuning,
    required String lyricsWithChords,
  }) async {
    final pdf = pw.Document();

    final titleFont = await PdfGoogleFonts.cormorantBold();
    final dataFont = await PdfGoogleFonts.cormorantRegular();
    final bodyFont = await PdfGoogleFonts.ubuntuMonoRegular();
    final chordFont = await PdfGoogleFonts.ubuntuMonoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(60),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: titleFont,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Artiste : $artist",
                style: pw.TextStyle(fontSize: 12, font: dataFont),
              ),
              pw.Text(
                "Difficulté : $difficulty",
                style: pw.TextStyle(fontSize: 12, font: dataFont),
              ),
              pw.Text(
                "Capo : $capo",
                style: pw.TextStyle(fontSize: 12, font: dataFont),
              ),
              pw.Text(
                "Accordage : $tuning",
                style: pw.TextStyle(fontSize: 12, font: dataFont),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              ...buildLyricsWithChords(lyricsWithChords, chordFont, bodyFont),
            ],
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    final safeTitle = title.replaceAll(RegExp(r'[^\w\s\-]'), '').trim();
    final date = DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now());

    final fileName = '${safeTitle}_$date.pdf';

    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes);

    final params = SaveFileDialogParams(
      sourceFilePath: tempFile.path,
      fileName: fileName,
    );

    final savedPath = await FlutterFileDialog.saveFile(params: params);

    if (savedPath == null) {
      BottomBarModel.showBottomBar(
        message: "Sauvegarde du fichier annulée ou échouée.",
      );
    } else {
      BottomBarModel.showBottomBar(
        message: "PDF enregistré à l'emplacement : $savedPath",
      );
    }
  }

  static Future<void> exportSongbook({
    required List<Song> songs,
    required String title,
    required bool withTableOfContents,
    required bool withCoverPage,
  }) async {
    final pdf = pw.Document();

    final titleFont = await PdfGoogleFonts.cormorantBold();
    final dataFont = await PdfGoogleFonts.cormorantRegular();
    final bodyFont = await PdfGoogleFonts.ubuntuMonoRegular();
    final chordFont = await PdfGoogleFonts.ubuntuMonoBold();

    if (withCoverPage) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(title,
                      style: pw.TextStyle(
                          font: titleFont,
                          fontSize: 40,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text("${songs.length} chansons",
                      style: pw.TextStyle(font: dataFont, fontSize: 20)),
                  pw.SizedBox(height: 10),
                  pw.Text(
                      "Généré le ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                      style: pw.TextStyle(
                          font: dataFont,
                          fontSize: 16,
                          color: PdfColors.grey700)),
                  pw.SizedBox(height: 50),
                  pw.Text("Chords - Open Source App",
                      style: pw.TextStyle(
                          font: dataFont,
                          fontSize: 10,
                          color: PdfColors.grey500)),
                ],
              ),
            );
          },
        ),
      );
    }

    if (withTableOfContents) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
                level: 0,
                child: pw.Text("Table des matières",
                    style: pw.TextStyle(
                        font: titleFont,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),
            ...songs.map((s) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          child: pw.Text(s.title ?? "Sans titre",
                              style:
                                  pw.TextStyle(font: dataFont, fontSize: 14))),
                      pw.Text(s.artist ?? "",
                          style: pw.TextStyle(
                              font: dataFont,
                              fontSize: 14,
                              color: PdfColors.grey700)),
                    ])))
          ],
        ),
      );
    }

    for (var song in songs) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(50),
          footer: (context) {
            return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Chords - Open Source App",
                    style: pw.TextStyle(
                        font: dataFont, fontSize: 8, color: PdfColors.grey500),
                  ),
                  pw.Text(
                    "${context.pageNumber}",
                    style: pw.TextStyle(
                        font: dataFont, fontSize: 10, color: PdfColors.black),
                  ),
                ]);
          },
          build: (context) => [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  song.title ?? "Sans titre",
                  style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      font: titleFont),
                ),
                pw.Text(
                  song.artist ?? "Artiste inconnu",
                  style: pw.TextStyle(
                      fontSize: 16, font: dataFont, color: PdfColors.grey800),
                ),
                pw.SizedBox(height: 5),
                pw.Row(children: [
                  if (song.capo != null && song.capo!.isNotEmpty)
                    pw.Text("Capo: ${song.capo}  |  ",
                        style: pw.TextStyle(fontSize: 10, font: dataFont)),
                  if (song.tuning != null && song.tuning!.isNotEmpty)
                    pw.Text("Tuning: ${song.tuning}  |  ",
                        style: pw.TextStyle(fontSize: 10, font: dataFont)),
                  pw.Text("Difficulty: ${song.difficulty ?? 'N/A'}",
                      style: pw.TextStyle(fontSize: 10, font: dataFont)),
                ]),
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                pw.SizedBox(height: 15),
                ...buildLyricsWithChords(
                    song.lyricsWithChords ?? "", chordFont, bodyFont),
              ],
            ),
          ],
        ),
      );
    }

    final bytes = await pdf.save();
    final fileName =
        'Songbook_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes);

    final params =
        SaveFileDialogParams(sourceFilePath: tempFile.path, fileName: fileName);
    final savedPath = await FlutterFileDialog.saveFile(params: params);

    if (savedPath != null) {
      BottomBarModel.showBottomBar(message: "Recueil PDF sauvegardé !");
    }
  }

  static List<pw.Widget> buildLyricsWithChords(
    String lyricsWithChords,
    pw.Font chordFont,
    pw.Font bodyFont,
  ) {
    final lines = lyricsWithChords.split('\n');
    final widgets = <pw.Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final currentLine =
          lines[i].trimRight();

      if (_isPositionIndicator(currentLine)) {
        widgets.add(pw.SizedBox(height: 10));
        widgets.add(
          pw.Text(
            currentLine.trim(),
            style: pw.TextStyle(
              font: bodyFont,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey,
            ),
          ),
        );
        widgets.add(pw.SizedBox(height: 4));
        continue;
      }

      if (_isChordLine(currentLine) &&
          i + 1 < lines.length &&
          !_isChordLine(lines[i + 1])) {
        final chordLine = currentLine;
        final lyricLine = lines[i + 1].trimRight();

        widgets.add(
          pw.Text(
            chordLine,
            style: pw.TextStyle(
              font: chordFont,
              fontSize: 10,
              color: PdfColors.black,
            ),
          ),
        );
        widgets.add(
          pw.Text(
            lyricLine,
            style: pw.TextStyle(
              font: bodyFont,
              fontSize: 10,
              color: PdfColors.black,
            ),
          ),
        );
        i++;
      } else {
        widgets.add(
          pw.Text(
            currentLine,
            style: pw.TextStyle(
              font: bodyFont,
              fontSize: 10,
              color: PdfColors.black,
            ),
          ),
        );
      }
    }
    return widgets;
  }

  static bool _isChordLine(String line) {
    final chordRegex = RegExp(
        r'^[A-G](?:[#b])?(?:m|maj|min|sus|dim|aug|add|7|9|11|13)?(?:\/[A-G](?:[#b])?(?:m|maj|min|sus|dim|aug|add|7|9|11|13)?)?$');
    final tokens = line.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    if (tokens.isEmpty) return false;
    return tokens.every((token) => chordRegex.hasMatch(token));
  }

  static bool _isPositionIndicator(String line) {
    final positionRegex = RegExp(
        r'^\[(Intro|Interlude|Verse|Chorus|Refrain|Pont|Couplet|Pre-chorus|Bridge|Break|Solo|Instrumental|Outro)(?:\s+\d+)?\]$',
        caseSensitive: false);
    return positionRegex.hasMatch(line.trim());
  }
}
