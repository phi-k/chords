// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

class AppImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const AppImage({
    super.key,
    required this.url,
    this.width = 50,
    this.height = 50,
    this.borderRadius = 5,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildStaticPlaceholder();
    }

    if (url!.startsWith('emoji://')) {
      final content = url!.substring(8);
      final parts = content.split('|');
      final emoji = parts[0];
      Color? bgColor;
      if (parts.length > 1) {
        final colorVal = int.tryParse(parts[1], radix: 16);
        if (colorVal != null) {
          bgColor = Color(colorVal);
        }
      }
      bgColor ??= Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);

      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          height: height,
          color: bgColor,
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: width * 0.5),
            ),
          ),
        ),
      );
    }

    if (url!.startsWith('icon://')) {
      final content = url!.substring(7);
      final parts = content.split('|');
      final codePointStr = parts[0];
      final codePoint = int.tryParse(codePointStr);
      final iconData = codePoint != null
          ? IconData(codePoint, fontFamily: 'MaterialIcons')
          : Icons.folder;

      Color? bgColor;
      Color? iconColor;
      if (parts.length > 1) {
        final colorVal = int.tryParse(parts[1], radix: 16);
        if (colorVal != null) {
          bgColor = Color(colorVal);
          iconColor = bgColor.computeLuminance() > 0.6
              ? Colors.black87
              : Colors.white;
        }
      }
      bgColor ??= Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
      iconColor ??= Theme.of(context).colorScheme.primary;

      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          height: height,
          color: bgColor,
          child: Center(
            child: Icon(
              iconData,
              color: iconColor,
              size: width * 0.55,
            ),
          ),
        ),
      );
    }

    if (url!.startsWith('local://')) {
      final localPath = url!.replaceFirst('local://', '');
      final file = File(localPath);

      if (!file.existsSync()) {
        return _buildStaticPlaceholder();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              _buildStaticPlaceholder(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth:
            (width * MediaQuery.of(context).devicePixelRatio).round(),
        memCacheHeight:
            (height * MediaQuery.of(context).devicePixelRatio).round(),
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) => _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) => _buildStaticPlaceholder(),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  Widget _buildStaticPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.music_note,
        color: Colors.grey.shade500,
        size: width * 0.5,
      ),
    );
  }
}
