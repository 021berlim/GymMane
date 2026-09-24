import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';

/// Widget de alta performance para exibição de GIFs animados de exercícios.
///
/// Proteção Anti-OOM no Android:
/// - Decodificação restrita na GPU via ResizeImage (cacheWidth/cacheHeight).
/// - Descarte imediato no dispose via evict().
class ExerciseGifPlayer extends StatefulWidget {
  const ExerciseGifPlayer({
    super.key,
    required this.gifPath,
    this.height = 180,
    this.width,
    this.radius = 16,
    this.fit = BoxFit.contain,
    this.isThumbnail = false,
  });

  final String gifPath;
  final double height;
  final double? width;
  final double radius;
  final BoxFit fit;
  final bool isThumbnail;

  @override
  State<ExerciseGifPlayer> createState() => _ExerciseGifPlayerState();
}

class _ExerciseGifPlayerState extends State<ExerciseGifPlayer> {
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _setupImageProvider();
  }

  @override
  void didUpdateWidget(ExerciseGifPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gifPath != widget.gifPath || oldWidget.isThumbnail != widget.isThumbnail) {
      _setupImageProvider();
    }
  }

  void _setupImageProvider() {
    if (widget.gifPath.isEmpty) {
      _imageProvider = null;
      return;
    }

    final ImageProvider rawProvider;
    if (widget.gifPath.startsWith('assets/')) {
      rawProvider = AssetImage(widget.gifPath);
    } else if (File(widget.gifPath).existsSync()) {
      rawProvider = FileImage(File(widget.gifPath));
    } else {
      rawProvider = AssetImage('assets/exercises/${widget.gifPath.split('/').last}');
    }

    final int targetWidth = widget.isThumbnail ? 160 : 360;
    final int targetHeight = widget.isThumbnail ? 160 : 360;

    _imageProvider = ResizeImage(
      rawProvider,
      width: targetWidth,
      height: targetHeight,
      allowUpscaling: false,
    );
  }

  @override
  void dispose() {
    _imageProvider?.evict();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final effectiveWidth = widget.width ?? widget.height;

    return Container(
      width: effectiveWidth,
      height: widget.height,
      decoration: BoxDecoration(
        color: gc.bgRaised2,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: gc.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: _imageProvider == null
          ? _fallbackIcon(gc)
          : Image(
              image: _imageProvider!,
              fit: widget.fit,
              alignment: Alignment.center,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) {
                  return child;
                }
                return Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: gc.accent.withValues(alpha: 0.6),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => _fallbackIcon(gc),
            ),
    );
  }

  Widget _fallbackIcon(GymColors gc) {
    return Center(
      child: Icon(
        PhosphorIconsRegular.barbell,
        size: widget.height * 0.35,
        color: gc.textTertiary,
      ),
    );
  }
}
