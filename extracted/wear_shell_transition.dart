// Origem: lib/wear/wear_shell.dart (~L175, ~L1245)
// Animação 7: Transições otimizadas para Wear OS (AnimatedSwitcher 220ms e WearSessionSlider 420ms)
// Parâmetros originais específicos desacoplados:
// - Desacoplado de rotas e chamadas de HapticFeedback do Wear OS.

import 'package:flutter/material.dart';

/// Transição rápida entre telas do Wear OS (220ms, Fade puro para baixo custo de GPU em relógio).
class WearShellScreenSwitcher extends StatelessWidget {
  const WearShellScreenSwitcher({
    super.key,
    required this.routeKey,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
  });

  final String routeKey;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: KeyedSubtree(key: ValueKey(routeKey), child: child),
    );
  }
}

/// Transição horizontal entre passos ou exercícios no Wear OS:
/// Duração de 420ms, curvas assimétricas (Interval(0.3, 1, easeOutCubic) / Interval(0.55, 1, easeInCubic)),
/// combinando Fade com Slide de Offset(0.4 * dir, 0).
class WearSessionSliderTransition extends StatefulWidget {
  const WearSessionSliderTransition({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<WearSessionSliderTransition> createState() => _WearSessionSliderTransitionState();
}

class _WearSessionSliderTransitionState extends State<WearSessionSliderTransition> {
  int _dir = 1;

  @override
  void didUpdateWidget(WearSessionSliderTransition old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index) return;
    _dir = widget.index > old.index ? 1 : -1;
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.index;
    final dir = _dir;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      switchOutCurve: const Interval(0.55, 1.0, curve: Curves.easeInCubic),
      transitionBuilder: (child, animation) {
        final incoming = (child.key as ValueKey?)?.value == current;
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(incoming ? 0.4 * dir : -0.4 * dir, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topCenter,
        children: [
          ...previousChildren,
          ?currentChild,
        ],
      ),
      child: KeyedSubtree(key: ValueKey(current), child: widget.child),
    );
  }
}
