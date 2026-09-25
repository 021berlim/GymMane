import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'muscle_icon.dart';
import 'svg_icon.dart';
import 'ui_kit.dart';

class EquipmentGroup {
  final String title;
  final List<EquipmentItemData> items;
  const EquipmentGroup(this.title, this.items);
}

class EquipmentItemData {
  final String label;
  final String filterKey;
  final IconData icon;
  const EquipmentItemData(this.label, this.filterKey, this.icon);
}

const List<EquipmentGroup> kEquipmentGroups = [
  EquipmentGroup('BARRAS E PESOS', [
    EquipmentItemData('Anilha', 'Weighted', PhosphorIconsRegular.disc),
    EquipmentItemData('Barra Hexagonal', 'trap bar', PhosphorIconsRegular.barbell),
    EquipmentItemData('Barra W', 'EZ', PhosphorIconsRegular.barbell),
    EquipmentItemData('Barra fixa', 'pull-up', PhosphorIconsRegular.rows),
    EquipmentItemData('Barra olímpica', 'Barbell', PhosphorIconsRegular.barbell),
  ]),
  EquipmentGroup('BANCOS E SUPORTES', [
    EquipmentItemData('Banco Inclinado', 'Incline', PhosphorIconsRegular.armchair),
    EquipmentItemData('Banco Reto', 'Bench', PhosphorIconsRegular.armchair),
    EquipmentItemData('Banco Romano', 'Roman', PhosphorIconsRegular.armchair),
    EquipmentItemData('Banco Scott', 'Preacher', PhosphorIconsRegular.armchair),
    EquipmentItemData('Gaiola de Agachamento', 'Rack', PhosphorIconsRegular.frameCorners),
    EquipmentItemData('Máquina de Agachamento em V', 'Squat', PhosphorIconsRegular.cpu),
  ]),
  EquipmentGroup('OUTROS', [
    EquipmentItemData('Barra Fixa e Paralelas', 'Parallel', PhosphorIconsRegular.rows),
    EquipmentItemData('Bicicleta Ergométrica', 'Bike', PhosphorIconsRegular.bicycle),
    EquipmentItemData('Bola Pilates', 'Ball', PhosphorIconsRegular.circle),
    EquipmentItemData('Bosu', 'Bosu', PhosphorIconsRegular.circleHalf),
    EquipmentItemData('Caixa', 'Box', PhosphorIconsRegular.package),
    EquipmentItemData('Halteres', 'Dumbbell', PhosphorIconsRegular.barbell),
    EquipmentItemData('Cabo / Polia', 'Cable', PhosphorIconsRegular.lightning),
    EquipmentItemData('Máquina', 'Machine', PhosphorIconsRegular.cpu),
    EquipmentItemData('Elástico / Fita', 'Band', PhosphorIconsRegular.infinity),
    EquipmentItemData('Kettlebell', 'Kettlebell', PhosphorIconsRegular.polygon),
  ]),
];

bool matchesEquipmentFilter(Exercise ex, String filterKey) {
  final eqTarget = filterKey.toLowerCase();
  final exEq = ex.equipment.toLowerCase();
  final exName = ex.name.toLowerCase();
  final locName = exerciseName(ex).toLowerCase();

  if (eqTarget == 'trap bar' && (exEq == 'trap bar' || locName.contains('hexagonal') || exName.contains('trap bar'))) return true;
  if (eqTarget == 'pull-up' && (exName.contains('pull-up') || exName.contains('chin-up') || locName.contains('barra fixa'))) return true;
  if (eqTarget == 'parallel' && (exName.contains('dip') || locName.contains('paralela'))) return true;
  if (eqTarget == 'barbell' && (exEq == 'barbell' || exName.contains('barbell') || locName.contains('barra'))) return true;
  if (eqTarget == 'dumbbell' && (exEq == 'dumbbell' || exName.contains('dumbbell') || locName.contains('halter'))) return true;
  if (eqTarget == 'cable' && (exEq == 'cable' || exName.contains('cable') || locName.contains('cabo') || locName.contains('polia'))) return true;
  if (eqTarget == 'machine' && (exEq == 'machine' || exName.contains('machine') || locName.contains('máquina'))) return true;
  if (eqTarget == 'bodyweight' && (exEq == 'bodyweight' || exName.contains('push-up') || exName.contains('pull-up') || locName.contains('corporal'))) return true;
  if (eqTarget == 'weighted' && (exEq == 'weighted' || exName.contains('plate') || locName.contains('anilha') || locName.contains('peso'))) return true;
  if (eqTarget == 'band' && (exEq == 'band' || exName.contains('band') || locName.contains('elástico'))) return true;
  if (eqTarget == 'kettlebell' && (exEq == 'kettlebell' || exName.contains('kettlebell'))) return true;
  if (eqTarget == 'incline' && (exName.contains('incline') || locName.contains('inclinad'))) return true;
  if (eqTarget == 'bench' && (exName.contains('bench') || locName.contains('banco'))) return true;
  if (eqTarget == 'squat' && (exName.contains('squat') || locName.contains('agachament'))) return true;
  return exEq.contains(eqTarget) || exName.contains(eqTarget) || locName.contains(eqTarget);
}

