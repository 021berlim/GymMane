import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/l10n.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/svg_icon.dart';
import '../widgets/ui_kit.dart';
import 'progress_screen.dart';

enum WeeklyDetailGrain { week, month, year }

class WeeklyProgressDetailScreen extends StatefulWidget {
  const WeeklyProgressDetailScreen({super.key});

  @override
  State<WeeklyProgressDetailScreen> createState() => _WeeklyProgressDetailScreenState();
}

class _WeeklyProgressDetailScreenState extends State<WeeklyProgressDetailScreen> {
  WeeklyDetailGrain _grain = WeeklyDetailGrain.week;
  int _periodOffset = 0;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);
    final currentWeekStart = todayKey.subtract(Duration(days: todayKey.weekday - 1));
    final weekStart = currentWeekStart.add(Duration(days: _periodOffset * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final dateRangeStr = '${t.shortDate(weekStart)} - ${t.shortDate(weekEnd)}';

    final earliestDate = fit.earliestActivityDate;
    final earliestDayKey = DateTime(earliestDate.year, earliestDate.month, earliestDate.day);
    final earliestWeekStart = earliestDayKey.subtract(Duration(days: earliestDayKey.weekday - 1));

    final maxPastWeeks = math.max(0, (currentWeekStart.difference(earliestWeekStart).inDays / 7.0).ceil());
    final minWeekOffset = -maxPastWeeks;

    final canGoBack = _periodOffset > minWeekOffset;
    final canGoForward = _periodOffset < 0;

    final sessionCount = fit.weeklySessionsCount(weekStart);
    final exercisesCount = fit.weeklyExercisesCount(weekStart);
    final durationMin = fit.durationWeekMin(weekStart);
    final totalCalories = fit.weeklyCalories(weekStart).fold(0.0, (a, b) => a + b).round();
    final totalVolumeKg = fit.volumeWeekKg(weekStart);
    final prsCount = fit.weeklyPrsCount(weekStart);

    final prevWeekStart = weekStart.subtract(const Duration(days: 7));
    final hasPrevData = fit.weekHasData(prevWeekStart);

    final currentCaloriesVal = fit.weeklyCalories(weekStart).fold(0.0, (a, b) => a + b);
    final prevCaloriesVal = hasPrevData ? fit.weeklyCalories(prevWeekStart).fold(0.0, (a, b) => a + b) : null;

    final currentVolumeVal = fit.volumeWeekKg(weekStart);
    final prevVolumeVal = hasPrevData ? fit.volumeWeekKg(prevWeekStart) : null;

    return Scaffold(
      backgroundColor: gc.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, gc),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 32 + MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    _buildGrainSelector(gc),
                    const SizedBox(height: 18),
                    _buildPeriodNavigator(gc, dateRangeStr, canGoBack, canGoForward),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.55,
                      children: [
                        _metricCard(
                          gc,
                          title: '$sessionCount',
                          subtitle: sessionCount == 1 ? 'Treino' : 'Treinos',
                          icon: Icon(PhosphorIconsRegular.squaresFour, size: 22, color: gc.textTertiary),
                        ),
                        _metricCard(
                          gc,
                          title: '$exercisesCount',
                          subtitle: 'Exercícios',
                          icon: Icon(PhosphorIconsRegular.link, size: 22, color: gc.textTertiary),
                        ),
                        _metricCard(
                          gc,
                          title: '${durationMin}min',
                          subtitle: 'Tempo',
                          icon: Icon(PhosphorIconsRegular.clock, size: 22, color: gc.textTertiary),
                        ),
                        _metricCard(
                          gc,
                          title: '$totalCalories',
                          subtitle: 'Calorias (kcal)',
                          icon: Icon(PhosphorIconsFill.flame, size: 22, color: gc.textTertiary),
                        ),
                        _metricCard(
                          gc,
                          title: fit.volumeValue(totalVolumeKg),
                          subtitle: 'Volume (${fit.volumeUnit})',
                          icon: Icon(PhosphorIconsRegular.barbell, size: 22, color: gc.textTertiary),
                        ),
                        _metricCard(
                          gc,
                          title: '$prsCount',
                          subtitle: 'Recordes',
                          icon: Icon(PhosphorIconsRegular.trophy, size: 22, color: gc.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    WeeklyProgressCardWidget(
                      weekStart: weekStart,
                      showExploreDetails: false,
                    ),
                    const SizedBox(height: 22),
                    _MuscleDistributionCard(
                      gc: gc,
                      start: weekStart,
                      end: weekEnd,
                    ),
                    const SizedBox(height: 22),
                    _TrendCard(
                      gc: gc,
                      title: 'Tendência de Calorias',
                      subtitle: 'Resumo de atividades no período atual',
                      currentValue: currentCaloriesVal,
                      previousValue: prevCaloriesVal,
                      unit: 'kcal',
                      dateRangeStr: dateRangeStr,
                      accentColor: const Color(0xFFFF6B4A),
                    ),
                    const SizedBox(height: 22),
                    _TrendCard(
                      gc: gc,
                      title: 'Tendência de Volume',
                      subtitle: 'Resumo de atividades no período atual',
                      currentValue: currentVolumeVal,
                      previousValue: prevVolumeVal,
                      unit: fit.volumeUnit,
                      dateRangeStr: dateRangeStr,
                      accentColor: const Color(0xFFA855F7),
                      valueFormatter: (v) => fit.volumeValue(v),
                    ),
                    const SizedBox(height: 22),
                    _PeriodPrsCard(
                      gc: gc,
                      start: weekStart,
                      end: weekEnd,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, GymColors gc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: gc.bgRaised,
                border: Border.all(color: gc.border),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.caretLeft,
                size: 20,
                color: gc.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Progresso semanal',
            style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
          ),
        ],
      ),
    );
  }

  Widget _buildGrainSelector(GymColors gc) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: gc.bgRaised2.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          _grainTab(gc, 'SEMANA', WeeklyDetailGrain.week),
          _grainTab(gc, 'MÊS', WeeklyDetailGrain.month),
          _grainTab(gc, 'ANO', WeeklyDetailGrain.year),
        ],
      ),
    );
  }

  Widget _grainTab(GymColors gc, String label, WeeklyDetailGrain grain) {
    final selected = _grain == grain;
    final activePillColor = gc.accent.withValues(alpha: 0.18);
    final activeTextColor = gc.accent;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _grain = grain),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? activePillColor : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: AppTheme.d(
              11,
              weight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? activeTextColor : gc.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodNavigator(GymColors gc, String label, bool canGoBack, bool canGoForward) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: canGoBack ? () => setState(() => _periodOffset--) : null,
          icon: SvgPathIcon(
            Ic.chevronLeft,
            size: 16,
            color: canGoBack ? gc.text : gc.textTertiary.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: canGoForward ? () => setState(() => _periodOffset++) : null,
          icon: SvgPathIcon(
            Ic.chevronRight,
            size: 16,
            color: canGoForward ? gc.text : gc.textTertiary.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _metricCard(GymColors gc, {required String title, required String subtitle, required Widget icon}) {
    return SoftCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: icon,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTheme.d(24, weight: FontWeight.w700, color: gc.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTheme.s(12, color: gc.textSecondary, weight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.gc,
    required this.title,
    required this.subtitle,
    required this.currentValue,
    required this.previousValue,
    required this.unit,
    required this.dateRangeStr,
    required this.accentColor,
    this.valueFormatter,
  });

  final GymColors gc;
  final String title;
  final String subtitle;
  final double currentValue;
  final double? previousValue;
  final String unit;
  final String dateRangeStr;
  final Color accentColor;
  final String Function(double)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final format = valueFormatter ?? (double v) => v.round().toString();

    final maxRef = math.max(currentValue, previousValue ?? 0);
    final displayMax = maxRef > 0 ? (maxRef * 1.25) : 100.0;

    final yLabels = [
      format(displayMax),
      format(displayMax * 0.66),
      format(displayMax * 0.33),
      '0',
    ];

    String footerComparisonText;
    if (previousValue == null || previousValue! <= 0) {
      footerComparisonText = 'Nenhum período anterior disponível para comparação';
    } else {
      final diff = ((currentValue - previousValue!) / previousValue!) * 100;
      if (diff > 0) {
        footerComparisonText = '+${diff.round()}% em relação ao período anterior';
      } else if (diff < 0) {
        footerComparisonText = '${diff.round()}% em relação ao período anterior';
      } else {
        footerComparisonText = 'Mesmo desempenho do período anterior';
      }
    }

    final barsData = <({String label, double value, bool isCurrent})>[];
    if (previousValue != null && previousValue! > 0) {
      barsData.add((
        label: 'Anterior',
        value: previousValue!,
        isCurrent: false,
      ));
    }
    barsData.add((
      label: dateRangeStr,
      value: currentValue,
      isCurrent: true,
    ));

    return SoftCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.s(12, color: gc.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (int i = 0; i < yLabels.length; i++)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: gc.border.withValues(alpha: 0.3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 44,
                              child: Text(
                                yLabels[i],
                                textAlign: TextAlign.end,
                                style: AppTheme.s(11, color: gc.textTertiary),
                              ),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            unit,
                            style: AppTheme.s(11, color: gc.textTertiary, weight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 58, bottom: 10),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (int i = 0; i < barsData.length; i++) ...[
                            if (i > 0) const SizedBox(width: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 64,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    color: gc.bgRaised2.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 64,
                                      height: displayMax > 0
                                          ? (110 * (barsData[i].value / displayMax)).clamp(6.0, 110.0)
                                          : 0,
                                      decoration: BoxDecoration(
                                        color: barsData[i].isCurrent
                                            ? accentColor
                                            : accentColor.withValues(alpha: 0.45),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 72,
                                  child: Text(
                                    barsData[i].label,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.s(
                                      10,
                                      color: barsData[i].isCurrent ? gc.textSecondary : gc.textTertiary,
                                      weight: barsData[i].isCurrent ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            footerComparisonText,
            style: AppTheme.s(13, color: gc.textSecondary, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _MuscleDistributionCard extends StatelessWidget {
  const _MuscleDistributionCard({
    required this.gc,
    required this.start,
    required this.end,
  });

  final GymColors gc;
  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final prevStart = start.subtract(end.difference(start));
    final prevEnd = start;

    final data = fit.muscleDistributionForPeriod(
      start: start,
      end: end,
      prevStart: prevStart,
      prevEnd: prevEnd,
    );

    final currentSets = data.currentSets;
    final totalSets = currentSets.values.fold(0.0, (a, b) => a + b);

    final entries = <({String name, double sets, double pct})>[];
    if (totalSets > 0) {
      currentSets.forEach((key, sets) {
        if (sets > 0) {
          String name;
          switch (key) {
            case 'legs': name = 'Pernas'; break;
            case 'arms': name = 'Braços'; break;
            case 'chest': name = 'Peito'; break;
            case 'shoulders': name = 'Ombros'; break;
            case 'back': name = 'Costas'; break;
            case 'core': default: name = 'Core'; break;
          }
          entries.add((
            name: name,
            sets: sets,
            pct: (sets / totalSets) * 100,
          ));
        }
      });
      entries.sort((a, b) => b.sets.compareTo(a.sets));
    }

    return SoftCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Distribuição Muscular no Período',
            style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
          ),
          const SizedBox(height: 4),
          Text(
            'Divisão de carga por grupos musculares trabalhados',
            style: AppTheme.s(12, color: gc.textSecondary),
          ),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Nenhum treino registrado neste período.',
                style: AppTheme.s(13, color: gc.textSecondary),
              ),
            )
          else
            Column(
              children: [
                for (final e in entries) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.name,
                        style: AppTheme.s(13, weight: FontWeight.w600, color: gc.text),
                      ),
                      Text(
                        '${e.sets.toStringAsFixed(1)} séries (${e.pct.round()}%)',
                        style: AppTheme.s(12, color: gc.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: e.pct / 100.0,
                      minHeight: 8,
                      backgroundColor: gc.bgRaised2,
                      valueColor: AlwaysStoppedAnimation<Color>(gc.accent),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _PeriodPrsCard extends StatelessWidget {
  const _PeriodPrsCard({
    required this.gc,
    required this.start,
    required this.end,
  });

  final GymColors gc;
  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final prs = fit.prsInPeriod(start, end);

    return SoftCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recordes & Cargas em Destaque',
                style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
              ),
              Icon(PhosphorIconsRegular.trophy, size: 20, color: gc.accent),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Maiores cargas e marcas atingidas no período',
            style: AppTheme.s(12, color: gc.textSecondary),
          ),
          const SizedBox(height: 16),
          if (prs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Nenhum recorde registrado neste período.',
                style: AppTheme.s(13, color: gc.textSecondary),
              ),
            )
          else
            for (int i = 0; i < prs.length; i++) ...[
              if (i > 0) Divider(color: gc.border, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prs[i].name,
                          style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.shortDate(prs[i].date),
                          style: AppTheme.s(11, color: gc.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fit.weightLabel(prs[i].topWeight),
                        style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
                      ),
                      Text(
                        '1RM: ${fit.weightLabel(prs[i].oneRm)}',
                        style: AppTheme.s(11, color: gc.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}
