// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/bottom_bar_model.dart';

class ExportService {
  static Future<void> exportSongList({
    required String content,
    required String format,
    required BuildContext context,
  }) async {
    try {
      Uint8List fileBytes;
      String fileName;

      final String date = DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now());

      if (format == 'txt') {
        fileName = 'song_list_$date.txt';
        fileBytes = Uint8List.fromList(utf8.encode(content));
      } else if (format == 'pdf') {
        fileName = 'song_list_$date.pdf';
        final pdf = pw.Document();
        final font = await PdfGoogleFonts.ubuntuMonoRegular();

        final List<String> lines = content.split('\n');

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (context) => lines
                .map((line) => pw.Text(
                      line,
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ))
                .toList(),
          ),
        );

        fileBytes = await pdf.save();
      } else {
        throw Exception("Format d'export non supporté");
      }

      final params = SaveFileDialogParams(
        data: fileBytes,
        fileName: fileName,
      );
      final savedPath = await FlutterFileDialog.saveFile(params: params);

      if (savedPath != null) {
        BottomBarModel.showBottomBar(message: "Export réussi !");
      } else {
        BottomBarModel.showBottomBar(message: "Export annulé.");
      }
    } catch (e) {
      BottomBarModel.showBottomBar(message: "Erreur lors de l'export : $e");
    }
  }
}
