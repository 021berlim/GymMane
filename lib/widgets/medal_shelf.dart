import 'package:flutter/material.dart';

import '../catalog/awards.dart';
import '../l10n/l10n.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass.dart';
import 'medal.dart';

class MedalShelf extends StatelessWidget {
  const MedalShelf({super.key, this.size = 66});

  final double size;

  @override
  Widget build(BuildContext context) {
    final order = [
      ...AwardId.values.where(fit.hasAward),
      ...AwardId.values.where((a) => !fit.hasAward(a)),
    ];
    return SizedBox(
      height: size + 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: order.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _slot(context, order[i]),
      ),
    );
  }

  Widget _slot(BuildContext context, AwardId id) {
    final gc = context.gc;
    final won = fit.hasAward(id);
    final fresh = fit.unseenAwards.contains(id);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showMedalSheet(context, id),
      child: Semantics(
        button: true,
        label: awardName(id),
        child: SizedBox(
          width: size + 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: Stack(
                  children: [
                    Medal(id: id, size: size, locked: !won),
                    if (fresh)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: gc.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: gc.bg, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (won) ...[
                const SizedBox(height: 7),
                Text(
                  awardName(id),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.s(10, weight: FontWeight.w600, color: gc.textSecondary, height: 1.15),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showMedalSheet(BuildContext context, AwardId id) {
  fit.markAwardsSeen();
  return showAppSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _MedalSheet(id: id),
  );
}

class _MedalSheet extends StatelessWidget {
  const _MedalSheet({required this.id});

  final AwardId id;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final won = fit.hasAward(id);
    final at = fit.awardWonAt(id);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          MedalSpin(id: id, size: 236, locked: !won),
          const SizedBox(height: 8),
          Text(t.awardSpinHint,
              style: AppTheme.s(11.5, weight: FontWeight.w500, color: gc.textTertiary)),
          const SizedBox(height: 22),
          Text(awardName(id), textAlign: TextAlign.center, style: AppTheme.d(22, weight: FontWeight.w700, color: gc.text)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              awardLine(id),
              textAlign: TextAlign.center,
              style: AppTheme.s(13, weight: FontWeight.w400, color: gc.textSecondary, height: 1.45),
            ),
          ),
          const SizedBox(height: 18),
          if (won && at != null)
            Text(t.awardWonOn(t.shortDateYear(at)),
                style: AppTheme.s(12.5, weight: FontWeight.w600, color: gc.textTertiary))
          else
            _progress(gc),
        ],
      ),
    );
  }

  Widget _progress(GymColors gc) {
    final value = fit.awardValue(id);
    final goal = fit.awardGoal(id);
    return Column(
      children: [
        SizedBox(
          width: 190,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: fit.awardProgress(id),
              minHeight: 6,
              backgroundColor: gc.bgRaised2,
              valueColor: AlwaysStoppedAnimation<Color>(gc.accent),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('${medalShort(value)} / ${medalShort(goal)}',
            style: AppTheme.s(12.5, weight: FontWeight.w600, color: gc.textTertiary)),
      ],
    );
  }
}

String medalShort(int v) =>
    v >= 1000 ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k' : '$v';
