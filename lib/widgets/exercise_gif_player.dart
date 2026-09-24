import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';

/// Widget de alta performance para renderização de GIFs animados de exercícios.
///
/// Proteção Avançada Anti-OOM (Out-of-Memory) no Android:
/// 1. Decodificação restrita na GPU via ResizeImage (cacheWidth/cacheHeight limitados).
/// 2. Descarte imediato no dispose via evict() do ImageProvider anterior.
/// 3. Resolução segura de caminhos locais (assets/exercises/, novas_imagens/, File system).
/// 4. Skeleton/Placeholder suave enquanto o frame é decodificado.
class ExerciseGifView extends StatefulWidget {
  const ExerciseGifView({
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
  State<ExerciseGifView> createState() => _ExerciseGifViewState();
}

class _ExerciseGifViewState extends State<ExerciseGifView> {
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _setupImageProvider();
  }

  @override
  void didUpdateWidget(ExerciseGifView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gifPath != widget.gifPath || oldWidget.isThumbnail != widget.isThumbnail) {
      oldWidget.gifPath.isNotEmpty ? _imageProvider?.evict() : null;
      _setupImageProvider();
    }
  }

  void _setupImageProvider() {
    final cleanPath = widget.gifPath.trim();
    if (cleanPath.isEmpty) {
      _imageProvider = null;
      return;
    }

    final ImageProvider rawProvider;
    if (cleanPath.startsWith('assets/')) {
      rawProvider = AssetImage(cleanPath);
    } else {
      final localFile = File(cleanPath);
      if (localFile.existsSync()) {
        rawProvider = FileImage(localFile);
      } else {
        final filename = cleanPath.split('/').last.split('\\').last;
        final assetTarget = 'assets/exercises/$filename';
        rawProvider = AssetImage(assetTarget);
      }
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
    _imageProvider = null;
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
                return _skeletonPlaceholder(gc);
              },
              errorBuilder: (context, error, stackTrace) => _fallbackIcon(gc),
            ),
    );
  }

  Widget _skeletonPlaceholder(GymColors gc) {
    return Container(
      color: gc.bgRaised,
      alignment: Alignment.center,
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: gc.accent.withValues(alpha: 0.5),
        ),
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

/// Alias para manter compatibilidade reversa com chamadas legadas
typedef ExerciseGifPlayer = ExerciseGifView;
