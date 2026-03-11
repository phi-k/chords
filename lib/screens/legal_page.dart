// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bottom_bar_model.dart';
import '../l10n/app_localizations.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          loc.legalAppBarTitle,
          style: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Part I: License ──
            _buildPartHeader(loc.legalPartLicenseHeader),
            _buildSectionTitle(loc.legalSection1Title),
            _buildParagraph(loc.legalSection1P1),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: Text(
                  loc.legalSection1Link,
                  style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            _buildParagraph(loc.legalSection1P2),
            _buildBulletPoint(loc.legalSection1Bullet1),
            _buildBulletPoint(loc.legalSection1Bullet2),
            _buildBulletPoint(loc.legalSection1Bullet3),
            _buildParagraph(loc.legalSection1P3),
            _buildSectionTitle(loc.legalSection2Title),
            _buildParagraph(loc.legalSection2P1),
            _buildParagraph(loc.legalSection2P2),
            _buildSectionTitle(loc.legalSection3Title),
            _buildParagraph(loc.legalSection3P1),
            _buildParagraph(loc.legalSection3P2),
            _buildSectionTitle(loc.legalSection4Title),
            _buildParagraph(loc.legalSection4P1),
            // ── Part II: Philosophy ──
            _buildPartHeader(loc.legalPartPhilosophyHeader),
            _buildParagraph(loc.legalPhilosophyIntro),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Text(
                  loc.legalPhiloQuote,
                  style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            _buildParagraph(loc.legalPhiloP1),
            _buildBulletPoint(loc.legalPhiloBullet1),
            _buildBulletPoint(loc.legalPhiloBullet2),
            _buildBulletPoint(loc.legalPhiloBullet3),
            _buildParagraph(loc.legalPhiloP2),
            _buildSectionTitle(loc.legalDonationTitle),
            _buildParagraph(loc.legalDonationContent),
            const SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: "pk@chords.ovh"));
                  BottomBarModel.showBottomBar(message: loc.legalEmailCopied);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.mail_outline, size: 20, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "pk@chords.ovh",
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPartHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0, bottom: 4.0),
      child: Center(
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Cormorant',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 16,
          height: 1.4,
          color: Colors.black87,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 16,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
