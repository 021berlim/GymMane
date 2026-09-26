import 'package:flutter/material.dart';

/// Abre visualizador de fotos/mídia em tela cheia com transição Fade translúcida
/// (360ms abertura / 300ms fechamento, Curves.easeOut) e suporte a pinch-to-zoom (InteractiveViewer).
Future<void> showMediaViewer({
  required BuildContext context,
  required int itemCount,
  required IndexedWidgetBuilder itemBuilder,
  int initialIndex = 0,
  Color barrierColor = const Color(0xF2000000),
  String? barrierLabel = 'Fechar',
}) {
  return Navigator.of(context).push(PageRouteBuilder<void>(
    opaque: false,
    barrierDismissible: true,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, _) => MediaViewer(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      initialIndex: initialIndex,
    ),
    transitionsBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  ));
}

/// Visualizador interativo de mídia em carrossel horizontal com zoom e contador de páginas.
class MediaViewer extends StatefulWidget {
  const MediaViewer({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.initialIndex = 0,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int initialIndex;

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  late final PageController _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: widget.itemCount,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              return InteractiveViewer(
                maxScale: 5,
                child: Center(
                  child: widget.itemBuilder(context, i),
                ),
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          if (widget.itemCount > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
