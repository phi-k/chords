import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: (width * MediaQuery.of(context).devicePixelRatio).round(),
        memCacheHeight: (height * MediaQuery.of(context).devicePixelRatio).round(),

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