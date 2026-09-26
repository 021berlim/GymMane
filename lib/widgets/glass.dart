import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const double kSheetBlur = 14.0;

/// Exibe modal bottom sheet com efeito de desfoque translúcido ("glass") no plano de fundo.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
  ShapeBorder? shape,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useSafeArea = false,
  Color? barrierColor,
  bool useRootNavigator = false,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  double blur = kSheetBlur,
}) {
  final nav = Navigator.of(context, rootNavigator: useRootNavigator);
  return nav.push(GlassSheetRoute<T>(
    builder: builder,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    shape: shape,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useSafeArea: useSafeArea,
    clipBehavior: clipBehavior,
    constraints: constraints,
    modalBarrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.32),
    capturedThemes: InheritedTheme.capture(from: context, to: nav.context),
    barrierLabel: MaterialLocalizations.of(context).scrimLabel,
    blur: blur,
  ));
}

/// Rota de Bottom Sheet com desfoque de barreira dinâmico.
class GlassSheetRoute<T> extends ModalBottomSheetRoute<T> {
  GlassSheetRoute({
    required super.builder,
    required super.isScrollControlled,
    super.backgroundColor,
    super.shape,
    super.isDismissible,
    super.enableDrag,
    super.useSafeArea,
    super.clipBehavior,
    super.constraints,
    super.modalBarrierColor,
    super.capturedThemes,
    super.barrierLabel,
    this.blur = kSheetBlur,
  });

  final double blur;

  @override
  Widget buildModalBarrier() =>
      BlurBarrier(animation: animation!, blur: blur, child: super.buildModalBarrier());
}

/// Exibe diálogo modal central com animação combinada de Fade + Scale (0.92 -> 1)
/// com curvas easeOutBack e easeInCubic, além de desfoque progressivo na barreira.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  double blur = kSheetBlur,
}) {
  final nav = Navigator.of(context, rootNavigator: useRootNavigator);
  return nav.push(GlassDialogRoute<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.36),
    themes: InheritedTheme.capture(from: context, to: nav.context),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    settings: routeSettings,
    blur: blur,
  ));
}

/// Rota de Dialog com Fade, Scale e desfoque dinâmico de barreira.
class GlassDialogRoute<T> extends DialogRoute<T> {
  GlassDialogRoute({
    required super.context,
    required super.builder,
    super.barrierDismissible = true,
    super.barrierColor,
    super.themes,
    super.barrierLabel,
    super.settings,
    this.blur = kSheetBlur,
  });

  final double blur;

  @override
  Widget buildModalBarrier() =>
      BlurBarrier(animation: animation!, blur: blur, child: super.buildModalBarrier());

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}

/// Barreira modal com BackdropFilter e desfoque progressivo baseado na animação da rota.
class BlurBarrier extends StatelessWidget {
  const BlurBarrier({
    super.key,
    required this.animation,
    required this.child,
    this.blur = kSheetBlur,
  });

  final Animation<double> animation;
  final Widget child;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, barrier) {
        final sigma = blur * Curves.easeOut.transform(animation.value.clamp(0.0, 1.0));
        if (sigma < 0.3) return barrier!;
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: barrier,
        );
      },
    );
  }
}