class CategoryTabSelector extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  const CategoryTabSelector({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final tabs = ['POR MÚSCULO', 'EQUIPAMENTOS', 'FAVORITOS'];
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: gc.border),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTabSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedTab == i ? gc.bgRaised2 : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    border: selectedTab == i
                        ? Border.all(color: gc.border.withValues(alpha: 0.6))
                        : null,
                  ),
                  child: Text(
                    tabs[i],
                    style: AppTheme.d(
                      11,
                      weight: selectedTab == i ? FontWeight.w700 : FontWeight.w500,
                      color: selectedTab == i ? gc.text : gc.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MuscleCategoryCard extends StatelessWidget {
  final String muscleId;
  final int count;
  final VoidCallback onTap;

  const MuscleCategoryCard({
    super.key,
    required this.muscleId,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: gc.bgRaised,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gc.border),
        ),
        child: Row(
          children: [
            MuscleIcon(muscleId: muscleId, size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    muscleLabel(muscleId),
                    style: AppTheme.s(16, weight: FontWeight.w700, color: gc.text),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count exercícios',
                    style: AppTheme.s(13, color: gc.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight, size: 18, color: gc.textTertiary),
          ],
        ),
      ),
    );
  }
}

class EquipmentCategoryCard extends StatelessWidget {
  final EquipmentItemData item;
  final int count;
  final VoidCallback onTap;

  const EquipmentCategoryCard({
    super.key,
    required this.item,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: gc.bgRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gc.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: gc.bgRaised2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 22, color: gc.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count exercícios',
                    style: AppTheme.s(12, color: gc.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight, size: 18, color: gc.textTertiary),
          ],
        ),
      ),
    );
  }
}

class EquipmentGroupSectionWidget extends StatelessWidget {
  final EquipmentGroup group;
  final Widget Function(EquipmentItemData item) itemBuilder;

  const EquipmentGroupSectionWidget({
    super.key,
    required this.group,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(
            group.title,
            style: AppTheme.d(12, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.2),
          ),
        ),
        for (final item in group.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: itemBuilder(item),
          ),
      ],
    );
  }
}

class CategoryDetailHeaderWidget extends StatelessWidget {
  final String categoryName;
  final int count;
  final VoidCallback onBack;
  final String? difficultyFilter;
  final String? secondaryFilterLabel;
  final VoidCallback onDifficultyTap;
  final VoidCallback onSecondaryFilterTap;

  const CategoryDetailHeaderWidget({
    super.key,
    required this.categoryName,
    required this.count,
    required this.onBack,
    required this.difficultyFilter,
    required this.secondaryFilterLabel,
    required this.onDifficultyTap,
    required this.onSecondaryFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: RoundBtn(
                icon: Ic.chevronLeft,
                onTap: onBack,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                categoryName.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.d(18, weight: FontWeight.w800, color: gc.text, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          '$count exercícios',
          style: AppTheme.s(13, color: gc.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilterDropdownPillWidget(
                label: difficultyFilter == null
                    ? t.difficulty('all')
                    : t.difficulty(difficultyFilter!),
                onTap: onDifficultyTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilterDropdownPillWidget(
                label: secondaryFilterLabel ?? t.equipment('all'),
                onTap: onSecondaryFilterTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class FilterDropdownPillWidget extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const FilterDropdownPillWidget({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: gc.bgRaised,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: gc.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTheme.s(12, weight: FontWeight.w600, color: gc.text),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(PhosphorIconsRegular.caretDown, size: 14, color: gc.textSecondary),
          ],
        ),
      ),
    );
  }
}

void showFilterSelectorBottomSheet<T>({
  required BuildContext context,
  required String title,
  required T? currentValue,
  required List<MapEntry<T?, String>> options,
  required ValueChanged<T?> onSelected,
}) {
  final gc = context.gc;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title.toUpperCase(),
              style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final opt in options) ...[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          onSelected(opt.key);
                          Navigator.pop(sheetCtx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: currentValue == opt.key ? gc.accentSoft : gc.bgRaised2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: currentValue == opt.key ? gc.accent : gc.border,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  opt.value,
                                  style: AppTheme.s(14,
                                      weight: currentValue == opt.key ? FontWeight.w700 : FontWeight.w500,
                                      color: currentValue == opt.key ? gc.accent : gc.text),
                                ),
                              ),
                              if (currentValue == opt.key) ...[
                                const SizedBox(width: 8),
                                Icon(PhosphorIconsRegular.check, size: 18, color: gc.accent),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
