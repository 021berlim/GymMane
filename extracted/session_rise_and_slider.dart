// Origem: lib/widgets/entrance.dart (~L58-115) e lib/screens/session_screen.dart (~L1139-1525)
// Animação 6: Animação escalonada Rise para cartões de conclusão + ExerciseSlideTransition com Slide, Scale e Fade
// Parâmetros originais específicos desacoplados:
// - Desacoplado de `Store.instance` e `fit.inSuperset`. Criados componentes puros `Rise`, `RiseAll`
//   e `ExerciseSlideTransition`.

import 'package:flutter/material.dart';

/// Transição escalonada para cartões (delay incremental de 70ms por índice,
/// duração de movimento de 560ms, subida de 22px, escala 0.97 -> 1.0 e fade com Curves.easeOutCubic).
class Rise extends StatefulWidget {
  const Rise({
    super.key,
    required this.index,
    required this.child,
    this.delayStepMs = 70,
    this.baseDelayMs = 40,
    this.motionMs = 560,
  });

  final int index;
  final Widget child;
  final int delayStepMs;
  final int baseDelayMs;
  final int motionMs;

  @override
  State<Rise> createState() => _RiseState();
}

class _RiseState extends State<Rise> with SingleTickerProviderStateMixin {
  late final int _delay = widget.baseDelayMs + widget.index.clamp(0, 8) * widget.delayStepMs;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _delay + widget.motionMs),
  );
  late final Animation<double> _v = CurvedAnimation(
    parent: _c,
    curve: Interval(_delay / (_delay + widget.motionMs), 1.0, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _v,
      child: widget.child,
      builder: (context, child) {
        final v = _v.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - v)),
            child: Transform.scale(
              scale: 0.97 + 0.03 * v,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Helper para embrulhar uma lista de widgets em animações escalonadas Rise.
List<Widget> riseAll(List<Widget> children) {
  var i = 0;
  return [
    for (final c in children)
      c is SizedBox && c.child == null ? c : Rise(index: i++, child: c),
  ];
}

/// Transição animada para troca de exercício na sessão ativa:
/// Combina AnimatedSwitcher de 520ms com curvas assimétricas,
/// Slide horizontal direcional (Offset(0.5 * dir, 0)), Scale (0.94 -> 1.0) e Fade.
class ExerciseSlideTransition extends StatefulWidget {
  const ExerciseSlideTransition({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<ExerciseSlideTransition> createState() => _ExerciseSlideTransitionState();
}

class _ExerciseSlideTransitionState extends State<ExerciseSlideTransition> {
  int _dir = 1;

  @override
  void didUpdateWidget(ExerciseSlideTransition old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index) return;
    _dir = widget.index > old.index ? 1 : -1;
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.index;
    final dir = _dir;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 520),
      switchInCurve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      switchOutCurve: const Interval(0.55, 1.0, curve: Curves.easeInCubic),
      transitionBuilder: (child, animation) {
        final incoming = (child.key as ValueKey?)?.value == current;
        final from = Offset(incoming ? 0.5 * dir : -0.5 * dir, 0);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: from, end: Offset.zero).animate(animation),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(animation),
              child: child,
            ),
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
