import 'package:flutter/material.dart';

/// Transição suave para legendas ou rótulos reativos (220ms Fade),
/// adaptada da linguagem de AnimatedSwitcher do GymMane.
class SubtleTextSwitcher extends StatelessWidget {
  const SubtleTextSwitcher({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 220),
    this.textAlign = TextAlign.center,
  });

  final String text;
  final TextStyle style;
  final Duration duration;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: Text(
        text,
        key: ValueKey(text),
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}

final _digitCells = <(TextStyle, double), double>{};

double digitCell(TextStyle style, TextScaler scaler) {
  if (_digitCells.length > 48) _digitCells.clear();
  return _digitCells.putIfAbsent((style, scaler.scale(100)), () {
    var widest = 0.0;
    for (var d = 0; d < 10; d++) {
      final p = TextPainter(
        text: TextSpan(text: '$d', style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      if (p.width > widest) widest = p.width;
      p.dispose();
    }
    return widest.ceilToDouble();
  });
}

/// Widget com efeito de roleta (odômetro individual de dígitos) para contadores,
/// cronômetros e pesos, com AnimatedSize (240ms) e rolagem de 420ms por dígito.
class RollingText extends StatefulWidget {
  const RollingText(
    this.text, {
    super.key,
    required this.style,
    this.duration = const Duration(milliseconds: 420),
    this.countsDown,
    this.textAlign = TextAlign.left,
  });

  final String text;
  final TextStyle style;
  final Duration duration;
  final bool? countsDown;
  final TextAlign textAlign;

  @override
  State<RollingText> createState() => _RollingTextState();
}

class _RollingTextState extends State<RollingText> {
  static const _burst = Duration(milliseconds: 180);

  bool _up = true;
  bool _rapid = false;
  DateTime? _changedAt;

  static double? _numeric(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9.]'), '');
    return digits.isEmpty ? null : double.tryParse(digits);
  }

  @override
  void didUpdateWidget(RollingText old) {
    super.didUpdateWidget(old);
    if (old.text == widget.text) return;
    final now = DateTime.now();
    _rapid = _changedAt != null && now.difference(_changedAt!) < _burst;
    _changedAt = now;

    final forced = widget.countsDown;
    if (forced != null) {
      _up = !forced;
      return;
    }
    final a = _numeric(old.text), b = _numeric(widget.text);
    if (a != null && b != null && a != b) _up = b > a;
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.text.characters.toList();
    final n = chars.length;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final line = (widget.style.fontSize ?? 14) * (widget.style.height ?? 1.2);
    final digit = digitCell(widget.style, MediaQuery.textScalerOf(context));
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < n; i++)
          _RollingChar(
            key: ValueKey(n - i),
            char: chars[i],
            style: widget.style,
            up: _up,
            duration: reduce || _rapid ? Duration.zero : widget.duration,
            solo: _rapid,
            line: line,
            width: _isDigit(chars[i]) ? digit : null,
          ),
      ],
    );
    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: AnimatedSize(
        duration: reduce || _rapid ? Duration.zero : const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        alignment: switch (widget.textAlign) {
          TextAlign.right || TextAlign.end => Alignment.centerRight,
          TextAlign.center => Alignment.center,
          _ => Alignment.centerLeft,
        },
        child: row,
      ),
    );
  }

  static bool _isDigit(String c) => c.length == 1 && c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}

class _RollingChar extends StatelessWidget {
  const _RollingChar({
    super.key,
    required this.char,
    required this.style,
    required this.up,
    required this.duration,
    required this.line,
    this.solo = false,
    this.width,
  });

  final String char;
  final TextStyle style;
  final bool up;
  final Duration duration;
  final double line;
  final bool solo;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final w = width;
    final content = AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        if (duration == Duration.zero) return child;
        final incoming = (child.key as ValueKey?)?.value == char;
        final from = incoming ? (up ? line : -line) : 0.0;
        final to = incoming ? 0.0 : (up ? -line : line);
        final curved = CurvedAnimation(
          parent: animation,
          curve: incoming ? Curves.easeOutCubic : Curves.easeInCubic,
        );
        return ClipRect(
          child: AnimatedBuilder(
            animation: curved,
            child: child,
            builder: (_, inner) {
              final dy = from + (to - from) * curved.value;
              return Transform.translate(
                offset: Offset(0, dy),
                child: Opacity(
                  opacity: solo ? 1 : curved.value.clamp(0.0, 1.0),
                  child: inner,
                ),
              );
            },
          ),
        );
      },
      layoutBuilder: (current, prev) => Stack(
        alignment: Alignment.center,
        children: [...prev, ?current],
      ),
      child: Text(
        char,
        key: ValueKey(char),
        style: style,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
        ),
      ),
    );

    if (w == null) return content;
    return SizedBox(width: w, height: line, child: Center(child: content));
  }
}

/// Contador ascendente suave (1150ms) usando Curves.easeOutCubic.
class RollInCounter extends StatefulWidget {
  const RollInCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 1150),
    this.formatter,
  });

  final double value;
  final TextStyle style;
  final Duration duration;
  final String Function(double)? formatter;

  @override
  State<RollInCounter> createState() => _RollInCounterState();
}

class _RollInCounterState extends State<RollInCounter> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _anim = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

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
      animation: _anim,
      builder: (context, _) {
        final current = widget.value * _anim.value;
        final label = widget.formatter != null ? widget.formatter!(current) : current.round().toString();
        return Text(label, style: widget.style);
      },
    );
  }
}
