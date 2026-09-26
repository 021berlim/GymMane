import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/fitness_translator.dart';
import '../l10n/l10n.dart';
import '../models/workout.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/share_photo_sheet.dart';
import '../widgets/ui_kit.dart';
import '../widgets/glass.dart';

String _getWorkoutTitle(LoggedSession session) {
  final sessionExIds = session.exercises.map((e) => e.id).toSet();
  if (sessionExIds.isNotEmpty) {
    for (final r in fit.routines) {
      final rExIds = r.exerciseIds.toSet();
      if (rExIds.isNotEmpty && sessionExIds.every((id) => rExIds.contains(id))) {
        return r.name;
      }
    }
  }

  final translatedNames = session.exercises
      .map((e) => fit.exerciseById(e.id)?.localizedName() ?? (appLanguage == 'pt' ? FitnessTranslator.translateExerciseName(e.name) : t.catalogName(e.id, e.name)))
      .where((name) => name.isNotEmpty)
      .toSet();

  if (translatedNames.isNotEmpty) {
    return translatedNames.take(3).join(', ');
  }
  return '';
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryItem {
  final DateTime date;
  final String label;
  final String data; // Base64 string or file path
  final LoggedSession session;
  final bool isBefore;

  _GalleryItem({
    required this.date,
    required this.label,
    required this.data,
    required this.session,
    required this.isBefore,
  });
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();

  List<_GalleryItem> _getPhotos() {
    final list = <_GalleryItem>[];
    for (final s in fit.sessions) {
      for (final pb in s.photosBefore) {
        if (pb.isNotEmpty) {
          list.add(_GalleryItem(
            date: s.date,
            label: t.photoBefore,
            data: pb,
            session: s,
            isBefore: true,
          ));
        }
      }
      for (final pa in s.photosAfter) {
        if (pa.isNotEmpty) {
          list.add(_GalleryItem(
            date: s.date,
            label: t.photoAfter,
            data: pa,
            session: s,
            isBefore: false,
          ));
        }
      }
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> _addNewPhoto(ImageSource source) async {
    if (fit.sessions.isEmpty) {
      _showNoSessionsWarning();
      return;
    }

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );
      if (picked != null) {
        final bytes = await File(picked.path).readAsBytes();
        final base64Str = base64Encode(bytes);
        if (mounted) {
          _showLinkToSessionSheet(context, base64Str);
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Erro ao selecionar foto: $e');
      }
    }
  }

  void _showNoSessionsWarning() {
    final gc = context.gc;
    showAppSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: gc.bgRaised,
          border: Border.all(color: gc.border),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 18),
            Icon(PhosphorIcons.warning(PhosphorIconsStyle.regular), size: 44, color: gc.accent),
            const SizedBox(height: 12),
            Text(
              'NENHUM TREINO ENCONTRADO',
              style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 2),
            ),
            const SizedBox(height: 6),
            Text(
              'Para salvar fotos de progresso na galeria, é necessário ter pelo menos 1 treino concluído no seu histórico.',
              style: AppTheme.s(13, color: gc.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'ENTENDI',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkToSessionSheet(BuildContext context, String base64Str) {
    final gc = context.gc;
    final sessions = fit.sessions.reversed.toList(); // Newest first
    LoggedSession selectedSession = sessions.first;
    bool isBefore = false;

    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.78,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: gc.bgRaised,
              border: Border.all(color: gc.border),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: gc.bgRaised2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'VINCULAR FOTO AO TREINO',
                  style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecione a qual treino do seu histórico esta foto pertence:',
                  style: AppTheme.s(13, color: gc.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // Timing selector (Antes / Depois)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => isBefore = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isBefore ? gc.accentSoft : gc.bgRaised2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isBefore ? gc.accent : gc.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t.photoBefore,
                            style: AppTheme.s(12, weight: isBefore ? FontWeight.w700 : FontWeight.w500, color: isBefore ? gc.accent : gc.textSecondary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => isBefore = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isBefore ? gc.accentSoft : gc.bgRaised2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: !isBefore ? gc.accent : gc.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t.photoAfter,
                            style: AppTheme.s(12, weight: !isBefore ? FontWeight.w700 : FontWeight.w500, color: !isBefore ? gc.accent : gc.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Text(
                  'TREINOS REGISTRADOS:',
                  style: AppTheme.d(11, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),

                // List of finished sessions
                Expanded(
                  child: ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (ctx, i) {
                      final s = sessions[i];
                      final isSelected = selectedSession == s;
                      final exercisesSummary = s.exercises.map((e) => t.catalogName(e.id, e.name)).join(', ');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => setSheetState(() => selectedSession = s),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? gc.accentSoft : gc.bgRaised2,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? gc.accent : gc.border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isSelected ? gc.accent : gc.textTertiary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.fullDate(s.date),
                                        style: AppTheme.d(14, weight: FontWeight.w700, color: gc.text),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${s.exercises.length} exercícios · ${fit.volumeLabel(s.volume)}',
                                        style: AppTheme.s(11, color: gc.textSecondary),
                                      ),
                                      if (exercisesSummary.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          exercisesSummary,
                                          style: AppTheme.s(10, color: gc.textTertiary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                PrimaryButton(
                  label: 'VINCULAR E SALVAR FOTO',
                  onTap: () {
                    fit.attachPhotoToSession(selectedSession, base64Str, before: isBefore);
                    Navigator.pop(context);
                    AppToast.showSuccess(context, 'Foto vinculada com sucesso!');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddPhotoOptions() {
    final gc = context.gc;
    showAppSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: gc.bgRaised,
          border: Border.all(color: gc.border),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: gc.bgRaised2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'ADICIONAR FOTO DE PROGRESSO',
              style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: gc.bgRaised2,
              leading: Icon(PhosphorIconsRegular.camera, color: gc.accent),
              title: Text(t.takePhoto, style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text)),
              onTap: () {
                Navigator.pop(context);
                _addNewPhoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: gc.bgRaised2,
              leading: Icon(PhosphorIconsRegular.image, color: gc.accent),
              title: Text(t.chooseGallery, style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text)),
              onTap: () {
                Navigator.pop(context);
                _addNewPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;

    return AnimatedBuilder(
      animation: fit,
      builder: (context, _) {
        final photos = _getPhotos();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: gc.text),
                        onPressed: fit.goHome,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.photoGallery,
                          style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text, letterSpacing: 2),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_a_photo, color: gc.accent),
                        onPressed: _showAddPhotoOptions,
                      ),
                    ],
                  ),
                ),

                // Photos Grid
                Expanded(
                  child: photos.isEmpty
                      ? _buildEmptyState(gc)
                      : CustomScrollView(
                          slivers: _buildDateGroupedSlivers(gc, photos),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(GymColors gc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: gc.bgRaised,
                shape: BoxShape.circle,
                border: Border.all(color: gc.border),
              ),
              child: Icon(Icons.photo_library_outlined, size: 36, color: gc.textTertiary),
            ),
            const SizedBox(height: 16),
            Text(
              t.noPhotosYet,
              style: AppTheme.d(16, weight: FontWeight.w700, color: gc.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tire fotos do seu progresso antes ou depois dos seus treinos para visualizar sua evolução.',
              style: AppTheme.s(13, color: gc.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: t.addPhoto.toUpperCase(),
              onTap: _showAddPhotoOptions,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDateGroupedSlivers(GymColors gc, List<_GalleryItem> photos) {
    // Group by date AND workout session so different workouts are kept in separate grids
    final grouped = <String, List<_GalleryItem>>{};
    for (final item in photos) {
      final key = '${item.date.year}-${item.date.month}-${item.date.day}_${item.session.date.millisecondsSinceEpoch}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final slivers = <Widget>[];
    for (final entry in grouped.entries) {
      final firstItem = entry.value.first;
      final dateLabel = t.fullDate(firstItem.date);
      final workoutName = _getWorkoutTitle(firstItem.session);

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: AppTheme.d(13, weight: FontWeight.w600, color: gc.text),
                ),
                if (workoutName.isNotEmpty)
                  Text(
                    workoutName,
                    style: AppTheme.s(11, color: gc.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      );
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildPhotoTile(gc, entry.value[index], photos),
              childCount: entry.value.length,
            ),
          ),
        ),
      );
    }
    return slivers;
  }

  String _heroTagFor(_GalleryItem item) =>
      'gallery_photo_${item.session.date.millisecondsSinceEpoch}_${item.isBefore}_${item.data.hashCode}';

  Widget _buildPhotoTile(GymColors gc, _GalleryItem item, List<_GalleryItem> allPhotos) {
    return GestureDetector(
      onTap: () => _openPhotoDetail(context, gc, item, allPhotos),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Hero(
          tag: _heroTagFor(item),
          child: _buildImageWidget(item.data),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String data) {
    if (data.startsWith('/') || data.startsWith('file://')) {
      final file = File(data.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    try {
      final bytes = base64Decode(data);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return Container(
        color: const Color(0xFF1F241C),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white38),
        ),
      );
    }
  }

  void _openPhotoDetail(BuildContext context, GymColors gc, _GalleryItem item, List<_GalleryItem> allPhotos) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenPhotoViewer(
            photos: allPhotos,
            initialIndex: allPhotos.indexOf(item),
            animation: animation,
            onDelete: (photo) {
              fit.deleteSessionPhoto(photo.session, before: photo.isBefore, photoData: photo.data);
              Navigator.of(context).pop();
            },
            onShare: (photo) {
              final durMins = photo.session.durationSec > 0 ? (photo.session.durationSec / 60).round() : 30;
              showSharePhotoSheet(
                context,
                durationStr: '$durMins MIN',
                prCount: 0,
                volumeKg: photo.session.volume,
                calories: (durMins * 5 + photo.session.volume * 0.02).round().clamp(20, 2000),
                muscleGroupsStr: '',
                initialImageBase64: photo.data,
              );
            },
          );
        },
      ),
    );
  }
}

class _FullScreenPhotoViewer extends StatefulWidget {
  final List<_GalleryItem> photos;
  final int initialIndex;
  final Animation<double> animation;
  final void Function(_GalleryItem) onDelete;
  final void Function(_GalleryItem) onShare;

  const _FullScreenPhotoViewer({
    required this.photos,
    required this.initialIndex,
    required this.animation,
    required this.onDelete,
    required this.onShare,
  });

  @override
  State<_FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<_FullScreenPhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(String data) {
    if (data.startsWith('/') || data.startsWith('file://')) {
      final file = File(data.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain);
      }
    }
    try {
      final bytes = base64Decode(data);
      return Image.memory(bytes, fit: BoxFit.contain);
    } catch (_) {
      return const Center(child: Icon(Icons.broken_image, color: Colors.white38, size: 48));
    }
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final currentPhoto = widget.photos[_currentIndex];

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) {
        final v = Curves.easeOutCubic.transform(widget.animation.value);
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 20 * v, sigmaY: 20 * v),
                  child: ColoredBox(color: Colors.black.withValues(alpha: 0.90 * v)),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Top bar
                    Opacity(
                      opacity: v,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    t.fullDate(currentPhoto.date),
                                    style: AppTheme.d(15, weight: FontWeight.w700, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_getWorkoutTitle(currentPhoto.session).isNotEmpty)
                                    Text(
                                      _getWorkoutTitle(currentPhoto.session),
                                      style: AppTheme.s(12, color: Colors.white70),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.light), color: Colors.white),
                              onPressed: () => _downloadImage(currentPhoto),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Photo viewer with swipe and zoom
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.photos.length,
                        onPageChanged: (index) {
                          setState(() => _currentIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final photo = widget.photos[index];
                          final heroTag = 'gallery_photo_${photo.session.date.millisecondsSinceEpoch}_${photo.isBefore}_${photo.data.hashCode}';
                          return InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 5.0,
                            child: Center(
                              child: Hero(
                                tag: heroTag,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: _buildImage(photo.data),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom action bar (Samsung/Xiaomi style)
                    Opacity(
                      opacity: v,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.white12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _bottomAction(
                              PhosphorIcons.export(PhosphorIconsStyle.light),
                              () => widget.onShare(currentPhoto),
                            ),
                            _bottomAction(
                              PhosphorIcons.trash(PhosphorIconsStyle.light),
                              () => _confirmDelete(gc, currentPhoto),
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Uint8List> _getPhotoBytes(String data) async {
    if (data.startsWith('file://')) {
      final path = data.replaceFirst('file://', '');
      final f = File(path);
      if (await f.exists()) return await f.readAsBytes();
    } else if (data.startsWith('/')) {
      final f = File(data);
      if (await f.exists()) return await f.readAsBytes();
    }
    return base64Decode(data);
  }

  Future<void> _downloadImage(_GalleryItem photo) async {
    try {
      final bytes = await _getPhotoBytes(photo.data);

      final dir = Directory('/storage/emulated/0/Pictures/FitIron');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('${dir.path}/FitIron_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes, flush: true);

      if (mounted) {
        AppToast.showDownload(context, 'Foto salva em Pictures/FitIron');
      }
    } catch (e) {
      if (mounted) {
        try {
          final bytes = await _getPhotoBytes(photo.data);

          final tempDir = await getApplicationDocumentsDirectory();
          final file = File('${tempDir.path}/FitIron_${DateTime.now().millisecondsSinceEpoch}.png');
          await file.writeAsBytes(bytes, flush: true);

          if (mounted) {
            AppToast.showDownload(context, 'Foto salva em ${file.path}');
          }
        } catch (e2) {
          if (mounted) {
            AppToast.showError(context, 'Erro ao salvar foto: $e2');
          }
        }
      }
    }
  }

  Widget _bottomAction(IconData icon, VoidCallback onTap, {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  void _confirmDelete(GymColors gc, _GalleryItem photo) {
    showAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: gc.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Excluir Foto?', style: AppTheme.d(16, weight: FontWeight.w700, color: gc.text)),
        content: Text(
          'Esta ação não pode ser desfeita.',
          style: AppTheme.s(13, color: gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: AppTheme.s(13, weight: FontWeight.w600, color: gc.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDelete(photo);
            },
            child: Text('Excluir', style: AppTheme.s(13, weight: FontWeight.w600, color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
