import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

const _kDisplay = 'Oswald';
const _kBody = 'IBM Plex Sans';

Color _heat(int level, GymColors gc) {
  switch (level) {
    case 3:
      return gc.accent;
    case 2:
      return gc.brass;
    case 1:
      return gc.mutedFill;
    default:
      return gc.heatEmpty;
  }
}

class HeatmapWidgetView extends StatelessWidget {
  const HeatmapWidgetView({
    super.key,
    required this.gc,
    required this.levels,
    required this.streak,
    this.size = const Size(320, 150),
  });

  final GymColors gc;
  final List<int> levels;
  final int streak;
  final Size size;

  @override
  Widget build(BuildContext context) {
    const rows = 7;
    const vgap = 3.0;
    const pad = 14.0;

    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('FIT//IRON',
                  style: TextStyle(
                      fontFamily: _kDisplay,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: gc.text)),
              const Spacer(),
              Icon(Icons.local_fire_department_rounded, size: 15, color: gc.accent),
              const SizedBox(width: 3),
              Text('$streak',
                  style: TextStyle(
                      fontFamily: _kDisplay,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: gc.accent)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gridW = constraints.maxWidth;
                final gridH = constraints.maxHeight;
                final cell = ((gridH - (rows - 1) * vgap) / rows).clamp(4.0, 40.0);
                final cols = math.max(1, ((gridW + vgap) / (cell + vgap)).floor());

                final need = cols * rows;
                final start = math.max(0, levels.length - need);
                final window = levels.sublist(start);
                int levelAt(int c, int r) {
                  final idx = c * rows + r - (need - window.length);
                  return (idx >= 0 && idx < window.length) ? window[idx] : 0;
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int c = 0; c < cols; c++)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int r = 0; r < rows; r++)
                            Container(
                              width: cell,
                              height: cell,
                              decoration: BoxDecoration(
                                color: _heat(levelAt(c, r), gc),
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatsWidgetView extends StatelessWidget {
  const StatsWidgetView({
    super.key,
    required this.gc,
    required this.streak,
    required this.sessionsThisWeek,
    required this.goalPct,
    this.size = const Size(155, 155),
  });

  final GymColors gc;
  final int streak;
  final int sessionsThisWeek;
  final int goalPct;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded, size: 15, color: gc.accent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(t.streakCaps,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: _kDisplay,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: gc.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$streak',
                    style: TextStyle(
                        fontFamily: _kDisplay,
                        fontSize: 42,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: gc.text)),
                const SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(t.daysUnit(streak),
                      style: TextStyle(fontFamily: _kBody, fontSize: 13, color: gc.textSecondary)),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _chip(gc, '$sessionsThisWeek', t.thisWeek),
              const SizedBox(width: 8),
              _chip(gc, '$goalPct%', t.goal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(GymColors gc, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: gc.bgRaised2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: _kDisplay, fontSize: 15, fontWeight: FontWeight.w700, color: gc.text)),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(label,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                      fontFamily: _kBody, fontSize: 9.0, letterSpacing: 0.3, color: gc.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
