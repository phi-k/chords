import 'package:flutter/material.dart';
import '../../data/collections/song.dart';
import '../../utils/string_normalization.dart';
import 'app_image.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final Widget? subtitleTrailing;
  final bool showArtist;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onLongPress,
    this.trailing,
    this.subtitleTrailing,
    this.showArtist = true,
  });

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontFamily: 'Cormorant', fontSize: 20, color: Colors.red);
    const artistStyle = TextStyle(fontFamily: 'Cormorant', fontSize: 16, color: Colors.black);

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppImage(url: song.coverUrl),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title ?? "",
                    style: getDynamicTextStyle(song.title ?? "", titleStyle),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (showArtist)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            song.artist ?? "",
                            style: getDynamicTextStyle(song.artist ?? "", artistStyle),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (subtitleTrailing != null) ...[
                          const SizedBox(width: 8),
                          subtitleTrailing!,
                        ],
                      ],
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}