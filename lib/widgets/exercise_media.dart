import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';

import '../models/exercise.dart';
import '../services/media_store.dart';
import '../theme/app_colors.dart';
import 'exercise_gif_player.dart';

class ExerciseMedia extends StatelessWidget {
  const ExerciseMedia({
    super.key,
    required this.ex,
    this.height,
    this.width,
    this.aspectRatio,
    this.radius = 20,
    this.live = false,
    this.fit,
  });

  final Exercise ex;
  final double? height;
  final double? width;
  final double? aspectRatio;
  final double radius;
  final bool live;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? (aspectRatio != null ? null : 210.0);
    final effectiveFit = fit ?? (aspectRatio != null ? BoxFit.cover : BoxFit.contain);

    final path = ex.media.isEmpty ? null : MediaStore.pathFor(ex.media);
    if (path == null) {
      final gif = ex.gifPath.isNotEmpty ? ex.gifPath : 'assets/exercises/${ex.id}.gif';
      return ExerciseGifView(
        gifPath: gif,
        height: effectiveHeight,
        width: width,
        aspectRatio: aspectRatio,
        radius: radius,
        fit: effectiveFit,
        isThumbnail: !live && (effectiveHeight != null && effectiveHeight <= 80),
      );
    }
    final isVideo = MediaStore.isVideo(ex.media);
    if (isVideo && live) {
      return _VideoTile(
        key: ValueKey(path),
        path: path,
        height: effectiveHeight,
        width: width,
        aspectRatio: aspectRatio,
        radius: radius,
      );
    }
    return _MediaFrame(
      height: effectiveHeight,
      width: width,
      aspectRatio: aspectRatio,
      radius: radius,
      child: isVideo
          ? _VideoPoster(height: effectiveHeight ?? 180)
          : Center(
              child: Image.file(
                File(path),
                key: ValueKey(ex.media),
                fit: effectiveFit,
                alignment: Alignment.center,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => _fallbackIcon(context, effectiveHeight ?? 180),
              ),
            ),
    );
  }
}

Widget _fallbackIcon(BuildContext context, double height) => Center(
      child: Icon(PhosphorIconsRegular.barbell,
          size: height * 0.32, color: context.gc.textTertiary),
    );

class _MediaFrame extends StatelessWidget {
  const _MediaFrame({
    required this.child,
    this.height,
    this.width,
    this.aspectRatio,
    required this.radius,
  });
  final Widget child;
  final double? height;
  final double? width;
  final double? aspectRatio;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    Widget frame = Container(
      width: width ?? (aspectRatio != null ? double.infinity : null),
      height: aspectRatio != null ? null : height,
      decoration: BoxDecoration(
        color: gc.bgRaised2,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: gc.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
    if (aspectRatio != null) {
      frame = AspectRatio(
        aspectRatio: aspectRatio!,
        child: frame,
      );
    }
    return frame;
  }
}

class _VideoPoster extends StatelessWidget {
  const _VideoPoster({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return Center(
      child: Icon(PhosphorIconsFill.playCircle,
          size: (height * 0.34).clamp(18.0, 54.0), color: gc.textSecondary),
    );
  }
}

class _VideoTile extends StatefulWidget {
  const _VideoTile({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.aspectRatio,
    required this.radius,
  });
  final String path;
  final double? height;
  final double? width;
  final double? aspectRatio;
  final double radius;

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
  VideoPlayerController? _c;
  bool _ok = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = VideoPlayerController.file(File(widget.path));
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      await c.play();
      if (!mounted) {
        c.dispose();
        return;
      }
      setState(() {
        _c = c;
        _ok = true;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    final effectiveHeight = widget.height ?? 180;
    if (_ok && _c != null) {
      child = FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _c!.value.size.width,
          height: _c!.value.size.height,
          child: VideoPlayer(_c!),
        ),
      );
    } else if (_failed) {
      child = _fallbackIcon(context, effectiveHeight);
    } else {
      child = const Center(
        child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final effectiveRatio = (_ok && _c != null && _c!.value.aspectRatio > 0)
        ? _c!.value.aspectRatio
        : widget.aspectRatio;
    return _MediaFrame(
      height: widget.height,
      width: widget.width,
      aspectRatio: effectiveRatio,
      radius: widget.radius,
      child: child,
    );
  }
}
