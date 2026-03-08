import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../services/update_service.dart';
import '../../services/version_service.dart';
import '../../widgets/update_dialog.dart';
import '../../l10n/app_localizations.dart';

class VersionPage extends StatefulWidget {
  const VersionPage({super.key});

  @override
  State<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  String _currentVersion = '';
  String _versionCodename = '';
  List<Map<String, String>> _releases = [];
  bool _isLoading = true;
  bool _isCheckingUpdate = false;
  String? _updateStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final updateService = UpdateService();
      final releases = await updateService.getAllReleases();

      setState(() {
        _currentVersion = packageInfo.version;
        _versionCodename = VersionService.getVersionCodename(_currentVersion);
        _releases = releases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkForUpdate() async {
    if (!Platform.isAndroid) {
      setState(() {
        _updateStatus =
            "Les mises à jour automatiques ne sont disponibles que sur Android.";
      });
      return;
    }

    setState(() {
      _isCheckingUpdate = true;
      _updateStatus = null;
    });

    try {
      final updateService = UpdateService();
      final newVersion = await updateService.checkForUpdate();

      if (newVersion != null) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => UpdateDialog(appVersion: newVersion),
          );
        }
      } else {
        setState(() {
          _updateStatus = 'up_to_date';
        });
      }
    } catch (e) {
      setState(() {
        _updateStatus = 'error';
      });
    } finally {
      setState(() {
        _isCheckingUpdate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          loc.versionTitle,
          style: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentVersionCard(),
                  const SizedBox(height: 20),
                  _buildCheckUpdateButton(),
                  if (_updateStatus != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_updateStatus == 'up_to_date')
                            const Icon(Icons.check_circle_outline,
                                color: Colors.green, size: 18),
                          if (_updateStatus == 'up_to_date')
                            const SizedBox(width: 6),
                          Text(
                            _updateStatus == 'up_to_date'
                                ? loc.versionUpToDate
                                : _updateStatus == 'android_only'
                                    ? loc.versionAutoUpdateAndroid
                                    : loc.versionCheckError,
                            style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 15,
                              color: _updateStatus == 'up_to_date'
                                  ? Colors.green.shade600
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  Text(
                    loc.versionHistory,
                    style: const TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_releases.isEmpty)
                    Center(
                      child: Text(
                        loc.versionHistoryError,
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  else
                    ..._releases.map((release) => _buildReleaseCard(release)),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentVersionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "C",
                style: GoogleFonts.cormorant(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Text(
                "hords",
                style: GoogleFonts.cormorant(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "v$_currentVersion",
              style: GoogleFonts.ubuntuMono(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
          ),
          if (_versionCodename.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _versionCodename.replaceFirst(' - ', ''),
              style: GoogleFonts.cormorant(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckUpdateButton() {
    final loc = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isCheckingUpdate ? null : _checkForUpdate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isCheckingUpdate)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey.shade600,
                  ),
                )
              else
                Icon(Icons.refresh_rounded,
                    color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 10),
              Text(
                _isCheckingUpdate
                    ? loc.versionChecking
                    : loc.versionCheckUpdate,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReleaseCard(Map<String, String> release) {
    final version = release['version'] ?? '';
    final changelog = release['changelog'] ?? '';
    final isCurrentVersion = version == _currentVersion;
    final codename = VersionService.getVersionCodename(version);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentVersion
            ? Colors.red.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentVersion
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrentVersion ? Colors.red : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "v$version",
                  style: TextStyle(
                    fontFamily: 'UbuntuMono',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCurrentVersion ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (codename.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  codename,
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              if (isCurrentVersion) ...[
                const Spacer(),
                const Icon(Icons.check_circle, color: Colors.red, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            changelog,
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
