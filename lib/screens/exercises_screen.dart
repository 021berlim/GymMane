import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../catalog/exercise_catalog.dart';
import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../services/media_store.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/exercise_media.dart';
import '../widgets/svg_icon.dart';
import '../widgets/ui_kit.dart';

import '../widgets/exercise_category_widgets.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});
  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late final TextEditingController _c = TextEditingController(text: fit.exSearch);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  bool get _isCategorySelected =>
      fit.exMuscleFilter != null || fit.exEquipmentFilter != null;

  bool get _isSearching => fit.exSearch.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final list = fit.exercisesFiltered;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _isCategorySelected
                  ? _categoryDetailHeader(gc, list.length)
                  : _isSearching
                      ? _searchHeader(gc, list.length)
                      : _header(gc),
            ),
          ),
          if (_isCategorySelected || _isSearching) ...[
            if (list.isEmpty)
              SliverToBoxAdapter(child: _empty(gc))
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 110 + MediaQuery.of(context).padding.bottom),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _card(gc, list[i]),
                    ),
                    childCount: list.length,
                  ),
                ),
              ),
          ] else if (fit.exTab == 0) ...[
            // POR MÚSCULO TAB
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 110 + MediaQuery.of(context).padding.bottom),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _muscleCard(gc, kFilterMuscles[i]),
                  ),
                  childCount: kFilterMuscles.length,
                ),
              ),
            ),
          ] else if (fit.exTab == 1) ...[
            // EQUIPAMENTOS TAB
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 110 + MediaQuery.of(context).padding.bottom),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _equipmentGroupSection(gc, kEquipmentGroups[i]),
                  childCount: kEquipmentGroups.length,
                ),
              ),
            ),
          ] else ...[
            // FAVORITOS TAB
            if (fit.exercisesFiltered.where((e) => fit.favorites[e.id] == true).isEmpty)
              SliverToBoxAdapter(child: _emptyFavorites(gc))
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 110 + MediaQuery.of(context).padding.bottom),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final favs = fit.exercisesFiltered.where((e) => fit.favorites[e.id] == true).toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _card(gc, favs[i]),
                      );
                    },
                    childCount: fit.exercisesFiltered.where((e) => fit.favorites[e.id] == true).length,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _header(GymColors gc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsRegular.barbell, size: 22, color: gc.text),
            const SizedBox(width: 10),
            Text(t.exercises, style: AppTheme.d(22, weight: FontWeight.w700, color: gc.text)),
          ],
        ),
        const SizedBox(height: 14),
        // Search exercises input
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: gc.bgRaised,
            border: Border.all(color: gc.border),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(children: [
            SvgPathIcon(Ic.search, size: 16, color: gc.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _c,
                onChanged: (val) {
                  fit.setExSearch(val);
                  setState(() {});
                },
                style: AppTheme.s(14, color: gc.text),
                cursorColor: gc.accent,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: t.searchExercises,
                  hintStyle: AppTheme.s(14, color: gc.textSecondary),
                ),
              ),
            ),
            if (_c.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _c.clear();
                  fit.setExSearch('');
                  setState(() {});
                },
                child: Icon(PhosphorIconsRegular.xCircle, size: 18, color: gc.textSecondary),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: fit.goRoutines,
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: gc.emberSoft,
                    border: Border.all(color: gc.ember),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsRegular.barbell, size: 16, color: gc.ember),
                      const SizedBox(width: 6),
                      Text(t.goToWorkouts,
                          style: AppTheme.d(12, weight: FontWeight.w600, color: gc.ember, letterSpacing: 0.8)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => showCreateExerciseSheet(context),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: gc.bgRaised2,
                    border: Border.all(color: gc.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsRegular.plus, size: 15, color: gc.text),
                      const SizedBox(width: 6),
                      Text(t.newExercise,
                          style: AppTheme.d(12, weight: FontWeight.w600, color: gc.text, letterSpacing: 0.8)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Subdivisão por Abas (POR MÚSCULO | EQUIPAMENTOS | FAVORITOS)
        _tabSelector(gc),
      ],
    );
  }

  Widget _tabSelector(GymColors gc) {
    return CategoryTabSelector(
      selectedTab: fit.exTab,
      onTabSelected: (i) {
        fit.setExTab(i);
        if (i == 2) {
          fit.exFavouritesOnly = true;
        } else {
          fit.exFavouritesOnly = false;
        }
        setState(() {});
      },
    );
  }

  Widget _categoryDetailHeader(GymColors gc, int count) {
    String categoryName = '';
    if (fit.exMuscleFilter != null) {
      categoryName = muscleLabel(fit.exMuscleFilter!).toUpperCase();
    } else if (fit.exEquipmentFilter != null) {
      categoryName = fit.exEquipmentFilter!.toUpperCase();
    }

    final secondaryLabel = fit.exEquipmentFilter == null
        ? t.equipment('all')
        : (kFilterEquipment.contains(fit.exEquipmentFilter)
            ? t.equipment(fit.exEquipmentFilter!)
            : fit.exEquipmentFilter!);

    return CategoryDetailHeaderWidget(
      categoryName: categoryName,
      count: count,
      onBack: () {
        fit.setMuscleFilter(null);
        fit.setEquipmentFilter(null);
        fit.setDifficultyFilter(null);
        setState(() {});
      },
      difficultyFilter: fit.exDifficultyFilter,
      secondaryFilterLabel: secondaryLabel,
      onDifficultyTap: () {
        showFilterSelectorBottomSheet<String>(
          context: context,
          title: t.levelFilter,
          currentValue: fit.exDifficultyFilter,
          options: [
            MapEntry(null, t.difficulty('all')),
            for (final d in kDifficulties) MapEntry(d, t.difficulty(d)),
          ],
          onSelected: (val) {
            fit.exDifficultyFilter = val;
            setState(() {});
          },
        );
      },
      onSecondaryFilterTap: () {
        showFilterSelectorBottomSheet<String>(
          context: context,
          title: t.equipmentLabel,
          currentValue: fit.exEquipmentFilter,
          options: [
            MapEntry(null, t.equipment('all')),
            for (final eq in kFilterEquipment) MapEntry(eq, t.equipment(eq)),
          ],
          onSelected: (val) {
            fit.setEquipmentFilter(val);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _searchHeader(GymColors gc, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsRegular.barbell, size: 22, color: gc.text),
            const SizedBox(width: 10),
            Text(t.exercises, style: AppTheme.d(22, weight: FontWeight.w700, color: gc.text)),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: gc.bgRaised,
            border: Border.all(color: gc.border),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(children: [
            SvgPathIcon(Ic.search, size: 16, color: gc.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _c,
                onChanged: (val) {
                  fit.setExSearch(val);
                  setState(() {});
                },
                style: AppTheme.s(14, color: gc.text),
                cursorColor: gc.accent,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: t.searchExercises,
                  hintStyle: AppTheme.s(14, color: gc.textSecondary),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _c.clear();
                fit.setExSearch('');
                setState(() {});
              },
              child: Icon(PhosphorIconsRegular.xCircle, size: 18, color: gc.textSecondary),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Text(
          '$count exercícios encontrados',
          style: AppTheme.s(13, color: gc.textSecondary),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _muscleCard(GymColors gc, String muscleId) {
    final count = fit.allExercises
        .where((e) => e.primary == muscleId || e.secondary.contains(muscleId))
        .length;

    return MuscleCategoryCard(
      muscleId: muscleId,
      count: count,
      onTap: () {
        fit.setMuscleFilter(muscleId);
        setState(() {});
      },
    );
  }

  Widget _equipmentGroupSection(GymColors gc, EquipmentGroup group) {
    return EquipmentGroupSectionWidget(
      group: group,
      itemBuilder: (item) => _equipmentCard(gc, item),
    );
  }

  Widget _equipmentCard(GymColors gc, EquipmentItemData item) {
    final count = fit.allExercises.where((ex) => matchesEquipmentFilter(ex, item.filterKey)).length;

    return EquipmentCategoryCard(
      item: item,
      count: count,
      onTap: () {
        fit.setEquipmentFilter(item.filterKey);
        setState(() {});
      },
    );
  }

  Widget _empty(GymColors gc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          SvgPathIcon(const [IconPath('M11 11m-7 0a7 7 0 1 0 14 0a7 7 0 1 0 -14 0', strokeWidth: 1.5), IconPath('M21 21l-4.35-4.35', strokeWidth: 1.5)], size: 40, color: gc.textTertiary),
          const SizedBox(height: 10),
          Text(t.noExercisesFound, style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text)),
          const SizedBox(height: 4),
          Text(t.noExercisesHint, textAlign: TextAlign.center, style: AppTheme.s(13, color: gc.textSecondary)),
          const SizedBox(height: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _c.clear();
              fit.clearExFilters();
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(t.clearFilters, style: AppTheme.s(13, weight: FontWeight.w600, color: gc.accent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyFavorites(GymColors gc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          _star(gc, false),
          const SizedBox(height: 10),
          Text(t.noFavouritesYet, style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text)),
          const SizedBox(height: 4),
          Text(t.noFavouritesHint, textAlign: TextAlign.center, style: AppTheme.s(13, color: gc.textSecondary)),
        ],
      ),
    );
  }

  Widget _card(GymColors gc, Exercise ex) {
    final fav = fit.favorites[ex.id] ?? false;
    final diffColor = ex.difficulty == 'Beginner'
        ? gc.sage
        : ex.difficulty == 'Advanced'
            ? gc.accent
            : gc.textSecondary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => fit.openExercise(ex.id),
                child: SizedBox(width: 64, child: ExerciseMedia(ex: ex, height: 64, radius: 14)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GestureDetector(
                  onTap: () => fit.openExercise(ex.id),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Text(ex.localizedName(context), style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text)),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: gc.accentSoft, borderRadius: BorderRadius.circular(100)),
                            child: Text(ex.getLocalizedTarget(context),
                                style: AppTheme.s(11, weight: FontWeight.w600, color: gc.accent)),
                          ),
                          Text(ex.getLocalizedEquipment(context), style: AppTheme.s(12, color: gc.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: diffColor, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text(t.difficulty(ex.difficulty), style: AppTheme.s(11, color: gc.textTertiary)),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                fit.toggleFavorite(ex.id);
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: _star(gc, fav),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _star(GymColors gc, bool fav) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(children: [
        if (fav) SvgPathIcon(const [IconPath('M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 21 12 17.77 5.82 21 7 14.14l-5-4.87 6.91-1.01z', fill: true)], size: 18, color: gc.accent),
        SvgPathIcon(Ic.star, size: 18, color: fav ? gc.accent : gc.textTertiary),
      ]),
    );
  }
}

void showCreateExerciseSheet(BuildContext context, {void Function(String id)? onCreated}) {
  final gc = context.gc;
  final nameCtrl = TextEditingController();
  String muscle = kMuscles.first.id;
  String equipment = kEquipment.first;
  String difficulty = kDifficulties.first;
  bool advanced = false;
  String? mediaPath;
  bool busy = false;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => StatefulBuilder(
      builder: (sheetCtx, setSheet) {
        final mediaIsVideo = mediaPath != null && MediaStore.isVideo(mediaPath!);
        Future<void> pickMedia() async {
          try {
            final res = await FilePicker.platform.pickFiles(type: FileType.media);
            final path = res?.files.single.path;
            if (path != null) setSheet(() => mediaPath = path);
          } catch (_) {}
        }

        return Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(sheetCtx).viewInsets.bottom),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: gc.bgRaised,
            border: Border.all(color: gc.border),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
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
                  Text(t.newExercise.toUpperCase(),
                      style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 2),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    style: AppTheme.s(15, color: gc.text),
                    cursorColor: gc.accent,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: t.exerciseName,
                      hintStyle: AppTheme.s(15, color: gc.textTertiary),
                      filled: true,
                      fillColor: gc.bgRaised2,
                      contentPadding: const EdgeInsets.all(14),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: gc.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: gc.accent)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(t.muscleFilter, style: AppTheme.s(11, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final m in kMuscles)
                      Pill(
                        label: t.muscle(m.id),
                        bg: muscle == m.id ? gc.ember : gc.bgRaised2,
                        fg: muscle == m.id ? gc.onEmber : gc.textSecondary,
                        onTap: () => setSheet(() => muscle = m.id),
                        vPad: 7,
                        fontSize: 12,
                      ),
                  ]),
                  const SizedBox(height: 16),
                  Text(t.equipmentLabel, style: AppTheme.s(11, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final e in kEquipment)
                      Pill(
                        label: t.equipment(e),
                        bg: equipment == e ? gc.ember : gc.bgRaised2,
                        fg: equipment == e ? gc.onEmber : gc.textSecondary,
                        onTap: () => setSheet(() => equipment = e),
                        vPad: 7,
                        fontSize: 12,
                      ),
                  ]),
                  const SizedBox(height: 16),
                  Text(t.levelFilter, style: AppTheme.s(11, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final d in kDifficulties)
                      Pill(
                        label: t.difficulty(d),
                        bg: difficulty == d ? gc.ember : gc.bgRaised2,
                        fg: difficulty == d ? gc.onEmber : gc.textSecondary,
                        onTap: () => setSheet(() => difficulty = d),
                        vPad: 7,
                        fontSize: 12,
                      ),
                  ]),
                  const SizedBox(height: 16),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setSheet(() => advanced = !advanced),
                    child: Row(
                      children: [
                        Icon(advanced ? PhosphorIconsRegular.caretDown : PhosphorIconsRegular.caretRight,
                            size: 16, color: gc.textSecondary),
                        const SizedBox(width: 8),
                        Text(t.advanced,
                            style: AppTheme.s(11, weight: FontWeight.w700, color: gc.textSecondary, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                  if (advanced) ...[
                    const SizedBox(height: 12),
                    Text(t.demoMedia, style: AppTheme.s(11, weight: FontWeight.w600, color: gc.textTertiary, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    if (mediaPath == null)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: pickMedia,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: gc.bgRaised2,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: gc.border),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(PhosphorIconsRegular.uploadSimple, size: 26, color: gc.textSecondary),
                              const SizedBox(height: 8),
                              Text(t.addMedia, style: AppTheme.s(13, weight: FontWeight.w600, color: gc.textSecondary)),
                              const SizedBox(height: 2),
                              Text(t.mediaHint, style: AppTheme.s(11, color: gc.textTertiary)),
                            ],
                          ),
                        ),
                      )
                    else
                      Stack(
                        children: [
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: gc.bgRaised2,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: gc.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: mediaIsVideo
                                ? Center(
                                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(PhosphorIconsFill.playCircle, size: 40, color: gc.textSecondary),
                                      const SizedBox(height: 6),
                                      Text(t.videoSelected, style: AppTheme.s(12, color: gc.textSecondary)),
                                    ]),
                                  )
                                : Center(child: Image.file(File(mediaPath!), fit: BoxFit.contain, alignment: Alignment.center)),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setSheet(() => mediaPath = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: gc.bg.withValues(alpha: 0.8), shape: BoxShape.circle),
                                child: Icon(PhosphorIconsRegular.x, size: 14, color: gc.text),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: pickMedia,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: gc.bg.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(100)),
                                child: Text(t.changeMedia, style: AppTheme.s(11, weight: FontWeight.w600, color: gc.text)),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: t.addExercise,
                    onTap: () async {
                      if (busy || nameCtrl.text.trim().isEmpty) return;
                      busy = true;
                      final id = fit.addCustomExercise(
                          name: nameCtrl.text, primary: muscle, equipment: equipment, difficulty: difficulty);
                      if (mediaPath != null) {
                        await fit.attachExerciseMedia(id, mediaPath!);
                      }
                      if (!sheetCtx.mounted) return;
                      Navigator.pop(sheetCtx);
                      if (onCreated != null) {
                        onCreated(id);
                      } else {
                        fit.openExercise(id);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
