import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  final String id;
  final String nameKey;
  final String descKey;
  final String coverUrl;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final bool isBuiltIn;

  const AppTheme({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.coverUrl,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    this.isBuiltIn = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameKey': nameKey,
      'descKey': descKey,
      'coverUrl': coverUrl,
      'primaryColor': primaryColor.toARGB32(),
      'backgroundColor': backgroundColor.toARGB32(),
      'textColor': textColor.toARGB32(),
      'isBuiltIn': isBuiltIn,
    };
  }

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      id: json['id'],
      nameKey: json['nameKey'],
      descKey: json['descKey'],
      coverUrl: json['coverUrl'],
      primaryColor: Color(json['primaryColor']),
      backgroundColor: Color(json['backgroundColor']),
      textColor: Color(json['textColor']),
      isBuiltIn: json['isBuiltIn'] ?? false,
    );
  }

  ThemeData getThemeData() {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    final baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final isMonochrome = HSLColor.fromColor(primaryColor).saturation <= 0.05;

    var scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      surface: backgroundColor,
      onSurface: textColor,
      brightness: brightness,
    ).copyWith(
      surfaceTint: Colors.transparent,
    );

    if (isMonochrome) {
      scheme = scheme.copyWith(
        primaryContainer: primaryColor.withValues(alpha: 0.2),
        onPrimaryContainer: primaryColor,
      );
    }

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: scheme,

      dialogTheme: DialogThemeData(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: backgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: backgroundColor,
        surfaceTintColor: Colors.transparent,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness,
          systemNavigationBarColor: backgroundColor,
          systemNavigationBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      ),
      textTheme: baseTextTheme.apply(
        fontFamily: 'Cormorant',
        bodyColor: textColor,
        displayColor: textColor,
      ),
    );
  }
}
