// Origem: lib/screens/moments_screen.dart (~L55 + Hero em L185/228/283)
// Animação 3: Visualizador de foto em tela cheia com expansão Hero + desfoque de fundo (BackdropFilter)
// Parâmetros originais específicos desacoplados:
// - `Moment`, `MediaStore.pathFor`, `gc.pageBg` e strings `t.fullDate` desacoplados.
// - Implementado como helper reutilizável que aceita qualquer Widget de imagem/foto ou caminho,
//   tag de Hero e widgets adicionais de overlay (ações, data, etc.).

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Abre um visualizador de foto em tela cheia com transição Hero suave
/// e desfoque progressivo no fundo (BackdropFilter sigma 0 -> 20).
Future<void> openPhotoHeroViewer({
  required BuildContext context,
  required Object heroTag,
  required Widget image,
  Widget? header,
  Widget? footer,
  Color backgroundColor = Colors.black,
  double backgroundOpacity = 0.62,
}) {
  return Navigator.of(context).push(PageRouteBuilder<void>(
    opaque: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, animation, _) => PhotoHeroViewer(
      heroTag: heroTag,
      image: image,
      header: header,
      footer: footer,
      backgroundColor: backgroundColor,
      backgroundOpacity: backgroundOpacity,
      animation: animation,
    ),
  ));
}

/// Widget interno de exibição de foto com transição Hero e efeito glass blur.
class PhotoHeroViewer extends StatelessWidget {
  const PhotoHeroViewer({
    super.key,
    required this.heroTag,
    required this.image,
    required this.animation,
    this.header,
    this.footer,
    this.backgroundColor = Colors.black,
    this.backgroundOpacity = 0.62,
  });

  final Object heroTag;
  final Widget image;
  final Animation<double> animation;
  final Widget? header;
  final Widget? footer;
  final Color backgroundColor;
  final double backgroundOpacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final v = Curves.easeOutCubic.transform(animation.value);
        return Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 20 * v, sigmaY: 20 * v),
                    child: ColoredBox(
                      color: backgroundColor.withValues(alpha: backgroundOpacity * v),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 86, 24, 54),
                    child: Hero(
                      tag: heroTag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: image,
                      ),
                    ),
                  ),
                ),
                if (header != null)
                  Positioned(
                    top: 40,
                    left: 16,
                    right: 16,
                    child: Opacity(
                      opacity: v,
                      child: header!,
                    ),
                  ),
                if (footer != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 54,
                    child: Opacity(
                      opacity: v,
                      child: footer!,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
