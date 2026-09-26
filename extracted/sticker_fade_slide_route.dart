// Origem: lib/screens/sticker_screen.dart (~L23-31)
// Animação 4: Transição de tela cheia/editor com FadeTransition + SlideTransition sutil
// Parâmetros originais específicos desacoplados:
// - `StickerEditor` e `LoggedSession` desacoplados. Converteu-se em rota genérica `FadeSlidePageRoute`
//   e helper `pushFadeSlideRoute` para qualquer tela ou sheet.

import 'package:flutter/material.dart';

/// Helper de rota com entrada suave: desce ligeiramente de Offset(0, 0.04) com Fade e curva easeOutCubic.
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

/// Função utilitária para navegar usando a transição Fade+Slide.
Future<T?> pushFadeSlideRoute<T>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).push(FadeSlidePageRoute<T>(builder: builder));
}
