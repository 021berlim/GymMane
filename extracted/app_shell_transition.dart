// Origem: lib/app/app_shell.dart (~L284-330 e ~L654-705)
// Animação 1: Transição principal do AppShell + Indicador LiquidPill da NavBar
// Parâmetros originais específicos do GymMane desacoplados:
// - `fit.route`, `fit.routeDepth`, `_NavBarState._routes` desacoplados para parâmetros puros
//   (currentRoute, previousRoute, routeDepth, previousDepth, mainRoutes).

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

/// Transição principal entre abas e telas do App Shell com suporte a detecção de direção
/// (forward / back) e eixo (lateral entre abas vs vertical para navegação em profundidade),
/// combinando deslocamento suave, desfoque progressivo (blur decal), escala e fade.
class ShellRouteSwitcher extends StatelessWidget {
  const ShellRouteSwitcher({
    super.key,
    required this.currentRoute,
    required this.previousRoute,
    required this.currentDepth,
    required this.previousDepth,
    required this.mainTabRoutes,
    required this.child,
  });

  final String currentRoute;
  final String? previousRoute;
  final int currentDepth;
  final int previousDepth;
  final List<String> mainTabRoutes;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final from = previousRoute != null ? mainTabRoutes.indexOf(previousRoute!) : -1;
    final to = mainTabRoutes.indexOf(currentRoute);
    final sideways = from >= 0 && to >= 0;
    final forward = sideways ? to > from : currentDepth >= previousDepth;
    final dir = forward ? 1.0 : -1.0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: const Interval(0.3, 1, curve: Curves.easeOutCubic),
      switchOutCurve: const Interval(0.7, 1, curve: Curves.easeInCubic),
      transitionBuilder: (child, animation) {
        final incoming = (child.key as ValueKey?)?.value == currentRoute;
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (_, inner) {
            final v = animation.value.clamp(0.0, 1.0);
            final away = 1 - v;
            final shift = sideways
                ? Offset((incoming ? 26 : -18) * dir * away, 0)
                : Offset(0, incoming ? 22 * dir * away : -8 * dir * away);
            final blur = 10 * away;
            return Opacity(
              opacity: v,
              child: ImageFiltered(
                enabled: blur > 0.25,
                imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur, tileMode: TileMode.decal),
                child: Transform.translate(
                  offset: shift,
                  child: Transform.scale(
                    scale: incoming ? 1 + 0.03 * away : 1 - 0.04 * away,
                    child: inner,
                  ),
                ),
              ),
            );
          },
        );
      },
      layoutBuilder: (currentChild, previousChildren) => Stack(
        children: <Widget>[
          for (final c in previousChildren) Positioned.fill(key: c.key, child: c),
          if (currentChild != null) Positioned.fill(key: currentChild.key, child: currentChild),
        ],
      ),
      child: KeyedSubtree(key: ValueKey(currentRoute), child: child),
    );
  }
}

/// Indicador em formato de pílula líquida com física de esticamento (squash)
/// e elevação iluminada durante a movimentação entre abas da barra de navegação.
class LiquidPillIndicator extends StatefulWidget {
  const LiquidPillIndicator({
    super.key,
    required this.left,
    required this.width,
    required this.color,
    this.dragLeft,
    this.borderRadius = 18.0,
  });

  final double left;
  final double width;
  final Color color;
  final double? dragLeft;
  final double borderRadius;

  @override
  State<LiquidPillIndicator> createState() => _LiquidPillIndicatorState();
}

class _LiquidPillIndicatorState extends State<LiquidPillIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _move = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
    value: 1,
  );
  late final AnimationController _lift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 380),
  );
  late double _from = widget.left;
  late double _shown = widget.left;

  static const _liftCurve = Cubic(0.3, 1.25, 0.5, 1);
  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void didUpdateWidget(LiquidPillIndicator old) {
    super.didUpdateWidget(old);
    final dragging = widget.dragLeft != null;
    if (dragging != (old.dragLeft != null)) {
      dragging ? _lift.forward() : _lift.reverse();
    }
    if (dragging) return;
    if (old.left == widget.left && old.dragLeft == null) return;
    _from = _shown;
    _move.forward(from: 0);
  }

  @override
  void dispose() {
    _move.dispose();
    _lift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_move, _lift]),
      builder: (context, _) {
        final lift = _liftCurve.transform(_lift.value.clamp(0.0, 1.0));
        final double l, r;
        var squash = 1.0;
        final drag = widget.dragLeft;
        if (drag != null) {
          l = drag;
          r = drag + widget.width;
        } else {
          final t = _move.value;
          final to = widget.left;
          final right = to >= _from;
          final lead = Curves.easeOutCubic.transform(t);
          final trail = Curves.easeInOutCubic.transform(t);
          l = _lerp(_from, to, right ? trail : lead);
          r = _lerp(_from + widget.width, to + widget.width, right ? lead : trail);
          squash = 1 - 0.14 * (1 - (2 * t - 1).abs()) * (to == _from ? 0 : 1);
        }
        _shown = l;
        final currentAlpha = widget.color.a;
        final boostedAlpha = (currentAlpha * 2.4).clamp(0.0, 1.0);
        final base = Color.lerp(
          widget.color,
          widget.color.withValues(alpha: boostedAlpha),
          lift,
        )!;
        final grow = 6 * lift;
        final inset = 10 + 12 * (1 - squash) - 6 * lift;

        return Positioned(
          left: l,
          width: (r - l).clamp(8.0, 400.0),
          top: inset / 2,
          bottom: inset / 2,
          child: Container(
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(widget.borderRadius + grow),
              boxShadow: lift > 0.05
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.28 * lift),
                        blurRadius: 18 * lift,
                        spreadRadius: 2 * lift,
                        offset: Offset(0, 4 * lift),
                      )
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }
}
