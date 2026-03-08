import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/collections/song.dart';
import '../widgets/common/app_image.dart';
import '../l10n/app_localizations.dart';

class SongStatisticsPage extends StatefulWidget {
  final Song songData;

  const SongStatisticsPage({super.key, required this.songData});

  @override
  State<SongStatisticsPage> createState() => _SongStatisticsPageState();
}

class _SongStatisticsPageState extends State<SongStatisticsPage> {
  bool _showGraph = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.statsTitle,
          style: GoogleFonts.cormorant(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCoverImage(),
            _buildHeaderInfo(),
            const SizedBox(height: 30),
            _buildStatisticsInfo(),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 20),
            _buildHistoryHeader(),
            const SizedBox(height: 16),
            _showGraph ? _buildPlayHistoryGraph() : _buildPlayHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AppImage(
          url: widget.songData.coverUrl,
          width: 200,
          height: 200,
          borderRadius: 10,
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          widget.songData.title ?? loc.statsUnknownTitle,
          style: GoogleFonts.cormorant(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          widget.songData.artist ?? loc.commonUnknownArtist,
          style: GoogleFonts.cormorant(fontSize: 22, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatisticsInfo() {
    final loc = AppLocalizations.of(context)!;
    final playCount = widget.songData.playCount;
    final lastPlayed = _formatDate(widget.songData.lastPlayed);
    final savedDate =
        _formatDate(widget.songData.savedDate ?? widget.songData.addedDate);
    final tags = widget.songData.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatItem(loc.statsSavedDate, savedDate),
        _buildStatItem(loc.statsPlayCount, "$playCount"),
        _buildStatItem(loc.statsLastPlayed, lastPlayed),
        const SizedBox(height: 10),
        Text(
          loc.statsTags,
          style: GoogleFonts.cormorant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        tags.isEmpty
            ? Text(loc.statsNoTags, style: GoogleFonts.cormorant(fontSize: 16))
            : Wrap(
                spacing: 8,
                runSpacing: 5,
                children: tags
                    .map<Widget>(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildHistoryHeader() {
    final loc = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          loc.statsHistory,
          style: GoogleFonts.cormorant(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(
            _showGraph ? Icons.list : Icons.bar_chart,
            color: Colors.black,
            size: 24,
          ),
          tooltip: _showGraph ? loc.statsShowList : loc.statsShowGraph,
          onPressed: () {
            setState(() {
              _showGraph = !_showGraph;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPlayHistoryList() {
    final loc = AppLocalizations.of(context)!;
    final history = widget.songData.playHistory;

    if (history.isEmpty) {
      return Text(
        loc.statsNoHistory,
        style: GoogleFonts.cormorant(fontSize: 16),
      );
    }

    Map<String, int> groupedHistory = {};
    for (var date in history) {
      String formattedDate = date;
      try {
        final DateTime dateTime = DateTime.parse(date);
        formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      } catch (e) {
        log("Date invalide dans l'historique: $date", error: e);
      }
      groupedHistory[formattedDate] = (groupedHistory[formattedDate] ?? 0) + 1;
    }

    List<MapEntry<String, int>> sortedEntries = groupedHistory.entries.toList();
    sortedEntries.sort((a, b) {
      List<String> partsA = a.key.split('/');
      List<String> partsB = b.key.split('/');

      if (partsA.length == 3 && partsB.length == 3) {
        int yearA = int.tryParse(partsA[2]) ?? 0;
        int yearB = int.tryParse(partsB[2]) ?? 0;
        if (yearA != yearB) return yearB.compareTo(yearA);

        int monthA = int.tryParse(partsA[1]) ?? 0;
        int monthB = int.tryParse(partsB[1]) ?? 0;
        if (monthA != monthB) return monthB.compareTo(monthA);

        int dayA = int.tryParse(partsA[0]) ?? 0;
        int dayB = int.tryParse(partsB[0]) ?? 0;
        return dayB.compareTo(dayA);
      }

      return b.key.compareTo(a.key);
    });

    return Column(
      children: sortedEntries.map((entry) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: GoogleFonts.cormorant(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${entry.value} ${entry.value > 1 ? 'fois' : 'fois'}",
                  style: GoogleFonts.cormorant(fontSize: 18),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayHistoryGraph() {
    final history = widget.songData.playHistory;

    if (history.isEmpty) {
      return Center(
        child: Text(
          "Pas assez de données pour afficher un graphique",
          style: GoogleFonts.cormorant(fontSize: 18),
        ),
      );
    }

    Map<DateTime, int> dailyData = {};
    List<DateTime> allDates = [];

    for (var dateStr in history) {
      try {
        final DateTime date = DateTime.parse(dateStr);
        allDates.add(date);
        dailyData[date] = (dailyData[date] ?? 0) + 1;
      } catch (e) {
        log("Date invalide dans l'historique: $dateStr", error: e);
      }
    }

    if (dailyData.isEmpty) {
      return Center(
        child: Text(
          "Données de dates invalides",
          style: GoogleFonts.cormorant(fontSize: 18),
        ),
      );
    }

    allDates.sort();

    final distinctDates = dailyData.keys.toList()..sort();

    if (distinctDates.length == 1) {
      final singleDate = distinctDates.first;
      final dayBefore = singleDate.subtract(const Duration(days: 1));
      final dayAfter = singleDate.add(const Duration(days: 1));

      dailyData[dayBefore] = 0;
      dailyData[dayAfter] = 0;

      distinctDates.clear();
      distinctDates.addAll([dayBefore, singleDate, dayAfter]);
      distinctDates.sort();
    }

    final spots = distinctDates.asMap().entries.map((entry) {
      final date = entry.value;
      final count = dailyData[date] ?? 0;
      return FlSpot(entry.key.toDouble(), count.toDouble());
    }).toList();

    final xLabels = distinctDates.map((date) {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 16, left: 6, top: 20, bottom: 10),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= xLabels.length) {
                    return const Text('');
                  }

                  String label = xLabels[index];
                  if (index > 0) {
                    final currentDate = distinctDates[index];
                    final previousDate = distinctDates[index - 1];

                    if (currentDate.month != previousDate.month ||
                        currentDate.year != previousDate.year) {
                      label += "\n${currentDate.year}";
                    }
                  } else if (index == 0) {
                    label += "\n${distinctDates[0].year}";
                  }

                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      label,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                interval: spots.length > 10
                    ? (spots.length / 10).ceil().toDouble()
                    : 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      value.toInt().toString(),
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                  );
                },
                interval: 1,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
          ),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: 0,
          maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF0000),
                  Color(0xFFFF4500),
                  Color(0xFFFF8C00),
                  Color(0xFFFFD700),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: const Color(0xFFFF4500),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF4500).withValues(alpha: 0.3),
                    const Color(0xFFFFD700).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cormorant(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value, style: GoogleFonts.cormorant(fontSize: 18)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return "Non disponible";
    try {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }
}
