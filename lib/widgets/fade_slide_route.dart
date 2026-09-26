import 'package:flutter/material.dart';

/// Transição suave de página/modal com entrada combinada de Fade e Slide sutil
/// (Offset(0, 0.04) -> 0 com 340ms/240ms e curva easeOutCubic), adaptada de sticker_screen do GymMane.
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  FadeSlidePageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.transitionDuration = const Duration(milliseconds: 340),
    super.reverseTransitionDuration = const Duration(milliseconds: 240),
    Offset slideBegin = const Offset(0, 0.04),
    Curve curve = Curves.easeOutCubic,
    super.opaque = true,
    super.barrierDismissible = false,
    super.barrierColor,
    super.barrierLabel,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: curve);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Helper utilitário para navegação com a transição Fade+Slide.
Future<T?> pushFadeSlideRoute<T>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).push(FadeSlidePageRoute<T>(builder: builder));
}
