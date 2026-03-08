import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bottom_bar_model.dart';
import '../l10n/app_localizations.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Mentions Légales & Licence",
          style: TextStyle(
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
            _buildSectionTitle("Préambule : Acceptation des Conditions"),
            _buildParagraph(
                "Toute installation, utilisation de l'application, ainsi que toute volonté de la modifier, de la forker ou de l'étendre, vaut acceptation pleine, entière et inconditionnelle des présentes conditions par l'utilisateur, la personne physique ou l'entité concernée."),
            _buildSectionTitle("1. Droits d'utilisation et Code Source"),
            _buildParagraph(
                "L'application Chords est un projet open-source dont l'accès au code source est actuellement restreint (privé). "
                "Les personnes disposant d'un accès légitime au dépôt GitHub officiel sont autorisées à :"),
            _buildBulletPoint("Consulter, copier et forker le code source."),
            _buildBulletPoint(
                "Modifier ou étendre les fonctionnalités de l'application pour un usage strictement privé."),
            _buildParagraph(
                "Cependant, tant que le dépôt GitHub original n'est pas rendu public par l'auteur, il est strictement interdit de rendre public un fork, une copie, une modification ou une extension de l'application. "
                "Le partage du code source ou de fichiers compilés (APK, IPA, etc.) en dehors du cadre privé défini est prohibé."),
            _buildSectionTitle("2. Attribution et Paternité"),
            _buildParagraph(
                "Toute modification, fork ou extension de l'application doit impérativement conserver, de manière visible et non altérée, la section relative à l'auteur original dans la page des paramètres. "
                "Il est interdit de modifier l'interface utilisateur (UI) dans le but de masquer ou d'obfusquer l'identité du créateur original."),
            _buildParagraph(
                "Les contributeurs peuvent ajouter leur nom en dessous de celui de l'auteur original pour signaler leurs modifications, mais ne peuvent en aucun cas s'attribuer la paternité globale de l'œuvre. "
                "Tout partage autorisé doit stipuler clairement que l'application originale a été développée par phi-k."),
            _buildSectionTitle("3. Distribution et Sécurité"),
            _buildParagraph(
                "Pour garantir l'intégrité et la sécurité de l'application, la seule source autorisée pour l'application originale non modifiée est le dépôt GitHub privé officiel. "
                "Toute autre source de distribution doit être considérée comme non autorisée et potentiellement risquée."),
            _buildSectionTitle("4. Services Tiers et Mises à jour"),
            _buildParagraph(
                "Le site web 'chords.ovh' est une entité indépendante de l'application open-source. Il fournit des services optionnels (partage de setlists, mises à jour automatiques) et son code source n'est pas ouvert."),
            _buildParagraph(
                "Dans le cadre d'une version modifiée ou d'un fork :"),
            _buildBulletPoint(
                "Les fonctionnalités liées à chords.ovh peuvent être supprimées."),
            _buildBulletPoint(
                "Le lien de mise à jour automatique ne doit JAMAIS être modifié sans avertir explicitement l'utilisateur que la mise à jour ne provient pas du créateur original, ceci pour des raisons évidentes de sécurité."),
            _buildSectionTitle("5. Philosophie et Gratuité"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Text(
                  "Chords est un outil musical gratuit, disponible pour tous, et le restera pour toujours.",
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
            _buildParagraph(
                "En accord avec cette philosophie, toute version de l'application, qu'elle soit originale ou modifiée, doit impérativement :"),
            _buildBulletPoint(
                "Être distribuée gratuitement et sans but lucratif."),
            _buildBulletPoint("Être exempte de toute forme de publicité."),
            _buildBulletPoint(
                "Être exempte de tout logiciel malveillant ou contenu inapproprié."),
            _buildParagraph(
                "Si une version modifiée est rendue disponible au grand public (dans le respect des conditions de l'article 1), elle doit obligatoirement être open-source et fournir un lien clair vers son code source."),
            _buildSectionTitle("6. Inaltérabilité des Conditions"),
            _buildParagraph(
                "Les présentes conditions légales et la licence d'utilisation constituent le socle éthique de l'application Chords. Elles ne peuvent en aucun cas être modifiées, supprimées, ou dissimulées dans une version modifiée ou un fork de l'application."),
            _buildParagraph(
                "Toute version de l'application a l'obligation stricte de :"),
            _buildBulletPoint(
                "Intégrer et présenter ces conditions de manière accessible aux utilisateurs."),
            _buildBulletPoint(
                "Respecter intégralement les règles ici énoncées."),
            _buildBulletPoint(
                "Partager et perpétuer la philosophie de l'application originale."),
            _buildSectionTitle("7. Contact et Signalement"),
            _buildParagraph(
                "Les utilisateurs acceptant ces conditions peuvent contacter le créateur pour signaler des bugs, proposer des améliorations ou demander l'accès au fichier d'installation (APK) pour un usage privé."),
            _buildSectionTitle(
                AppLocalizations.of(context)!.legalDonationTitle),
            _buildParagraph(AppLocalizations.of(context)!.legalDonationContent),
            const SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: "pk@chords.ovh"));
                  BottomBarModel.showBottomBar(
                      message: "Adresse email copiée !");
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
